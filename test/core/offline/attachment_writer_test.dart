import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/attachment_writer.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/core/offline/outbox.dart';
import 'package:vikunja_app/core/offline/temp_ids.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

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

class _FakeTaskDataSource implements TaskDataSource {
  Response<List<TaskAttachmentDto>> Function(int taskId, List<String> paths)?
  uploadStub;
  Response<Object> Function(int taskId, int attachmentId)? deleteStub;
  int uploadCalls = 0;

  @override
  Future<Response<List<TaskAttachmentDto>>> uploadAttachments(
    int taskId,
    List<String> filePaths,
  ) async {
    uploadCalls++;
    return uploadStub!(taskId, filePaths);
  }

  @override
  Future<Response<Object>> deleteAttachment(int taskId, int attachmentId) async {
    return deleteStub!(taskId, attachmentId);
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

void main() {
  late AppDatabase db;
  late Directory supportDir;
  late Directory srcDir;
  late LocalFileStorage storage;
  late Outbox outbox;
  late _FakeTaskDataSource dataSource;
  late AttachmentWriter writer;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    supportDir = await Directory.systemTemp.createTemp('aw_support');
    srcDir = await Directory.systemTemp.createTemp('aw_src');
    storage = LocalFileStorage(supportDirectory: () async => supportDir);
    outbox = Outbox(
      pendingOpsDao: db.pendingOpsDao,
      tempIds: TempIdAllocator(db: db, keyValueDao: db.keyValueDao),
    );
    dataSource = _FakeTaskDataSource();
    writer = AttachmentWriter(
      db: db,
      dataSource: dataSource,
      outbox: outbox,
      attachmentsDao: db.taskAttachmentsDao,
      storage: storage,
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

  test('online Erfolg: schreibt DB-Anhang, löscht Kopien, kein Op', () async {
    final path = await makeSourceFile('pic.png');
    dataSource.uploadStub = (taskId, paths) =>
        SuccessResponse([_dto(99, 'pic.png')], 200, {});

    final result = await writer.uploadAttachments(7, [path]);

    expect(result, isA<AttachmentUploaded>());
    final rows = await db.taskAttachmentsDao.watchAttachmentsByTask(7).first;
    expect(rows.length, 1);
    expect(rows.first.remoteId, 99);
    // Op-Queue leer, pending_uploads aufgeräumt.
    expect(await db.pendingOpsDao.nextBatch(limit: 10), isEmpty);
    final uploadsDir = Directory('${supportDir.path}/pending_uploads');
    if (await uploadsDir.exists()) {
      expect(await uploadsDir.list().toList(), isEmpty);
    }
  });

  test('offline: enqueued Op, Platzhalter-Zeile, Kopie überlebt', () async {
    final path = await makeSourceFile('pic.png');
    dataSource.uploadStub = (taskId, paths) =>
        ExceptionResponse(Exception('offline'), StackTrace.empty);

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
    dataSource.uploadStub = (taskId, paths) =>
        ErrorResponse(400, {}, {'message': 'bad'});

    final result = await writer.uploadAttachments(7, [path]);

    expect(result, isA<AttachmentFailed>());
    expect((result as AttachmentFailed).statusCode, 400);
    expect(await db.pendingOpsDao.nextBatch(limit: 10), isEmpty);
    expect(await db.taskAttachmentsDao.watchAttachmentsByTask(7).first, isEmpty);
    final uploadsDir = Directory('${supportDir.path}/pending_uploads');
    if (await uploadsDir.exists()) {
      expect(await uploadsDir.list().toList(), isEmpty);
    }
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
    dataSource.deleteStub = (taskId, attId) =>
        ExceptionResponse(Exception('offline'), StackTrace.empty);

    final result = await writer.deleteAttachment(7, 5);

    expect(result, isA<AttachmentDeleted>());
    final ops = await db.pendingOpsDao.nextBatch(limit: 10);
    expect(ops.single.opType, 'attachmentDelete');
    // Tombstone: watch (filtert isDeleted) liefert nichts mehr.
    expect(await db.taskAttachmentsDao.watchAttachmentsByTask(7).first, isEmpty);
  });

  test('delete Platzhalter (negative ID): Zeile + Kopie entfernt', () async {
    final path = await makeSourceFile('pic.png');
    dataSource.uploadStub = (taskId, paths) =>
        ExceptionResponse(Exception('offline'), StackTrace.empty);
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
}
