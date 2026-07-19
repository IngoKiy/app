import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/repositories/settings_repository.dart';
import 'package:vikunja_app/domain/repositories/task_repository.dart';
import 'package:vikunja_app/presentation/manager/project_controller.dart';

import 'controller_test_helpers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  bool displayDone = false;

  @override
  Future<bool> getDisplayDoneTasks(int projectId) async => displayDone;

  @override
  Future<bool> getLandingPageOnlyDueDateTasks() async => false;

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeTaskRepository implements TaskRepository {
  Future<Response<Task>> Function(int, Task)? addStub;

  @override
  Future<Response<Task>> add(int projectId, Task task) =>
      addStub!(projectId, task);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Project listProject() => Project(
    id: 1,
    title: 'P',
    views: [listViewDto(id: 1, projectId: 1).toDomain()],
    created: testTime,
    updated: testTime,
  );

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

  test('liest Tasks der List-View reaktiv aus der DB (nach Position sortiert)', () async {
    await seedTask(db, id: 11, projectId: 1, title: 'Zweite', position: 2);
    await seedTask(db, id: 10, projectId: 1, title: 'Erste', position: 1);

    final project = listProject();
    final container = createContainer();
    final model = await container.read(
      projectControllerProvider(project).future,
    );

    expect(model.tasks.length, 2);
    expect(model.tasks.first.id, 10);
    expect(model.tasks.last.id, 11);
  });

  test('offene-Task-Filter blendet erledigte Tasks aus', () async {
    await seedTask(db, id: 10, projectId: 1, title: 'Offen', done: false);
    await seedTask(db, id: 11, projectId: 1, title: 'Erledigt', done: true);

    final project = listProject();
    final container = createContainer();
    final model = await container.read(
      projectControllerProvider(project).future,
    );

    expect(model.tasks.length, 1);
    expect(model.tasks.first.id, 10);
  });

  test('addTask upsertet die Server-Antwort in die DB', () async {
    final taskRepo = _FakeTaskRepository()
      ..addStub = (projectId, task) async => SuccessResponse(
        Task(
          id: 55,
          title: task.title,
          createdBy: null,
          projectId: projectId,
          created: testTime,
          updated: testTime,
        ),
        201,
        {},
      );

    final project = listProject();
    final container = createContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(taskRepo)],
    );
    await container.read(projectControllerProvider(project).future);

    final ok = await container
        .read(projectControllerProvider(project).notifier)
        .addTask(
          project,
          Task(
            title: 'Neu',
            createdBy: null,
            projectId: 1,
            created: testTime,
            updated: testTime,
          ),
        );

    expect(ok, isTrue);
    final row = await db.tasksDao.getById(55);
    expect(row, isNotNull);
    expect(row!.title, 'Neu');
  });
}
