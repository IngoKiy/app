import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/core/sync/sync_service.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/data/data_sources/bucket_data_source.dart';
import 'package:vikunja_app/data/data_sources/label_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_data_source.dart';
import 'package:vikunja_app/data/data_sources/server_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_comment_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/data_sources/user_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/bucket_dto.dart';
import 'package:vikunja_app/data/models/label_dto.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/project_view_dto.dart';
import 'package:vikunja_app/data/models/server_dto.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

// --- Test-Fakes für die Data-Sources -----------------------------------------

class _FakeServerDataSource implements ServerDataSource {
  int callCount = 0;
  late Future<Response<ServerDto>> Function() getInfoStub;
  @override
  Future<Response<ServerDto>> getInfo() {
    callCount++;
    return getInfoStub();
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeUserDataSource implements UserDataSource {
  Response<UserDto> Function() getCurrentUserStub =
      () => SuccessResponse(_user(id: 1), 200, {});
  @override
  Future<Response<UserDto>> getCurrentUser() async => getCurrentUserStub();

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeLabelDataSource implements LabelDataSource {
  Response<List<LabelDto>> Function() getAllStub =
      () => SuccessResponse(<LabelDto>[], 200, {});
  @override
  Future<Response<List<LabelDto>>> getAll({String? query}) async =>
      getAllStub();

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeProjectDataSource implements ProjectDataSource {
  Response<List<ProjectDto>> Function(int page) getAllStub =
      (page) => SuccessResponse(<ProjectDto>[], 200, {});
  @override
  Future<Response<List<ProjectDto>>> getAll({int page = 1}) async =>
      getAllStub(page);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeTaskDataSource implements TaskDataSource {
  /// (projectId, viewId, page) -> Response.
  Response<List<TaskDto>> Function(int projectId, int viewId, int page)
  viewStub = (_, _, _) => SuccessResponse(<TaskDto>[], 200, {});

  Response<TaskDto> Function(int taskId)? getTaskStub;
  Response<List<UserDto>> Function(int projectId)? assignableStub;

  @override
  Future<Response<List<TaskDto>>> getAllByProjectView(
    int projectId,
    int view, [
    Map<String, List<String>>? queryParameters,
  ]) async {
    final page = int.tryParse(queryParameters?['page']?.first ?? '1') ?? 1;
    return viewStub(projectId, view, page);
  }

  @override
  Future<Response<List<TaskDto>>> getAllByProject(
    int projectId, [
    Map<String, List<String>>? queryParameters,
  ]) async {
    final page = int.tryParse(queryParameters?['page']?.first ?? '1') ?? 1;
    return viewStub(projectId, 0, page);
  }

  @override
  Future<Response<TaskDto>> getTask(int taskId) async => getTaskStub!(taskId);

  @override
  Future<Response<List<UserDto>>> getAssignableUsers(
    int projectId, [
    String? query,
  ]) async => assignableStub!(projectId);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeBucketDataSource implements BucketDataSource {
  Response<List<BucketDto>> Function(int projectId, int viewId) getAllByListStub =
      (_, _) => SuccessResponse(<BucketDto>[], 200, {});
  @override
  Future<Response<List<BucketDto>>> getAllByList(
    int projectId,
    int viewId, [
    Map<String, List<String>>? queryParameters,
  ]) async => getAllByListStub(projectId, viewId);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeTaskCommentDataSource implements TaskCommentDataSource {
  Response<List<TaskCommentDto>> Function(int taskId)? getAllStub;
  @override
  Future<Response<List<TaskCommentDto>>> getAll(int taskId) async =>
      getAllStub!(taskId);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

/// Connectivity ohne Platform-Channel (für Tests deterministisch).
class _StubConnectivity extends ConnectivityStatus {
  @override
  bool build() => true;
}

// --- DTO-Builder -------------------------------------------------------------

final _t = DateTime.utc(2026, 1, 1);

UserDto _user({required int id, String username = 'user'}) =>
    UserDto(id: id, username: username, created: _t, updated: _t);

ServerDto _server() =>
    ServerDto(null, null, null, null, null, null, null, null, null, null, null, '1.0');

ProjectViewDto _view({
  required int id,
  required int projectId,
  required String kind,
  int doneBucketId = 0,
}) => ProjectViewDto(
  _t,
  0,
  doneBucketId,
  id,
  0,
  projectId,
  '$kind view',
  _t,
  null,
  null,
  'manual',
  kind,
);

ProjectDto _project({
  required int id,
  String title = 'Projekt',
  List<ProjectViewDto> views = const [],
}) => ProjectDto(id: id, title: title, views: views, created: _t, updated: _t);

TaskDto _task({
  required int id,
  required int projectId,
  String title = 'Task',
  List<LabelDto> labels = const [],
  List<UserDto> assignees = const [],
}) => TaskDto(
  id: id,
  title: title,
  projectId: projectId,
  createdBy: null,
  labels: labels,
  assignees: assignees,
  created: _t,
  updated: _t,
);

LabelDto _label({required int id, String title = 'Label'}) =>
    LabelDto(id: id, title: title, createdBy: _user(id: 1), created: _t, updated: _t);

BucketDto _bucket({required int id, required int viewId, String title = 'Bucket'}) =>
    BucketDto(
      id: id,
      projectViewId: viewId,
      title: title,
      limit: 0,
      createdBy: _user(id: 1),
      created: _t,
      updated: _t,
    );

// --- Test-Setup --------------------------------------------------------------

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late SyncStateNotifier syncState;
  late _FakeServerDataSource server;
  late _FakeUserDataSource user;
  late _FakeLabelDataSource label;
  late _FakeProjectDataSource project;
  late _FakeTaskDataSource task;
  late _FakeBucketDataSource bucket;
  late _FakeTaskCommentDataSource comment;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        connectivityStatusProvider.overrideWith(() => _StubConnectivity()),
      ],
    );
    syncState = container.read(syncStateNotifierProvider.notifier);

    server = _FakeServerDataSource()
      ..getInfoStub = () async => SuccessResponse(_server(), 200, {});
    user = _FakeUserDataSource();
    label = _FakeLabelDataSource();
    project = _FakeProjectDataSource();
    task = _FakeTaskDataSource();
    bucket = _FakeBucketDataSource();
    comment = _FakeTaskCommentDataSource();
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  SyncService buildService() => SyncService(
    serverDataSource: server,
    userDataSource: user,
    labelDataSource: label,
    projectDataSource: project,
    taskDataSource: task,
    bucketDataSource: bucket,
    taskCommentDataSource: comment,
    projectsDao: db.projectsDao,
    tasksDao: db.tasksDao,
    bucketsDao: db.bucketsDao,
    labelsDao: db.labelsDao,
    usersDao: db.usersDao,
    taskLabelsDao: db.taskLabelsDao,
    taskAssigneesDao: db.taskAssigneesDao,
    taskCommentsDao: db.taskCommentsDao,
    keyValueDao: db.keyValueDao,
    syncState: syncState,
  );

  // Fügt einen Task direkt (mit voller Flag-Kontrolle) in die DB ein.
  Future<void> seedTask({
    required int id,
    required int remoteId,
    int projectId = 10,
    String title = 'seed',
    bool isDirty = false,
    bool isDeleted = false,
  }) => db
      .into(db.tasks)
      .insert(
        TasksCompanion.insert(
          id: Value(id),
          projectId: projectId,
          title: title,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
          rawJson: '{}',
          remoteId: Value(remoteId),
          isDirty: Value(isDirty),
          isDeleted: Value(isDeleted),
        ),
        mode: InsertMode.insertOrReplace,
      );

  test('Merge-Matrix: insert/update/dirty/delete/tombstone', () async {
    // Ausgangszustand.
    await seedTask(id: 2, remoteId: 2, title: 'alt'); // clean -> update
    await seedTask(
      id: 3,
      remoteId: 3,
      title: 'lokal dirty',
      isDirty: true,
    ); // dirty -> Server verworfen
    await seedTask(id: 4, remoteId: 4, title: 'clean fehlt'); // -> delete
    await seedTask(
      id: 5,
      remoteId: 5,
      title: 'dirty fehlt',
      isDirty: true,
    ); // -> bleibt
    await seedTask(
      id: 6,
      remoteId: 6,
      title: 'tombstone',
      isDirty: true,
      isDeleted: true,
    ); // -> nicht wiederbelebt

    project.getAllStub = (page) => page == 1
        ? SuccessResponse([
            _project(id: 10, views: [_view(id: 100, projectId: 10, kind: 'list')]),
          ], 200, {})
        : SuccessResponse(<ProjectDto>[], 200, {});

    task.viewStub = (projectId, viewId, page) => page == 1
        ? SuccessResponse([
            _task(id: 1, projectId: 10, title: 'neu1'),
            _task(id: 2, projectId: 10, title: 'neu2'),
            _task(id: 3, projectId: 10, title: 'server3'),
            _task(id: 6, projectId: 10, title: 'server6'),
          ], 200, {})
        : SuccessResponse(<TaskDto>[], 200, {});

    final result = await buildService().pullAll();

    expect(result.success, isTrue);

    // insert
    expect((await db.tasksDao.getById(1))?.title, 'neu1');
    // update (clean)
    expect((await db.tasksDao.getById(2))?.title, 'neu2');
    // dirty -> Server verworfen
    final t3 = await db.tasksDao.getById(3);
    expect(t3?.title, 'lokal dirty');
    expect(t3?.isDirty, isTrue);
    // clean + fehlt -> gelöscht
    expect(await db.tasksDao.getById(4), isNull);
    // dirty + fehlt -> bleibt
    expect(await db.tasksDao.getById(5), isNotNull);
    // tombstone -> nicht wiederbelebt
    final t6 = await db.tasksDao.getById(6);
    expect(t6, isNotNull);
    expect(t6!.title, 'tombstone');
    expect(t6.isDeleted, isTrue);
  });

  test('Pagination: Tasks über 2 Seiten werden vollständig gemergt', () async {
    project.getAllStub = (page) => page == 1
        ? SuccessResponse([
            _project(id: 10, views: [_view(id: 100, projectId: 10, kind: 'list')]),
          ], 200, {})
        : SuccessResponse(<ProjectDto>[], 200, {});

    task.viewStub = (projectId, viewId, page) {
      switch (page) {
        case 1:
          return SuccessResponse([
            _task(id: 1, projectId: 10),
            _task(id: 2, projectId: 10),
          ], 200, {});
        case 2:
          return SuccessResponse([_task(id: 3, projectId: 10)], 200, {});
        default:
          return SuccessResponse(<TaskDto>[], 200, {});
      }
    };

    final result = await buildService().pullAll();

    expect(result.success, isTrue);
    expect(result.stats.tasksUpserted, 3);
    expect(await db.tasksDao.getById(1), isNotNull);
    expect(await db.tasksDao.getById(3), isNotNull);
  });

  test(
    'Abbruch mitten im Pull (ExceptionResponse) -> Teilmerge, kein Error, '
    'kein last_full_sync',
    () async {
      project.getAllStub = (page) => page == 1
          ? SuccessResponse([
              _project(id: 1, views: [_view(id: 11, projectId: 1, kind: 'list')]),
              _project(id: 2, views: [_view(id: 22, projectId: 2, kind: 'list')]),
              _project(id: 3, views: [_view(id: 33, projectId: 3, kind: 'list')]),
            ], 200, {})
          : SuccessResponse(<ProjectDto>[], 200, {});

      task.viewStub = (projectId, viewId, page) {
        if (projectId == 1) {
          return page == 1
              ? SuccessResponse([_task(id: 111, projectId: 1)], 200, {})
              : SuccessResponse(<TaskDto>[], 200, {});
        }
        if (projectId == 2) {
          return ExceptionResponse(Exception('offline'), StackTrace.empty);
        }
        return SuccessResponse(<TaskDto>[], 200, {});
      };

      final result = await buildService().pullAll();

      expect(result.offline, isTrue);
      expect(result.success, isFalse);
      // Projekt 1 gemergt.
      expect(await db.tasksDao.getById(111), isNotNull);
      // Kein Error-State.
      expect(
        container.read(syncStateNotifierProvider).phase,
        isNot(SyncPhase.error),
      );
      // Kein last_full_sync.
      expect(await db.keyValueDao.get(kvLastFullSync), isNull);
    },
  );

  test('4xx-Fehler setzt Error-State', () async {
    server.getInfoStub = () async => ErrorResponse(403, {}, {'message': 'nope'});

    final result = await buildService().pullAll();

    expect(result.success, isFalse);
    expect(result.offline, isFalse);
    expect(result.errorMessage, isNotNull);
    expect(container.read(syncStateNotifierProvider).phase, SyncPhase.error);
    expect(await db.keyValueDao.get(kvLastFullSync), isNull);
  });

  test('Single-Flight: zwei parallele pullAll -> eine Ausführung', () async {
    final gate = Completer<void>();
    server.getInfoStub = () async {
      await gate.future;
      return SuccessResponse(_server(), 200, {});
    };

    final service = buildService();
    final f1 = service.pullAll();
    final f2 = service.pullAll();

    expect(identical(f1, f2), isTrue);

    gate.complete();
    await Future.wait([f1, f2]);

    expect(server.callCount, 1);
  });

  test(
    'userInitiated: true wird während des Pulls in den SyncState '
    'durchgereicht und danach wieder zurückgesetzt',
    () async {
      final gate = Completer<void>();
      server.getInfoStub = () async {
        await gate.future;
        return SuccessResponse(_server(), 200, {});
      };

      final future = buildService().pullAll(userInitiated: true);

      // Während des Pulls: syncing + userInitiated gesetzt.
      final duringPull = container.read(syncStateNotifierProvider);
      expect(duringPull.phase, SyncPhase.syncing);
      expect(duringPull.userInitiated, isTrue);

      gate.complete();
      await future;

      // Nach Abschluss: idle, userInitiated zurückgesetzt.
      final afterPull = container.read(syncStateNotifierProvider);
      expect(afterPull.phase, SyncPhase.idle);
      expect(afterPull.userInitiated, isFalse);
    },
  );

  test(
    'userInitiated bleibt standardmäßig false (automatischer Sync)',
    () async {
      final gate = Completer<void>();
      server.getInfoStub = () async {
        await gate.future;
        return SuccessResponse(_server(), 200, {});
      };

      final future = buildService().pullAll();

      final duringPull = container.read(syncStateNotifierProvider);
      expect(duringPull.phase, SyncPhase.syncing);
      expect(duringPull.userInitiated, isFalse);

      gate.complete();
      await future;
    },
  );

  test('Task-Junctions (Labels/Assignees) werden korrekt ersetzt', () async {
    // Ausgangszustand: Task 1 mit veralteten cleanen Relationen + einer
    // dirty-Relation, die erhalten bleiben muss.
    await seedTask(id: 1, remoteId: 1, projectId: 10, title: 'T1');
    await db.taskLabelsDao.upsertFromServer(1, 9); // clean, soll weg
    await db.taskLabelsDao.upsertLocal(1, 7); // dirty, bleibt
    await db.taskAssigneesDao.upsertFromServer(1, 99); // clean, soll weg

    project.getAllStub = (page) => page == 1
        ? SuccessResponse([
            _project(id: 10, views: [_view(id: 100, projectId: 10, kind: 'list')]),
          ], 200, {})
        : SuccessResponse(<ProjectDto>[], 200, {});

    task.viewStub = (projectId, viewId, page) => page == 1
        ? SuccessResponse([
            _task(
              id: 1,
              projectId: 10,
              labels: [_label(id: 1), _label(id: 2)],
              assignees: [_user(id: 5)],
            ),
          ], 200, {})
        : SuccessResponse(<TaskDto>[], 200, {});

    await buildService().pullAll();

    final labelIds =
        (await db.taskLabelsDao.watchLabelsForTask(1).first)
            .map((e) => e.labelId)
            .toSet();
    // Server-Labels 1,2 gesetzt; dirty 7 bleibt; clean 9 entfernt.
    expect(labelIds, {1, 2, 7});

    final assigneeIds =
        (await db.taskAssigneesDao.watchAssigneesForTask(1).first)
            .map((e) => e.userId)
            .toSet();
    expect(assigneeIds, {5});
  });

  test('Kanban-View: Buckets werden gemergt und aufgeräumt', () async {
    // Ausgangszustand: ein cleaner Bucket, der auf dem Server fehlt.
    await db.bucketsDao.upsertFromServer(
      BucketsCompanion.insert(
        id: Value(88),
        projectId: 10,
        title: 'alt',
        rawJson: '{}',
        remoteId: Value(88),
      ),
    );

    project.getAllStub = (page) => page == 1
        ? SuccessResponse([
            _project(id: 10, views: [
              _view(id: 100, projectId: 10, kind: 'list'),
              _view(id: 200, projectId: 10, kind: 'kanban', doneBucketId: 2),
            ]),
          ], 200, {})
        : SuccessResponse(<ProjectDto>[], 200, {});

    bucket.getAllByListStub = (projectId, viewId) => SuccessResponse([
      _bucket(id: 1, viewId: 200, title: 'Todo'),
      _bucket(id: 2, viewId: 200, title: 'Done'),
    ], 200, {});

    final result = await buildService().pullAll();

    expect(result.success, isTrue);
    final buckets = await db.bucketsDao.watchBucketsByProject(10).first;
    expect(buckets.map((b) => b.id).toSet(), {1, 2});
    expect(await db.bucketsDao.getById(88), isNull); // aufgeräumt
    // done-Bucket-Flag aus der View abgeleitet.
    expect((await db.bucketsDao.getById(2))?.isDoneBucket, isTrue);
    expect((await db.bucketsDao.getById(1))?.isDoneBucket, isFalse);
  });

  test('pullTaskDetails upsertet Task + Kommentare', () async {
    task.getTaskStub = (id) =>
        SuccessResponse(_task(id: id, projectId: 10, title: 'Detail'), 200, {});
    comment.getAllStub = (taskId) => SuccessResponse([
      TaskCommentDto(id: 1, comment: 'Hallo', author: _user(id: 1)),
    ], 200, {});

    await buildService().pullTaskDetails(42);

    expect((await db.tasksDao.getById(42))?.title, 'Detail');
    final comments = await db.taskCommentsDao.watchCommentsByTask(42).first;
    expect(comments, hasLength(1));
    expect(comments.first.comment, 'Hallo');
  });

  test('pullProjectUsers spiegelt Nutzer in die users-Tabelle', () async {
    task.assignableStub = (projectId) =>
        SuccessResponse([_user(id: 7, username: 'alice')], 200, {});

    await buildService().pullProjectUsers(10);

    expect((await db.usersDao.getById(7))?.username, 'alice');
  });
}
