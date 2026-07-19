import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/filter_dto.dart';
import 'package:vikunja_app/data/models/project_view_dto.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/repositories/settings_repository.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';

import 'controller_test_helpers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  bool onlyDue = false;

  @override
  Future<bool> getLandingPageOnlyDueDateTasks() async => onlyDue;

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'liefert offene Tasks projektübergreifend aus der DB inkl. Projektzuordnung',
    () async {
      await seedProject(db, id: 1, title: 'Projekt A');
      await seedTask(db, id: 10, projectId: 1, title: 'Offen', done: false);
      await seedTask(db, id: 11, projectId: 1, title: 'Erledigt', done: true);

      final container = createContainer();
      final model = await container.read(taskPageControllerProvider.future);

      expect(model.tasks.length, 1);
      expect(model.tasks.first.id, 10);
      expect(model.tasks.first.project?.title, 'Projekt A');
    },
  );

  test('Stream-Update: neu geseedete offene Tasks erscheinen ohne reload', () async {
    await seedProject(db, id: 1, title: 'Projekt A');
    await seedTask(db, id: 10, projectId: 1, done: false);

    final container = createContainer();
    container.listen(taskPageControllerProvider, (_, _) {}, fireImmediately: true);
    await container.read(taskPageControllerProvider.future);

    await seedTask(db, id: 20, projectId: 1, done: false);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final model = container.read(taskPageControllerProvider).value!;
    expect(model.tasks.length, 2);
  });

  test(
    'gespeicherter Übersichts-Filter wird offline lokal ausgewertet',
    () async {
      // Pseudo-Filter-Projekt (id 100) mit Filterstring in einer View.
      await seedProject(
        db,
        id: 100,
        title: 'Wichtig',
        views: [_filterViewDto(id: 1, projectId: 100, filter: 'priority >= 3')],
      );
      // Reguläres Projekt + offene Tasks mit unterschiedlicher Priorität.
      await seedProject(db, id: 1, title: 'Projekt A');
      await seedTask(db, id: 10, projectId: 1, title: 'Hoch', priority: 5);
      await seedTask(db, id: 11, projectId: 1, title: 'Niedrig', priority: 1);

      final user = User(
        id: 1,
        username: 'u',
        settings: UserSettings(
          frontendSettings: {'filter_id_used_on_overview': 100},
        ),
      );

      final container = createContainer();
      container.read(currentUserProvider.notifier).set(user);

      // taskRepositoryProvider ist NICHT überschrieben: Würde der Online-Pfad
      // betreten, flöge ein Fehler -> der grüne Test beweist lokale Auswertung.
      final model = await container.read(taskPageControllerProvider.future);

      expect(model.tasks.map((t) => t.id), [10]);
    },
  );
}

ProjectViewDto _filterViewDto({
  required int id,
  required int projectId,
  required String filter,
}) => ProjectViewDto(
  testTime,
  0,
  0,
  id,
  0,
  projectId,
  'Filter View',
  testTime,
  FilterDto('', const [], const [], filter, false),
  null,
  'manual',
  'list',
);
