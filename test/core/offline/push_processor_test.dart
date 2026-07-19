import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/offline/push_processor.dart';
import 'package:vikunja_app/data/data_sources/bucket_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_view_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_comment_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_label_bulk_data_source.dart';
import 'package:vikunja_app/data/data_sources/user_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

final _t = DateTime.utc(2026, 1, 1);

UserDto _user(int id) =>
    UserDto(id: id, username: 'u$id', created: _t, updated: _t);

TaskDto _task(int id, {int projectId = 10, String title = 'srv'}) => TaskDto(
  id: id,
  title: title,
  projectId: projectId,
  createdBy: null,
  created: _t,
  updated: _t,
);

TaskCommentDto _comment(int id, {String text = 'hi'}) =>
    TaskCommentDto(id: id, comment: text, author: _user(1), created: _t, updated: _t);

// --- Fakes -------------------------------------------------------------------

class _FakeTaskDataSource implements TaskDataSource {
  _FakeTaskDataSource(this.log);
  final List<String> log;

  Response<TaskDto> Function(int projectId, TaskDto task)? addStub;
  Response<TaskDto> Function(TaskDto task)? updateStub;
  Response<Object> Function(int taskId)? deleteStub;

  @override
  Future<Response<TaskDto>> add(int projectId, TaskDto task) async {
    log.add('add(project=$projectId,id=${task.id})');
    return addStub!(projectId, task);
  }

  @override
  Future<Response<TaskDto>> update(TaskDto task) async {
    log.add('update(id=${task.id})');
    return updateStub!(task);
  }

