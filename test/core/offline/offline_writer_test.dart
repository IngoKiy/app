import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';

import 'offline_test_fakes.dart';

final _t = DateTime.utc(2026, 1, 1);

TaskDto _srvTask(int id, {int projectId = 10, String title = 'srv'}) => TaskDto(
  id: id,
  title: title,
  projectId: projectId,
  createdBy: null,
  created: _t,
  updated: _t,
);

TaskCommentDto _srvComment(int id, {String text = 'srv'}) => TaskCommentDto(
  id: id,
  comment: text,
  author: UserDto(id: 1, username: 'u1', created: _t, updated: _t),
  created: _t,
  updated: _t,
);

Task _task({int id = 0, String title = 'neu', bool done = false}) => Task(
  id: id,
  title: title,
  done: done,
  createdBy: null,
  projectId: 10,
  created: _t,
  updated: _t,
);

void main() {
  late AppDatabase db;
  late FakeTaskDataSource task;
  late FakeCommentDataSource comment;
  late OfflineWriter writer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    task = FakeTaskDataSource();
    comment = FakeCommentDataSource();
    writer = buildWriter(db, buildExecutor(db, task: task, comment: comment));
  });

  tearDown(() => db.close());

  Future<void> seedTask({
    required int id,
    int? remoteId,
    String title = 'seed',
    bool isDirty = false,
    int projectId = 10,
  }) => db.into(db.tasks).insert(
    TasksCompanion.insert(
      id: Value(id),
      projectId: projectId,
      title: title,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      rawJson: '{"id":$id,"title":"$title","project_id":$projectId,'
          '"description":"","done":false,'
          '"updated":"2026-01-01T00:00:00.000Z",'
          '"created":"2026-01-01T00:00:00.000Z"}',
      remoteId: Value(remoteId),
      isDirty: Value(isDirty),
    ),
    mode: InsertMode.insertOrReplace,
  );

  Future<List<PendingOp>> ops() async =>
      (await db.pendingOpsDao.nextBatch(limit: 100))
          .map(PendingOp.fromRow)
          .toList();

  // --- Task add --------------------------------------------------------------

  group('addTask', () {
    test('online-Erfolg: kein Enqueue, Server-Zeile, dirty gelöscht', () async {
      task.addStub = (p, t) => SuccessResponse(_srvTask(42, title: t.title), 200, {});

      final res = await writer.addTask(10, _task(title: 'neu'));

      expect(res.status, OfflineWriteStatus.synced);
      expect(await ops(), isEmpty);
      final row = await db.tasksDao.getById(42);
      expect(row, isNotNull);
      expect(row!.isDirty, isFalse);
      expect(await db.tasksDao.getById(-1), isNull); // Temp-Zeile umgezogen
    });

    test('offline: Enqueue + optimistische Temp-Zeile (dirty)', () async {
      final res = await writer.addTask(10, _task(title: 'neu'));

      expect(res.status, OfflineWriteStatus.queued);
      final queued = await ops();
      expect(queued, hasLength(1));
      expect(queued.single.type, PendingOpType.taskCreate);
      final row = await db.tasksDao.getById(-1);
      expect(row, isNotNull);
      expect(row!.title, 'neu');
      expect(row.isDirty, isTrue);
      expect(row.remoteId, isNull);
    });

    test('4xx: Rollback (Temp-Zeile weg), kein Enqueue', () async {
      task.addStub = (p, t) => ErrorResponse(400, {}, {'message': 'bad'});

      final res = await writer.addTask(10, _task());

      expect(res.status, OfflineWriteStatus.rejected);
      expect(await ops(), isEmpty);
      expect(await db.tasksDao.getById(-1), isNull);
    });
  });

  // --- Task update -----------------------------------------------------------

  group('updateTask', () {
    test('online-Erfolg: kein Enqueue, dirty gelöscht', () async {
      await seedTask(id: 5, remoteId: 5, title: 'alt');
      task.updateStub = (t) => SuccessResponse(_srvTask(5, title: t.title), 200, {});

      final res = await writer.updateTask(_task(id: 5, title: 'neu'));

      expect(res.status, OfflineWriteStatus.synced);
      expect(await ops(), isEmpty);
      expect((await db.tasksDao.getById(5))!.isDirty, isFalse);
    });

    test('offline: Enqueue + dirty-Zeile mit neuem Titel', () async {
      await seedTask(id: 5, remoteId: 5, title: 'alt');

      final res = await writer.updateTask(_task(id: 5, title: 'neu'));

      expect(res.status, OfflineWriteStatus.queued);
      final queued = await ops();
      expect(queued.single.type, PendingOpType.taskUpdate);
      final row = await db.tasksDao.getById(5);
      expect(row!.title, 'neu');
      expect(row.isDirty, isTrue);
    });

    test('4xx: Rollback auf Server-Stand, kein Enqueue', () async {
      await seedTask(id: 5, remoteId: 5, title: 'alt');
      task.updateStub = (t) => ErrorResponse(400, {}, {'message': 'bad'});

      final res = await writer.updateTask(_task(id: 5, title: 'neu'));

      expect(res.status, OfflineWriteStatus.rejected);
      expect(await ops(), isEmpty);
      expect((await db.tasksDao.getById(5))!.title, 'alt');
    });
  });

  // --- Task delete -----------------------------------------------------------

  group('deleteTask', () {
    test('online-Erfolg: Zeile entfernt, kein Enqueue', () async {
      await seedTask(id: 5, remoteId: 5);
      task.deleteStub = (id) => VoidResponse();

      final res = await writer.deleteTask(5);

      expect(res.status, OfflineWriteStatus.synced);
      expect(await ops(), isEmpty);
      expect(await db.tasksDao.getById(5), isNull);
    });

    test('offline: Tombstone + Enqueue', () async {
      await seedTask(id: 5, remoteId: 5);

      final res = await writer.deleteTask(5);

      expect(res.status, OfflineWriteStatus.queued);
      expect((await ops()).single.type, PendingOpType.taskDelete);
      final row = await db.tasksDao.getById(5);
      expect(row!.isDeleted, isTrue);
      expect(row.isDirty, isTrue);
    });

    test('4xx: Rollback (Tombstone aufgehoben), kein Enqueue', () async {
      await seedTask(id: 5, remoteId: 5);
      task.deleteStub = (id) => ErrorResponse(400, {}, {'message': 'bad'});

      final res = await writer.deleteTask(5);

      expect(res.status, OfflineWriteStatus.rejected);
      expect(await ops(), isEmpty);
      expect((await db.tasksDao.getById(5))!.isDeleted, isFalse);
    });
  });

  // --- Comment create --------------------------------------------------------

  group('addComment', () {
    final author = User(id: 1, username: 'u1', created: _t, updated: _t);

    test('offline: Enqueue + optimistische Temp-Zeile', () async {
      await seedTask(id: 5, remoteId: 5);

      final res = await writer.addComment(5, 'hallo', author);

      expect(res.status, OfflineWriteStatus.queued);
      expect((await ops()).single.type, PendingOpType.commentCreate);
      final rows = await db.taskCommentsDao.watchCommentsByTask(5).first;
      expect(rows, hasLength(1));
      expect(rows.single.id, -1);
      expect(rows.single.isDirty, isTrue);
    });

    test('online-Erfolg: Server-Zeile, kein Enqueue', () async {
      await seedTask(id: 5, remoteId: 5);
      comment.createStub = (t, c) => SuccessResponse(_srvComment(99), 200, {});

      final res = await writer.addComment(5, 'hallo', author);

      expect(res.status, OfflineWriteStatus.synced);
      expect(await ops(), isEmpty);
      final rows = await db.taskCommentsDao.watchCommentsByTask(5).first;
      expect(rows.map((r) => r.id), contains(99));
    });
  });

  // --- setAssignees ----------------------------------------------------------

  group('setAssignees', () {
    final users = [User(id: 7, username: 'a'), User(id: 8, username: 'b')];

    test('offline: Enqueue + dirty-Zuweisungen', () async {
      await seedTask(id: 5, remoteId: 5);

      final res = await writer.setAssignees(5, users);

      expect(res.status, OfflineWriteStatus.queued);
      expect((await ops()).single.type, PendingOpType.taskSetAssignees);
      final rows = await db.taskAssigneesDao.watchAssigneesForTask(5).first;
      expect(rows.map((r) => r.userId).toSet(), {7, 8});
      expect(rows.every((r) => r.isDirty), isTrue);
    });

    test('online-Erfolg: kein Enqueue, dirty gelöscht', () async {
      await seedTask(id: 5, remoteId: 5);
      task.assigneesStub = (id, a) => VoidResponse();

      final res = await writer.setAssignees(5, users);

      expect(res.status, OfflineWriteStatus.synced);
      expect(await ops(), isEmpty);
      final rows = await db.taskAssigneesDao.watchAssigneesForTask(5).first;
      expect(rows.every((r) => !r.isDirty), isTrue);
    });

    test('4xx: Rollback auf vorherige Zuweisungen', () async {
      await seedTask(id: 5, remoteId: 5);
      await db.taskAssigneesDao.upsertFromServer(5, 99); // vorher zugewiesen
      task.assigneesStub = (id, a) => ErrorResponse(400, {}, {'message': 'x'});

      final res = await writer.setAssignees(5, users);

      expect(res.status, OfflineWriteStatus.rejected);
      expect(await ops(), isEmpty);
      final rows = await db.taskAssigneesDao.watchAssigneesForTask(5).first;
      expect(rows.map((r) => r.userId), [99]);
    });
  });

  // --- FIFO: offline anlegen + markAsDone ------------------------------------

  test('Task offline anlegen → markAsDone offline: beide Ops FIFO', () async {
    final add = await writer.addTask(10, _task(title: 'neu'));
    expect(add.status, OfflineWriteStatus.queued);

    // markAsDone auf der Temp-ID (-1) → landet direkt in der Outbox.
    final done = await writer.updateTask(_task(id: -1, title: 'neu', done: true));
    expect(done.status, OfflineWriteStatus.queued);

    final queued = await ops();
    expect(queued.map((o) => o.type), [
      PendingOpType.taskCreate,
      PendingOpType.taskUpdate,
    ]);
    expect(queued.every((o) => o.localId == -1), isTrue);
    expect((await db.tasksDao.getById(-1))!.done, isTrue);
  });

  // --- E2E mit PushProcessor -------------------------------------------------

  test('E2E: offline Task+Kommentar → online → Push in korrekter Reihenfolge',
      () async {
    final author = User(id: 1, username: 'u1', created: _t, updated: _t);

    // Offline anlegen (keine Stubs -> ExceptionResponse).
    await writer.addTask(10, _task(title: 'neu')); // taskCreate localId -1
    await writer.addComment(-1, 'hi', author); // commentCreate localId -2, ref -1

    // Jetzt online: gemeinsamer Log über die Push-Fakes.
    final log = <String>[];
    final pTask = FakeTaskDataSource(log)
      ..addStub = (p, t) => SuccessResponse(_srvTask(42), 200, {});
    final pComment = FakeCommentDataSource(log)
      ..createStub = (tid, c) => SuccessResponse(_srvComment(99), 200, {});
    final processor = buildPushProcessor(db, task: pTask, comment: pComment);

    final result = await processor.pushAll();

    expect(result.success, isTrue);
    // Create-Payload trägt id=0 (nicht die Temp-ID -1), sonst 404 vom Server.
    expect(log, ['add(project=10,id=0)', 'comment.create(task=42)']);
    expect(await ops(), isEmpty);
    expect(await db.tasksDao.getById(42), isNotNull);
  });

  // --- Create-Payload: Temp-ID darf NICHT an den Server (Vikunja: 404) -------

  group('Create-Payload sendet id=0 statt Temp-ID', () {
    test('taskCreate: gesendete DTO-id=0, Migration Temp→Server', () async {
      int? sentId;
      task.addStub = (p, t) {
        sentId = t.id;
        return SuccessResponse(_srvTask(42, title: t.title), 201, {});
      };

      final res = await writer.addTask(10, _task(title: 'neu'));

      expect(res.status, OfflineWriteStatus.synced);
      expect(sentId, 0, reason: 'Temp-ID -1 darf nicht gesendet werden');
      expect(await db.tasksDao.getById(-1), isNull); // Temp umgezogen
      expect(await db.tasksDao.getById(42), isNotNull); // Server-ID
    });

    test('commentCreate: gesendete DTO-id=0, Migration Temp→Server', () async {
      await seedTask(id: 5, remoteId: 5);
      final author = User(id: 1, username: 'u1', created: _t, updated: _t);
      int? sentId;
      comment.createStub = (t, c) {
        sentId = c.id;
        return SuccessResponse(_srvComment(99), 201, {});
      };

      final res = await writer.addComment(5, 'hallo', author);

      expect(res.status, OfflineWriteStatus.synced);
      expect(sentId, 0);
      final rows = await db.taskCommentsDao.watchCommentsByTask(5).first;
      expect(rows.map((r) => r.id), contains(99));
      expect(rows.map((r) => r.id), isNot(contains(-1)));
    });

    test('projectCreate: gesendete DTO-id=0, Migration Temp→Server', () async {
      final projectDs = FakeProjectDataSource();
      int? sentId;
      projectDs.createStub = (p) {
        sentId = p.id;
        return SuccessResponse<ProjectDto>(
          ProjectDto(
            id: 100,
            title: p.title,
            parentProjectId: p.parentProjectId,
            created: _t,
            updated: _t,
          ),
          201,
          const {},
        );
      };
      final projectWriter =
          buildWriter(db, buildExecutor(db, project: projectDs));

      final res = await projectWriter.createProject(
        Project(title: 'Neu', owner: User(id: 1, username: 'u1')),
      );

      expect(res.status, OfflineWriteStatus.synced);
      expect(sentId, 0, reason: 'Temp-ID -1 darf nicht gesendet werden');
      expect(await db.projectsDao.getById(-1), isNull); // Temp umgezogen
      expect(await db.projectsDao.getById(100), isNotNull); // Server-ID
    });
  });
}
