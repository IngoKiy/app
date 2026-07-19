import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/attachment_mapping.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/core/offline/outbox.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/local/dao/task_attachments_dao.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/domain/entities/task_attachment.dart';
import 'package:vikunja_app/domain/entities/user.dart';

/// Ergebnis eines Anhang-Schreibvorgangs für die UI.
sealed class AttachmentWriteResult {
  const AttachmentWriteResult();
}

/// Online erfolgreich hochgeladen; [attachments] sind die Server-Anhänge.
class AttachmentUploaded extends AttachmentWriteResult {
  const AttachmentUploaded(this.attachments);
  final List<TaskAttachment> attachments;
}

/// Offline zwischengespeichert; [placeholders] tragen `localFilePath` und
/// werden in der Section sofort (FileImage) angezeigt.
class AttachmentQueued extends AttachmentWriteResult {
  const AttachmentQueued(this.placeholders);
  final List<TaskAttachment> placeholders;
}

/// Server hat abgelehnt (4xx/5xx) — nichts wurde übernommen.
class AttachmentFailed extends AttachmentWriteResult {
  const AttachmentFailed(this.statusCode);
  final int? statusCode;
}

class AttachmentDeleted extends AttachmentWriteResult {
  const AttachmentDeleted();
}

/// Schreibende Fassade für Anhänge im Local-First-Ansatz.
///
/// Upload: Dateien werden SOFORT nach `<ApplicationSupport>/pending_uploads/`
/// kopiert (Picker-Tempdateien überleben nicht). Danach online versucht; bei
/// Erfolg werden die Server-Anhänge in die DB geschrieben und die Kopien
/// gelöscht, bei 4xx/5xx die Kopien verworfen (Rollback), offline eine
/// `attachmentUpload`-Op enqueued und eine Platzhalter-Zeile angelegt.
class AttachmentWriter {
  AttachmentWriter({
    required AppDatabase db,
    required TaskDataSource dataSource,
    required Outbox outbox,
    required TaskAttachmentsDao attachmentsDao,
    required LocalFileStorage storage,
  }) : _db = db,
       _dataSource = dataSource,
       _outbox = outbox,
       _attachmentsDao = attachmentsDao,
       _storage = storage;

  final AppDatabase _db;
  final TaskDataSource _dataSource;
  final Outbox _outbox;
  final TaskAttachmentsDao _attachmentsDao;
  final LocalFileStorage _storage;

  Future<AttachmentWriteResult> uploadAttachments(
    int taskId,
    List<String> paths, {
    User? uploadedBy,
  }) async {
    if (paths.isEmpty) return const AttachmentUploaded([]);

    // 1. Dateien in einen op-eigenen Ordner kopieren (überleben den Picker).
    final key = await _outbox.nextTempId();
    final dir = await _storage.pendingUploadDir(key.abs().toString());
    await dir.create(recursive: true);
    final copied = <String>[];
    for (final path in paths) {
      final dest = '${dir.path}/${_basename(path)}';
      await File(path).copy(dest);
      copied.add(dest);
    }

    final now = DateTime.now();
    // 2. Online versuchen (nur für bereits synchronisierte Aufgaben).
    if (taskId > 0) {
      final resp = await _dataSource.uploadAttachments(taskId, copied);
      switch (resp) {
        case SuccessResponse<List<TaskAttachmentDto>>():
          await _persistServerAttachments(taskId, resp.body, now);
          await _deleteDirQuietly(dir);
          return AttachmentUploaded(
            resp.body.map((e) => e.toDomain()).toList(),
          );
        case ErrorResponse():
          await _deleteDirQuietly(dir); // Rollback: keine Kopie behalten.
          return AttachmentFailed(resp.statusCode);
        case ExceptionResponse():
          break; // offline → unten enqueuen
      }
    }

    // 3. Offline: Op enqueuen + Platzhalter-Zeilen mit localFilePath.
    await _outbox.enqueue(
      PendingOp(
        type: PendingOpType.attachmentUpload,
        localId: taskId,
        payload: {'task_id': taskId},
        tempIdRefs: taskId < 0 ? {'taskId': taskId} : const {},
        localFilePaths: copied,
        createdAt: now.toUtc().toIso8601String(),
      ),
    );

    final placeholders = <TaskAttachment>[];
    for (final path in copied) {
      final id = await _outbox.nextTempId();
      final name = _basename(path);
      final size = await File(path).length();
      final file = TaskAttachmentFile(
        id: id,
        created: now,
        mime: _guessMime(name),
        name: name,
        size: size,
      );
      await _attachmentsDao.upsertLocal(
        TaskAttachmentsCompanion.insert(
          id: Value(id),
          taskId: taskId,
          fileJson: jsonEncode(_fileJson(file)),
          localFilePath: Value(path),
          rawJson: '{}',
        ),
      );
      placeholders.add(
        TaskAttachment(
          id: id,
          taskId: taskId,
          created: now,
          createdBy: uploadedBy ?? User(username: ''),
          file: file,
          localFilePath: path,
        ),
      );
    }
    return AttachmentQueued(placeholders);
  }

