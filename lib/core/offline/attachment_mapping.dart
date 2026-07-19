import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';

/// Baut aus einer Server-Anhang-DTO die `task_attachments`-Companion für das
/// lokale Upsert (`upsertFromServer`). `remoteId` = Server-ID, `localFilePath`
/// bleibt frei (wird beim Download gesetzt).
TaskAttachmentsCompanion attachmentCompanionFromDto(
  TaskAttachmentDto dto, {
  required int taskId,
  required String syncedAt,
  String? localFilePath,
}) {
  return TaskAttachmentsCompanion.insert(
    id: Value(dto.id),
    taskId: taskId,
    fileJson: jsonEncode(dto.file.toJSON()),
    localFilePath: Value(localFilePath),
    rawJson: jsonEncode(dto.toJSON()),
    remoteId: Value(dto.id),
    syncedAt: Value(syncedAt),
  );
}