  @override
  Future<Response<Object>> delete(int taskId) async {
    log.add('delete(id=$taskId)');
    return deleteStub != null ? deleteStub!(taskId) : VoidResponse();
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeCommentDataSource implements TaskCommentDataSource {
  _FakeCommentDataSource(this.log);
  final List<String> log;

  Response<TaskCommentDto> Function(int taskId, TaskCommentDto c)? createStub;

  @override
  Future<Response<TaskCommentDto>> create(int taskId, TaskCommentDto c) async {
    log.add('comment.create(task=$taskId)');
    return createStub!(taskId, c);
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeProjectDataSource implements ProjectDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeBucketDataSource implements BucketDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeTaskLabelBulkDataSource implements TaskLabelBulkDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeProjectViewDataSource implements ProjectViewDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeUserDataSource implements UserDataSource {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

// --- Setup -------------------------------------------------------------------

void main() {
  late AppDatabase db;
  late List<String> log;
  late _FakeTaskDataSource task;
  late _FakeCommentDataSource comment;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    log = [];
    task = _FakeTaskDataSource(log);
    comment = _FakeCommentDataSource(log);
  });

  tearDown(() => db.close());

  PushProcessor build() => PushProcessor(
    db: db,
    taskDataSource: task,
    taskCommentDataSource: comment,
    projectDataSource: _FakeProjectDataSource(),
    bucketDataSource: _FakeBucketDataSource(),
    taskLabelBulkDataSource: _FakeTaskLabelBulkDataSource(),
    projectViewDataSource: _FakeProjectViewDataSource(),
    userDataSource: _FakeUserDataSource(),
    tasksDao: db.tasksDao,
    projectsDao: db.projectsDao,
    bucketsDao: db.bucketsDao,
    taskCommentsDao: db.taskCommentsDao,
    pendingOpsDao: db.pendingOpsDao,
    keyValueDao: db.keyValueDao,
  );

  Future<void> seedTask({
    required int id,
    int? remoteId,
    int projectId = 10,
    String title = 'seed',
    bool isDirty = true,
  }) => db.into(db.tasks).insert(
    TasksCompanion.insert(
      id: Value(id),
      projectId: projectId,
      title: title,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      rawJson: '{}',
      remoteId: Value(remoteId),
      isDirty: Value(isDirty),
    ),
    mode: InsertMode.insertOrReplace,
  );

  Future<void> seedComment({
    required int id,
    required int taskId,
  }) => db.into(db.taskComments).insert(
    TaskCommentsCompanion.insert(
      id: Value(id),
      taskId: taskId,
      authorJson: '{}',
      comment: 'local',
      createdAt: '2026-01-01T00:00:00.000Z',
      rawJson: '{}',
      isDirty: const Value(true),
    ),
    mode: InsertMode.insertOrReplace,
  );

  Future<int> enqueue(PendingOp op) => db.pendingOpsDao.enqueue(op.toCompanion());

  PendingOp createTaskOp(int tempId, {int projectId = 10}) => PendingOp(
    type: PendingOpType.taskCreate,
    localId: tempId,
    payload: _task(tempId, projectId: projectId, title: 'neu').toJSON(),
    createdAt: '2026-01-01T00:00:00.000Z',
  );

  PendingOp updateTaskOp(int id) => PendingOp(
    type: PendingOpType.taskUpdate,
    localId: id,
    payload: _task(id, title: 'upd').toJSON(),
    createdAt: '2026-01-01T00:00:00.000Z',
  );

  PendingOp createCommentOp(int tempId, int taskTempRef) => PendingOp(
    type: PendingOpType.commentCreate,
    localId: tempId,
    payload: {..._comment(tempId).toJSON(), 'task_id': taskTempRef},
    tempIdRefs: {'taskId': taskTempRef},
    createdAt: '2026-01-01T00:00:00.000Z',
  );

  // --- Tests -----------------------------------------------------------------

  test('FIFO: Sends laufen strikt in opId-Reihenfolge', () async {
    await seedTask(id: 5, remoteId: 5);
    await seedTask(id: 6, remoteId: 6);
    await seedTask(id: 7, remoteId: 7);
    task.updateStub = (t) => SuccessResponse(_task(t.id), 200, {});

    await enqueue(updateTaskOp(5));
    await enqueue(updateTaskOp(6));
    await enqueue(updateTaskOp(7));

    final result = await build().pushAll();

    expect(result.success, isTrue);
    expect(log, ['update(id=5)', 'update(id=6)', 'update(id=7)']);
  });

  test('Create-Erfolg: Mapping auf DB-Zeile, abhängige Zeilen, Op entfernt', () async {
    await seedTask(id: -5, remoteId: null, title: 'offline');
    await seedComment(id: -7, taskId: -5);
    await db.taskLabelsDao.upsertLocal(-5, 1); // task_labels.taskId = -5

    task.addStub = (projectId, t) => SuccessResponse(_task(42), 200, {});
    await enqueue(createTaskOp(-5));

    final result = await build().pushAll();

    expect(result.success, isTrue);
    // (a) DB-Zeile umgezogen.
    expect(await db.tasksDao.getById(-5), isNull);
    final migrated = await db.tasksDao.getById(42);
    expect(migrated, isNotNull);
    expect(migrated!.remoteId, 42);
    expect(migrated.isDirty, isFalse);
    // (b) abhängige Zeilen umgezogen.
    final comments = await db.taskCommentsDao.watchCommentsByTask(42).first;
    expect(comments, hasLength(1));
    final labels = await db.taskLabelsDao.watchLabelsForTask(42).first;
    expect(labels.map((e) => e.labelId), [1]);
    // Op entfernt.
    expect(await db.pendingOpsDao.nextBatch(), isEmpty);
    // Mapping persistiert.
    expect(await db.keyValueDao.get(kvTempIdMapping), contains('42'));
  });

  test('Kommentar auf offline erzeugten Task: richtige Server-Task-ID', () async {
    await seedTask(id: -5, remoteId: null, title: 'offline');
    await seedComment(id: -7, taskId: -5);

    task.addStub = (projectId, t) => SuccessResponse(_task(42), 200, {});
    comment.createStub = (taskId, c) => SuccessResponse(_comment(99), 200, {});

    await enqueue(createTaskOp(-5));
    await enqueue(createCommentOp(-7, -5));

    final result = await build().pushAll();

    expect(result.success, isTrue);
    expect(log, ['add(project=10,id=-5)', 'comment.create(task=42)']);
    expect(await db.pendingOpsDao.nextBatch(), isEmpty);
  });

  test('Spätere Op-Payloads werden persistent umgeschrieben', () async {
    await seedTask(id: -5, remoteId: null);
    task.addStub = (projectId, t) => SuccessResponse(_task(42), 200, {});
    // Zweite Op bricht offline ab, bleibt daher (umgeschrieben) liegen.
    comment.createStub =
        (taskId, c) => ExceptionResponse(Exception('offline'), StackTrace.empty);

    await enqueue(createTaskOp(-5));
    await enqueue(createCommentOp(-7, -5));

    final result = await build().pushAll();

    expect(result.offline, isTrue);
    final remaining = await db.pendingOpsDao.nextBatch();
    expect(remaining, hasLength(1));
    final op = PendingOp.fromRow(remaining.single);
    expect(op.type, PendingOpType.commentCreate);
    expect(op.tempIdRefs['taskId'], 42); // Temp -5 -> Server 42
    expect(op.payload['task_id'], 42);
  });

  test('4xx auf Create: Op failed + Kaskade; unabhängige Op läuft weiter', () async {
    await seedTask(id: -5, remoteId: null);
    await seedTask(id: 9, remoteId: 9);

    task.addStub = (projectId, t) => ErrorResponse(400, {}, {'message': 'bad'});
    task.updateStub = (t) => SuccessResponse(_task(t.id), 200, {});

    await enqueue(createTaskOp(-5)); // op1 -> 4xx
    await enqueue(createCommentOp(-7, -5)); // op2 -> Kaskade (unresolvable)
    await enqueue(updateTaskOp(9)); // op3 -> unabhängig, ok

    final result = await build().pushAll();

    expect(result.success, isFalse);
    expect(result.failed, 2);
    expect(result.pushed, 1);
    // op1 + op2 bleiben mit lastError.
    final rows = await db.pendingOpsDao.nextBatch();
    expect(rows, hasLength(2));
    expect(rows.every((r) => r.lastError != null), isTrue);
    // Kommentar wurde nie gesendet.
    expect(log, ['add(project=10,id=-5)', 'update(id=9)']);
  });

  test('Offline mitten im Push: Abbruch, Rest pending, kein retryCount++', () async {
    await seedTask(id: 5, remoteId: 5);
    await seedTask(id: 6, remoteId: 6);
    await seedTask(id: 7, remoteId: 7);

    task.updateStub = (t) {
      if (t.id == 6) {
        return ExceptionResponse(Exception('offline'), StackTrace.empty);
      }
      return SuccessResponse(_task(t.id), 200, {});
    };

    await enqueue(updateTaskOp(5));
    await enqueue(updateTaskOp(6));
    await enqueue(updateTaskOp(7));

    final result = await build().pushAll();

    expect(result.offline, isTrue);
    final rows = await db.pendingOpsDao.nextBatch();
    expect(rows, hasLength(2)); // op2 + op3 bleiben
    expect(rows.every((r) => r.retryCount == 0), isTrue);
    expect(log, ['update(id=5)', 'update(id=6)']); // op3 nicht mehr erreicht
  });

  test('Delete auf ungesyncten Create: beide Ops weg, kein Server-Call', () async {
    await seedTask(id: -5, remoteId: null);

    await enqueue(createTaskOp(-5));
    await enqueue(PendingOp(
      type: PendingOpType.taskDelete,
      localId: -5,
      payload: const {},
      createdAt: '2026-01-01T00:00:00.000Z',
    ));

    final result = await build().pushAll();

    expect(result.success, isTrue);
    expect(result.pushed, 0);
    expect(log, isEmpty); // weder add noch delete
    expect(await db.pendingOpsDao.nextBatch(), isEmpty);
    expect(await db.tasksDao.getById(-5), isNull); // Temp-Zeile entfernt
  });

  test('Crash-Sicherheit: neuer Processor setzt über persistiertem Mapping fort',
      () async {
    await seedTask(id: -5, remoteId: null);
    task.addStub = (projectId, t) => SuccessResponse(_task(42), 200, {});
    comment.createStub =
        (taskId, c) => ExceptionResponse(Exception('offline'), StackTrace.empty);

    await enqueue(createTaskOp(-5));
    await enqueue(createCommentOp(-7, -5));

    // Lauf 1: Create ok, Kommentar bricht offline ab.
    final r1 = await build().pushAll();
    expect(r1.offline, isTrue);
    expect(await db.keyValueDao.get(kvTempIdMapping), isNotNull);

    // Lauf 2: neuer Processor, Kommentar jetzt online.
    final log2 = <String>[];
    final task2 = _FakeTaskDataSource(log2);
    final comment2 = _FakeCommentDataSource(log2)
      ..createStub = (taskId, c) => SuccessResponse(_comment(99), 200, {});
    final processor2 = PushProcessor(
      db: db,
      taskDataSource: task2,
      taskCommentDataSource: comment2,
      projectDataSource: _FakeProjectDataSource(),
      bucketDataSource: _FakeBucketDataSource(),
      taskLabelBulkDataSource: _FakeTaskLabelBulkDataSource(),
      projectViewDataSource: _FakeProjectViewDataSource(),
      userDataSource: _FakeUserDataSource(),
      tasksDao: db.tasksDao,
      projectsDao: db.projectsDao,
      bucketsDao: db.bucketsDao,
      taskCommentsDao: db.taskCommentsDao,
      pendingOpsDao: db.pendingOpsDao,
      keyValueDao: db.keyValueDao,
    );

    final r2 = await processor2.pushAll();

    expect(r2.success, isTrue);
    expect(log2, ['comment.create(task=42)']); // Server-ID aus Mapping
    expect(await db.pendingOpsDao.nextBatch(), isEmpty);
  });

  test('Single-Flight: zwei parallele pushAll -> ein Durchlauf', () async {
    await seedTask(id: 5, remoteId: 5);
    task.updateStub = (t) => SuccessResponse(_task(t.id), 200, {});
    await enqueue(updateTaskOp(5));

    final processor = build();
    final f1 = processor.pushAll();
    final f2 = processor.pushAll();
    expect(identical(f1, f2), isTrue);
    await Future.wait([f1, f2]);
    expect(log, ['update(id=5)']);
  });
}
