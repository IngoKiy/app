import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';

import '../../core/offline/offline_test_fakes.dart';
import 'controller_test_helpers.dart';

class _StubConnectivity extends ConnectivityStatus {
  @override
  bool build() => true;
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        connectivityStatusProvider.overrideWith(() => _StubConnectivity()),
        opExecutorProvider.overrideWithValue(buildExecutor(db)),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('liest Projekte reaktiv aus der DB und gruppiert Unterprojekte', () async {
    await seedProject(db, id: 1, title: 'Parent', parentProjectId: 0);
    await seedProject(db, id: 2, title: 'Sub 1', parentProjectId: 1);
    await seedProject(db, id: 3, title: 'Sub 2', parentProjectId: 1);
    await seedProject(db, id: 4, title: 'Independent', parentProjectId: 0);

    final container = createContainer();
    final model = await container.read(projectsControllerProvider.future);

    expect(model.projects.length, 2);
    expect(model.projects[0].id, 1);
    expect(model.projects[1].id, 4);
    expect(model.projects[0].subprojects.length, 2);
    expect(model.projects[0].subprojects.first.id, 2);
    expect(model.projects[0].subprojects.last.id, 3);
  });

  test('Stream-Update: neue Projekte erscheinen ohne reload', () async {
    await seedProject(db, id: 1, title: 'A');

    final container = createContainer();
    container.listen(projectsControllerProvider, (_, _) {}, fireImmediately: true);
    await container.read(projectsControllerProvider.future);

    await seedProject(db, id: 2, title: 'B');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final model = container.read(projectsControllerProvider).value!;
    expect(model.projects.length, 2);
  });

  test('create (offline) legt optimistisch ein Temp-Projekt an + Outbox', () async {
    final container = createContainer();
    await container.read(projectsControllerProvider.future);

    container
        .read(projectsControllerProvider.notifier)
        .create(Project(title: 'Neu'));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final row = await db.projectsDao.getById(-1);
    expect(row, isNotNull);
    expect(row!.title, 'Neu');
    expect(row.isDirty, isTrue);
    expect(await db.pendingOpsDao.nextBatch(), hasLength(1));
  });

  test('REPRO: neues Projekt erscheint optimistisch im topLevel-Model', () async {
    final container = createContainer();
    container.listen(projectsControllerProvider, (_, _) {}, fireImmediately: true);
    await container.read(projectsControllerProvider.future);

    container
        .read(projectsControllerProvider.notifier)
        .create(Project(title: 'Neu'));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final model = container.read(projectsControllerProvider).value!;
    expect(
      model.projects.map((p) => p.title),
      contains('Neu'),
      reason: 'Frisch angelegtes Projekt muss im topLevel-Baum auftauchen',
    );
  });

  test('REPRO: neues Projekt erscheint nach Online-Erfolg im topLevel-Model',
      () async {
    // Server bestätigt sofort mit realer ID (Gerät ist online).
    final projectDs = FakeProjectDataSource()
      ..createStub = (p) => SuccessResponse<ProjectDto>(
            ProjectDto(
              id: 100,
              title: p.title,
              parentProjectId: p.parentProjectId,
              created: testTime,
              updated: testTime,
            ),
            201,
            const {},
          );

    final container = createContainer(
      overrides: [
        opExecutorProvider.overrideWithValue(
          buildExecutor(db, project: projectDs),
        ),
      ],
    );
    container.listen(projectsControllerProvider, (_, _) {}, fireImmediately: true);
    await container.read(projectsControllerProvider.future);

    container
        .read(projectsControllerProvider.notifier)
        .create(Project(title: 'Neu'));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final model = container.read(projectsControllerProvider).value!;
    expect(
      model.projects.map((p) => p.title),
      contains('Neu'),
      reason: 'Nach Online-Erfolg muss das Projekt (mit Server-ID) sichtbar sein',
    );
  });

  test('REPRO: Server-Ablehnung rollt zurück und meldet den Fehler', () async {
    // Server lehnt ab (z.B. 400) — die optimistische Zeile wird zurückgerollt.
    // Im schnellen Netz (Tailnet) passiert das binnen eines Frames, sodass der
    // Nutzer nichts sieht: "erscheint nie, auch nicht optimistisch".
    final projectDs = FakeProjectDataSource()
      ..createStub = (p) => ErrorResponse<ProjectDto>(
            400,
            const {},
            const {'message': 'invalid'},
          );

    final container = createContainer(
      overrides: [
        opExecutorProvider.overrideWithValue(
          buildExecutor(db, project: projectDs),
        ),
      ],
    );
    container.listen(projectsControllerProvider, (_, _) {}, fireImmediately: true);
    await container.read(projectsControllerProvider.future);

    final result = await container
        .read(projectsControllerProvider.notifier)
        .create(Project(title: 'Neu'));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Nach Rollback ist die Zeile weg …
    expect(await db.projectsDao.getById(-1), isNull);
    final model = container.read(projectsControllerProvider).value!;
    expect(model.projects.map((p) => p.title), isNot(contains('Neu')));
    // … und die UI erhält ein auswertbares Fehlerergebnis (nicht ok).
    expect(result.ok, isFalse);
  });
}
