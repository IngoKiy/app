import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/repositories/project_repository.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';

import 'controller_test_helpers.dart';

class _MockProjectRepository implements ProjectRepository {
  Future<Response<Project>> Function(Project)? createStub;

  @override
  Future<Response<Project>> create(Project p) => createStub!(p);

  @override
  Future<Response<List<Project>>> getAll({int page = 1}) =>
      throw UnimplementedError();

  @override
  Future<Response<Project>> update(Project p) => throw UnimplementedError();
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db), ...overrides],
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

  test('create upsertet die Server-Antwort in die DB', () async {
    final repo = _MockProjectRepository()
      ..createStub = (p) async => SuccessResponse(
        Project(id: 99, title: p.title, created: testTime, updated: testTime),
        201,
        {},
      );

    final container = createContainer(
      overrides: [projectRepositoryProvider.overrideWithValue(repo)],
    );
    await container.read(projectsControllerProvider.future);

    container
        .read(projectsControllerProvider.notifier)
        .create(Project(title: 'Neu'));
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final row = await db.projectsDao.getById(99);
    expect(row, isNotNull);
    expect(row!.title, 'Neu');
  });
}
