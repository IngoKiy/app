import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

import 'offline_test_fakes.dart';

final _t = DateTime.utc(2026, 1, 1);

TaskAttachmentDto _dto(int id, String name) => TaskAttachmentDto(
  id: id,
  taskId: 7,
  created: _t,
  createdBy: UserDto(id: 1, username: 'u1', created: _t, updated: _t),
  file: TaskAttachmentFileDto(
    id: id,
    created: _t,
    mime: 'image/png',
    name: name,
    size: 3,
  ),
);

void main() {
  late AppDatabase db;
  late Directory supportDir;
  late Directory srcDir;
  late FakeTaskDataSource task;
  late OfflineWriter writer;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    supportDir = await Directory.systemTemp.createTemp('aw_support');
    srcDir = await Directory.systemTemp.createTemp('aw_src');
    task = FakeTaskDataSource();
    writer = buildWriter(
      db,
      buildExecutor(db, task: task),
      storage: LocalFileStorage(supportDirectory: () async => supportDir),
    );
  });

  tearDown(() async {
    await db.close();
    for (final d in [supportDir, srcDir]) {
      if (await d.exists()) await d.delete(recursive: true);
    }
  });

  Future<String> makeSourceFile(String name) async {
    final f = File('${srcDir.path}/$name');
    await f.writeAsBytes([1, 2, 3]);
    return f.path;
  }

  Future<void> expectUploadsDirEmpty() async {
    final uploadsDir = Directory('${supportDir.path}/pending_uploads');
    if (await uploadsDir.exists()) {
      expect(await uploadsDir.list().toList(), isEmpty);
    }
  }

  test('online Erfolg: schreibt DB-Anhang, löscht Kopien, kein Op', () async {
    final path = await makeSourceFile('pic.png');
    task.uploadAttachmentsStub = (taskId, paths) =>
        SuccessResponse([_dto(99, 'pic.png')], 200, {});

    final result = await writer.uploadAttachments(7, [path]);

    expect(result, isA<AttachmentUploaded>());
    final rows = await db.taskAttachmentsDao.watchAttachmentsByTask(7).first;
    expect(rows.length, 1);
    expect(rows.first.remoteId, 99);
    // Op-Queue leer, pending_uploads aufgeräumt.
    expect(await db.pendingOpsDao.nextBatch(limit: 10), isEmpty);
    await expectUploadsDirEmpty();
  });

  test('offline: enqueued Op, Platzhalter-Zeile, Kopie überlebt', () async {
    final path = await makeSourceFile('pic.png');
    // Kein Stub → FakeTaskDataSource antwortet mit ExceptionResponse (offline).

    final result = await writer.uploadAttachments(7, [path]);

    expect(result, isA<AttachmentQueued>());
    final placeholders = (result as AttachmentQueued).placeholders;
    expect(placeholders.single.localFilePath, isNotNull);
    expect(placeholders.single.id, lessThan(0));
    // Kopie existiert und ist NICHT die Picker-Quelle.
    final copy = placeholders.single.localFilePath!;
    expect(await File(copy).exists(), isTrue);
    expect(copy, isNot(path));

    // Op enqueued mit localFilePaths.
    final ops = await db.pendingOpsDao.nextBatch(limit: 10);
    expect(ops.length, 1);
    expect(ops.first.opType, 'attachmentUpload');
    final paths =
        (jsonDecode(ops.first.localFilePathsJson!) as List).cast<String>();
    expect(paths, [copy]);

    // Platzhalter-Zeile in der DB.
    final rows = await db.taskAttachmentsDao.watchAttachmentsByTask(7).first;
    expect(rows.single.localFilePath, copy);
    expect(rows.single.id, lessThan(0));
  });

  test('4xx: Rollback — kein Op, keine Zeile, Kopie weg', () async {
    final path = await makeSourceFile('pic.png');
    task.uploadAttachmentsStub = (taskId, paths) =>
        ErrorResponse(400, {}, {'message': 'bad'});

    final result = await writer.uploadAttachments(7, [path]);

    expect(result, isA<AttachmentFailed>());
    expect((result as AttachmentFailed).statusCode, 400);
    expect(await db.pendingOpsDao.nextBatch(limit: 10), isEmpty);
    expect(await db.taskAttachmentsDao.watchAttachmentsByTask(7).first, isEmpty);
    await expectUploadsDirEmpty();
    // Quelle bleibt unberührt.
    expect(await File(path).exists(), isTrue);
  });

  test('delete offline: Op enqueued + Zeile als Tombstone', () async {
    await db.into(db.taskAttachments).insert(
      TaskAttachmentsCompanion.insert(
        id: const Value(5),
        taskId: 7,
        fileJson: '{}',
        rawJson: '{}',
        remoteId: const Value(5),
      ),
    );
    // Kein Stub → offline.

    final result = await writer.deleteAttachment(7, 5);

    expect(result, isA<AttachmentDeleted>());
    final ops = await db.pendingOpsDao.nextBatch(limit: 10);
    expect(ops.single.opType, 'attachmentDelete');
    // Tombstone: watch (filtert isDeleted) liefert nichts mehr.
    expect(await db.taskAttachmentsDao.watchAttachmentsByTask(7).first, isEmpty);
  });

  test('delete online: Zeile entfernt, kein Op', () async {
    await db.into(db.taskAttachments).insert(
      TaskAttachmentsCompanion.insert(
        id: const Value(5),
        taskId: 7,
        fileJson: '{}',
        rawJson: '{}',
        remoteId: const Value(5),
      ),
    );
    task.deleteAttachmentStub = (taskId, attId) => VoidResponse();

    final result = await writer.deleteAttachment(7, 5);

    expect(result, isA<AttachmentDeleted>());
    expect(await db.pendingOpsDao.nextBatch(limit: 10), isEmpty);
    final rows = await (db.select(db.taskAttachments)).get();
    expect(rows, isEmpty);
  });

  test('delete Platzhalter (negative ID): Zeile + Kopie entfernt', () async {
    final path = await makeSourceFile('pic.png');
    final queued =
        (await writer.uploadAttachments(7, [path])) as AttachmentQueued;
    final placeholder = queued.placeholders.single;

    final result = await writer.deleteAttachment(
      7,
      placeholder.id,
      localFilePath: placeholder.localFilePath,
    );

    expect(result, isA<AttachmentDeleted>());
    expect(await db.taskAttachmentsDao.watchAttachmentsByTask(7).first, isEmpty);
    expect(await File(placeholder.localFilePath!).exists(), isFalse);
  });

  test('registerDownloadedFile + attachmentLocalFilePath', () async {
    await writer.registerDownloadedFile(7, _dto(99, 'doc.pdf'), '/dl/doc.pdf');

    expect(await writer.attachmentLocalFilePath(99), '/dl/doc.pdf');
    final rows = await db.taskAttachmentsDao.watchAttachmentsByTask(7).first;
    expect(rows.single.remoteId, 99);
  });
}