  Future<AttachmentWriteResult> deleteAttachment(
    int taskId,
    int attachmentId, {
    String? localFilePath,
  }) async {
    // Noch nicht synchronisierter Platzhalter (negative ID): Zeile + Kopie weg.
    if (attachmentId < 0) {
      final row =
          await (_db.select(
            _db.taskAttachments,
          )..where((a) => a.id.equals(attachmentId))).getSingleOrNull();
      await (_db.delete(
        _db.taskAttachments,
      )..where((a) => a.id.equals(attachmentId))).go();
      final path = localFilePath ?? row?.localFilePath;
      if (path != null) await _storage.deleteFileQuietly(path);
      return const AttachmentDeleted();
    }

    if (taskId > 0) {
      final resp = await _dataSource.deleteAttachment(taskId, attachmentId);
      switch (resp) {
        case ErrorResponse():
          return AttachmentFailed(resp.statusCode);
        case ExceptionResponse():
          break; // offline → unten enqueuen
        default:
          await _removeLocal(attachmentId);
          return const AttachmentDeleted();
      }
    }

    // Offline: Op enqueuen, Zeile als Tombstone markieren.
    await _outbox.enqueue(
      PendingOp(
        type: PendingOpType.attachmentDelete,
        localId: taskId,
        payload: {'task_id': taskId, 'attachment_id': attachmentId},
        tempIdRefs: taskId < 0 ? {'taskId': taskId} : const {},
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await (_db.update(_db.taskAttachments)
          ..where((a) => a.remoteId.equals(attachmentId)))
        .write(const TaskAttachmentsCompanion(isDeleted: Value(true)));
    return const AttachmentDeleted();
  }

  /// Merkt sich den Pfad einer heruntergeladenen Datei am Anhang (für „Öffnen"
  /// offline). Legt bei Bedarf eine Zeile an.
  Future<void> registerDownloadedFile(
    int taskId,
    TaskAttachmentDto attachment,
    String path,
  ) async {
    await _attachmentsDao.upsertFromServer(
      attachmentCompanionFromDto(
        attachment,
        taskId: taskId,
        syncedAt: DateTime.now().toUtc().toIso8601String(),
        localFilePath: path,
      ),
    );
  }

  /// Lokaler Pfad eines Anhangs, falls heruntergeladen/zwischengespeichert.
  Future<String?> localFilePathFor(int attachmentId) async {
    final row =
        await (_db.select(_db.taskAttachments)..where(
              (a) =>
                  a.id.equals(attachmentId) | a.remoteId.equals(attachmentId),
            ))
            .getSingleOrNull();
    return row?.localFilePath;
  }

  Future<void> _persistServerAttachments(
    int taskId,
    List<TaskAttachmentDto> dtos,
    DateTime now,
  ) async {
    final syncedAt = now.toUtc().toIso8601String();
    for (final dto in dtos) {
      await _attachmentsDao.upsertFromServer(
        attachmentCompanionFromDto(dto, taskId: taskId, syncedAt: syncedAt),
      );
    }
  }

  Future<void> _removeLocal(int attachmentId) => (_db.delete(
    _db.taskAttachments,
  )..where((a) => a.remoteId.equals(attachmentId))).go();

  Future<void> _deleteDirQuietly(Directory dir) async {
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  Map<String, Object> _fileJson(TaskAttachmentFile file) => {
    'id': file.id,
    'created': file.created.toUtc().toIso8601String(),
    'mime': file.mime,
    'name': file.name,
    'size': file.size,
  };

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx < 0 ? normalized : normalized.substring(idx + 1);
  }

  String _guessMime(String name) {
    final dot = name.lastIndexOf('.');
    final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'bmp':
        return 'image/bmp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
