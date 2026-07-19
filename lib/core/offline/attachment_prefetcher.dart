import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vikunja_app/core/offline/attachment_mapping.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';

/// Lädt Anhänge synchronisierter Tasks automatisch auf das Gerät, damit sie
/// offline verfügbar sind. Läuft nach jedem erfolgreichen Pull (Hook
/// `SyncService.onPullCompleted`).
///
/// Quelle der Wahrheit ist das `rawJson` der synchronisierten Tasks (enthält die
/// Anhangsliste). Der Prefetcher spiegelt daraus die `task_attachments`-Zeilen,
/// lädt fehlende Dateien (≤ [maxFileBytes]) sequenziell über HTTP mit
/// Auth-Headern nach `<ApplicationSupport>/attachments/<remoteId>_<name>` und
/// merkt sich den Pfad in `localFilePath`. Fehler (offline/Server) werden still
/// toleriert — der nächste Sync versucht es erneut. Verwaiste Dateien (kein
/// DB-Eintrag mehr) werden entfernt.
class AttachmentPrefetcher {
  AttachmentPrefetcher({
    required AppDatabase db,
    required TaskDataSource taskDataSource,
    required LocalFileStorage storage,
    http.Client? client,
    this.maxFileBytes = 15 * 1024 * 1024,
  }) : _db = db,
       _taskDataSource = taskDataSource,
       _storage = storage,
       _client = client ?? http.Client();

  final AppDatabase _db;
  final TaskDataSource _taskDataSource;
  final LocalFileStorage _storage;
  final http.Client _client;

  /// Größenlimit pro Datei (Standard 15 MB). Größere Anhänge werden übersprungen.
  final int maxFileBytes;

  String get _nowIso => DateTime.now().toUtc().toIso8601String();

  Future<void> run() async {
    final dir = await _storage.attachmentsDir();

    // Nur synchronisierte Tasks (remoteId gesetzt) haben serverseitige Anhänge.
    final taskRows = await (_db.select(
      _db.tasks,
    )..where((t) => t.remoteId.isNotNull())).get();

    for (final task in taskRows) {
      final attachments = _attachmentsOf(task.rawJson);
      for (final attachment in attachments) {
        await _mirrorAndPrefetch(dir, task.id, attachment);
      }
      // Serverseitig verschwundene Anhänge (clean) lokal entfernen.
      await _db.taskAttachmentsDao.deleteMissingCleanForTask(
        task.id,
        attachments.map((a) => a.id),
      );
    }

    await _cleanupOrphanFiles(dir);
  }

  /// Spiegelt eine Anhang-Zeile und lädt bei Bedarf die Datei herunter.
  Future<void> _mirrorAndPrefetch(
    Directory dir,
    int taskId,
    TaskAttachmentDto attachment,
  ) async {
    final existing = await (_db.select(
      _db.taskAttachments,
    )..where((a) => a.remoteId.equals(attachment.id))).getSingleOrNull();
    // Lokale, noch nicht gepushte Änderung nicht anfassen.
    if (existing != null && existing.isDirty) return;

    var localPath = existing?.localFilePath;
    final present = localPath != null && await File(localPath).exists();
    if (!present && attachment.file.size <= maxFileBytes) {
      localPath = await _download(dir, taskId, attachment) ?? localPath;
    }

    await _db.taskAttachmentsDao.upsertFromServer(
      attachmentCompanionFromDto(
        attachment,
        taskId: taskId,
        syncedAt: _nowIso,
        localFilePath: localPath,
      ),
    );
  }

  /// Lädt eine Datei herunter; liefert den Zielpfad oder `null` bei Fehler.
  Future<String?> _download(
    Directory dir,
    int taskId,
    TaskAttachmentDto attachment,
  ) async {
    try {
      final headers = await _taskDataSource.authHeaders();
      final url = _taskDataSource.attachmentUrl(taskId, attachment.id);
      final resp = await _client.get(Uri.parse(url), headers: headers);
      if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
      await dir.create(recursive: true);
      final dest = File('${dir.path}/${attachment.id}_${_sanitize(attachment.file.name)}');
      await dest.writeAsBytes(resp.bodyBytes, flush: true);
      return dest.path;
    } catch (_) {
      // offline / Serverfehler → still tolerieren, nächster Sync erneut.
      return null;
    }
  }

  /// Entfernt Dateien im Anhang-Verzeichnis, auf die keine DB-Zeile mehr zeigt.
  Future<void> _cleanupOrphanFiles(Directory dir) async {
    if (!await dir.exists()) return;
    final rows = await _db.select(_db.taskAttachments).get();
    final keep = rows
        .map((r) => r.localFilePath)
        .whereType<String>()
        .toSet();
    await for (final entity in dir.list()) {
      if (entity is File && !keep.contains(entity.path)) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }

  /// Liest die Anhangsliste aus dem `rawJson` eines Tasks (fehlertolerant, pro
  /// Eintrag: ein defekter Anhang verwirft nicht die ganze Liste).
  List<TaskAttachmentDto> _attachmentsOf(String rawJson) {
    final List<dynamic> raw;
    try {
      final map = (jsonDecode(rawJson) as Map).cast<String, dynamic>();
      final value = map['attachments'];
      if (value is! List) return const [];
      raw = value;
    } catch (_) {
      return const [];
    }
    final result = <TaskAttachmentDto>[];
    for (final entry in raw) {
      try {
        result.add(
          TaskAttachmentDto.fromJSON((entry as Map).cast<String, dynamic>()),
        );
      } catch (_) {}
    }
    return result;
  }

  /// Ersetzt Pfadtrenner im Dateinamen, damit der Zielpfad flach bleibt.
  String _sanitize(String name) => name.replaceAll(RegExp(r'[/\\]'), '_');
}
