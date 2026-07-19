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
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

final _t = DateTime.utc(2026, 1, 1);

TaskAttachmentDto _dto(int id) => TaskAttachmentDto(
  id: id,
  taskId: 7,
  created: _t,
  createdBy: UserDto(id: 1, username: 'u1', created: _t, updated: _t),
  file: TaskAttachmentFileDto(
    id: id,
    created: _t,
    mime: 'image/png',
    name: 'pic.png',
    size: 3,
  ),
);

class _FakeTaskDataSource implements TaskDataSource {
  Response<List<TaskAttachmentDto>> Function(int taskId, List<String> paths)?
  uploadStub;

  @override
  Future<Response<List<TaskAttachmentDto>>> uploadAttachments(
    int taskId,
    List<String> filePaths,
  ) async => uploadStub!(taskId, filePaths);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _Throwing {
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _FakeComment extends _Throwing implements TaskCommentDataSource {}

class _FakeProject extends _Throwing implements ProjectDataSource {}

class _FakeBucket extends _Throwing implements BucketDataSource {}

class _FakeLabelBulk extends _Throwing implements TaskLabelBulkDataSource {}

class _FakeProjectView extends _Throwing implements ProjectViewDataSource {}

class _FakeUser extends _Throwing implements UserDataSource {}

void main() {
  late AppDatabase db;
  late _FakeTaskDataSource task;
  late List<String> deletedFiles;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    task = _FakeTaskDataSource();
    deletedFiles = [];
  });

  tearDown(() => db.close());

  PushProcessor build() => PushProcessor(
    db: db,
    taskDataSource: task,
    taskCommentDataSource: _FakeComment(),
    projectDataSource: _FakeProject(),
    bucketDataSource: _FakeBucket(),
    taskLabelBulkDataSource: _FakeLabelBulk(),
    projectViewDataSource: _FakeProjectView(),
    userDataSource: _FakeUser(),
    tasksDao: db.tasksDao,
    projectsDao: db.projectsDao,
    bucketsDao: db.bucketsDao,
    taskCommentsDao: db.taskCommentsDao,
    pendingOpsDao: db.pendingOpsDao,
    keyValueDao: db.keyValueDao,
    deleteUploadedFiles: (paths) async => deletedFiles.addAll(paths),
  );

  test('attachmentUpload-Erfolg ersetzt Platzhalter + löscht Kopien', () async {
    // Platzhalter-Zeile (offline angelegt) + Op.
    await db.into(db.taskAttachments).insert(
      TaskAttachmentsCompanion.insert(
        id: const Value(-3),
        taskId: 7,
        fileJson: '{}',
        localFilePath: const Value('/uploads/3/pic.png'),
        rawJson: '{}',
        isDirty: const Value(true),
      ),
    );
    await db.pendingOpsDao.enqueue(
      PendingOp(
        type: PendingOpType.attachmentUpload,
        localId: 7,
        payload: {'task_id': 7},
        localFilePaths: const ['/uploads/3/pic.png'],
        createdAt: '2026-01-01T00:00:00.000Z',
      ).toCompanion(),
    );

    task.uploadStub = (taskId, paths) => SuccessResponse([_dto(99)], 200, {});

    final result = await build().pushAll();

    expect(result.success, isTrue);
    expect(result.pushed, 1);
    // Op entfernt.
    expect(await db.pendingOpsDao.nextBatch(limit: 10), isEmpty);
    // Platzhalter ersetzt durch Server-Anhang.
    final rows = await db.taskAttachmentsDao.watchAttachmentsByTask(7).first;
    expect(rows.length, 1);
    expect(rows.single.remoteId, 99);
    expect(rows.single.localFilePath, isNull);
    // Kopien gelöscht.
    expect(deletedFiles, ['/uploads/3/pic.png']);
  });
}
