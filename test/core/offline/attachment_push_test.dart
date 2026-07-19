import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

import 'offline_test_fakes.dart';

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

void main() {
  late AppDatabase db;
  late FakeTaskDataSource task;
  late List<String> deletedFiles;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    task = FakeTaskDataSource();
    deletedFiles = [];
  });

  tearDown(() => db.close());

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

    task.uploadAttachmentsStub = (taskId, paths) =>
        SuccessResponse([_dto(99)], 200, {});

    final processor = buildPushProcessor(
      db,
      task: task,
      deleteUploadedFiles: (paths) async => deletedFiles.addAll(paths),
    );
    final result = await processor.pushAll();

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

  test('attachmentDelete-Erfolg entfernt die Tombstone-Zeile', () async {
    await db.into(db.taskAttachments).insert(
      TaskAttachmentsCompanion.insert(
        id: const Value(5),
        taskId: 7,
        fileJson: '{}',
        rawJson: '{}',
        remoteId: const Value(5),
        isDeleted: const Value(true),
      ),
    );
    await db.pendingOpsDao.enqueue(
      PendingOp(
        type: PendingOpType.attachmentDelete,
        localId: 7,
        payload: {'task_id': 7, 'attachment_id': 5},
        createdAt: '2026-01-01T00:00:00.000Z',
      ).toCompanion(),
    );
    task.deleteAttachmentStub = (taskId, attId) => VoidResponse();

    final result = await buildPushProcessor(db, task: task).pushAll();

    expect(result.success, isTrue);
    expect(await (db.select(db.taskAttachments)).get(), isEmpty);
  });
}
