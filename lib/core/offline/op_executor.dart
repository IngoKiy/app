import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/attachment_mapping.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/models/task_attachment_dto.dart';
import 'package:vikunja_app/data/data_sources/bucket_data_source.dart';
import 'package:vikunja_app/data/data_sources/label_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_view_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_comment_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_label_bulk_data_source.dart';
import 'package:vikunja_app/data/data_sources/user_data_source.dart';
import 'package:vikunja_app/data/local/dao/buckets_dao.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
import 'package:vikunja_app/data/local/dao/labels_dao.dart';
import 'package:vikunja_app/data/local/dao/pending_ops_dao.dart';
import 'package:vikunja_app/data/local/dao/projects_dao.dart';
import 'package:vikunja_app/data/local/dao/task_comments_dao.dart';
import 'package:vikunja_app/data/local/dao/tasks_dao.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/bucket_dto.dart';
import 'package:vikunja_app/data/models/label_dto.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/project_view_dto.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

/// KeyValue-Schlüssel der persistierten Temp-ID→Server-ID-Zuordnung. Wird nach
/// jedem erfolgreichen Create geschrieben, damit ein Neustart des Processors
/// (Crash-Sicherheit) das Mapping wiederfindet.
const String kvTempIdMapping = 'temp_id_mapping';

/// Wiederverwendbarer Kern für das Anwenden einer [PendingOp]: das Senden an
/// die passende Data-Source ([dispatch]) sowie die Erfolgsbehandlung
/// (Temp-ID-Migration bei Create, dirty-Bereinigung + Server-Upsert bei
/// Update/Delete).
///
/// Sowohl der [PushProcessor] (Outbox abarbeiten) als auch der [OfflineWriter]
/// (optimistisch schreiben mit Online-Versuch) benutzen dieselbe Instanz, damit
/// die Migrations-/Merge-Logik nur an EINER Stelle existiert.
class OpExecutor {
  OpExecutor({
    required AppDatabase db,
    required TaskDataSource taskDataSource,
    required TaskCommentDataSource taskCommentDataSource,
    required ProjectDataSource projectDataSource,
    required BucketDataSource bucketDataSource,
    required TaskLabelBulkDataSource taskLabelBulkDataSource,
    required LabelDataSource labelDataSource,
    required ProjectViewDataSource projectViewDataSource,
    required UserDataSource userDataSource,
    required TasksDao tasksDao,
    required ProjectsDao projectsDao,
    required BucketsDao bucketsDao,
    required LabelsDao labelsDao,
    required TaskCommentsDao taskCommentsDao,
    required PendingOpsDao pendingOpsDao,
    required KeyValueDao keyValueDao,
    DtoCompanionMapper mapper = const DtoCompanionMapper(),
    Future<void> Function(List<String> paths)? deleteUploadedFiles,
  }) : _deleteUploadedFiles = deleteUploadedFiles ?? _defaultDeleteFiles,
       _db = db,
       _taskDataSource = taskDataSource,
       _taskCommentDataSource = taskCommentDataSource,
       _projectDataSource = projectDataSource,
       _bucketDataSource = bucketDataSource,
       _taskLabelBulkDataSource = taskLabelBulkDataSource,
       _labelDataSource = labelDataSource,
       _projectViewDataSource = projectViewDataSource,
       _userDataSource = userDataSource,
       _tasksDao = tasksDao,
       _projectsDao = projectsDao,
       _bucketsDao = bucketsDao,
       _labelsDao = labelsDao,
       _taskCommentsDao = taskCommentsDao,
       _pendingOpsDao = pendingOpsDao,
       _keyValueDao = keyValueDao,
       _mapper = mapper;

  final AppDatabase _db;
  final TaskDataSource _taskDataSource;
  final TaskCommentDataSource _taskCommentDataSource;
  final ProjectDataSource _projectDataSource;
  final BucketDataSource _bucketDataSource;
  final TaskLabelBulkDataSource _taskLabelBulkDataSource;
  final LabelDataSource _labelDataSource;
  final ProjectViewDataSource _projectViewDataSource;
  final UserDataSource _userDataSource;

  final TasksDao _tasksDao;
  final ProjectsDao _projectsDao;
  final BucketsDao _bucketsDao;
  final LabelsDao _labelsDao;
  final TaskCommentsDao _taskCommentsDao;
  final PendingOpsDao _pendingOpsDao;
  final KeyValueDao _keyValueDao;
  final DtoCompanionMapper _mapper;

  /// Löscht die kopierten Upload-Dateien nach erfolgreichem attachmentUpload
  /// (injizierbar für Tests). Standard: Dateien + leeren Elternordner entfernen.
  final Future<void> Function(List<String> paths) _deleteUploadedFiles;

  static Future<void> _defaultDeleteFiles(List<String> paths) async {
    final parents = <String>{};
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
        parents.add(file.parent.path);
      } catch (_) {}
    }
    for (final p in parents) {
      try {
        final dir = Directory(p);
        if (await dir.exists() && await dir.list().isEmpty) {
          await dir.delete();
        }
      } catch (_) {}
    }
  }

  /// Sicherheitsnetz gegen fehlerhafte Zustände (Ops-Zahl ist ohnehin klein).
  static const int _maxOps = 100000;

  // --- Dispatch --------------------------------------------------------------

  /// Sendet eine Op an die passende Data-Source. [refs] enthält aufgelöste
  /// Temp-Referenzen (Server-IDs), [primaryId] die aufgelöste ID der primären
  /// Entität (bei Update/Delete).
  Future<Response<dynamic>> dispatch(
    PendingOp op,
    Map<String, int> refs,
    int? primaryId,
  ) {
    switch (op.type) {
      case PendingOpType.taskCreate:
        final projectId =
            refs['projectId'] ?? (op.payload['project_id'] as num).toInt();
        return _taskDataSource.add(
          projectId,
          _taskDto(_createPayload(op.payload), refs),
        );
      case PendingOpType.taskUpdate:
        final payload = _resolveTaskPayload(op.payload, refs)
          ..['id'] = primaryId;
        return _taskDataSource.update(TaskDto.fromJson(payload));
      case PendingOpType.taskDelete:
        return _taskDataSource.delete(primaryId!);
      case PendingOpType.taskSetAssignees:
        final assignees = _userList(op.payload['assignees']);
        return _taskDataSource.setAssignees(primaryId!, assignees);
      case PendingOpType.taskLabelBulk:
        final labels = _labelList(op.payload['labels']);
        final task = TaskDto(
          id: primaryId!,
          createdBy: null,
          projectId: null,
        );
        return _taskLabelBulkDataSource.update(task, labels);
      case PendingOpType.labelCreate:
        return _labelDataSource.create(
          LabelDto.fromJson(_createPayload(op.payload)),
        );
      case PendingOpType.commentCreate:
        final taskId =
            refs['taskId'] ?? (op.payload['task_id'] as num).toInt();
        return _taskCommentDataSource.create(
          taskId,
          TaskCommentDto.fromJson(_createPayload(op.payload)),
        );
      case PendingOpType.commentUpdate:
        final taskId =
            refs['taskId'] ?? (op.payload['task_id'] as num).toInt();
        final payload = Map<String, dynamic>.of(op.payload)..['id'] = primaryId;
        return _taskCommentDataSource.update(
          taskId,
          TaskCommentDto.fromJson(payload),
        );
      case PendingOpType.commentDelete:
        final taskId =
            refs['taskId'] ?? (op.payload['task_id'] as num).toInt();
        return _taskCommentDataSource.delete(taskId, primaryId!);
      case PendingOpType.projectCreate:
        return _projectDataSource.create(
          ProjectDto.fromJson(_createPayload(op.payload)),
        );
      case PendingOpType.projectUpdate:
        final payload = Map<String, dynamic>.of(op.payload)..['id'] = primaryId;
        return _projectDataSource.update(ProjectDto.fromJson(payload));
      case PendingOpType.bucketCreate:
        final projectId =
            refs['projectId'] ?? (op.payload['project_id'] as num).toInt();
        final viewId =
            refs['viewId'] ?? (op.payload['view_id'] as num).toInt();
        return _bucketDataSource.add(
          projectId,
          viewId,
          BucketDto.fromJSON(_createPayload(op.payload)),
        );
      case PendingOpType.bucketUpdate:
        final projectId =
            refs['projectId'] ?? (op.payload['project_id'] as num).toInt();
        final viewId =
            refs['viewId'] ?? (op.payload['view_id'] as num).toInt();
        final payload = Map<String, dynamic>.of(op.payload)..['id'] = primaryId;
        return _bucketDataSource.update(
          projectId,
          viewId,
          BucketDto.fromJSON(payload),
        );
      case PendingOpType.bucketDelete:
        final projectId =
            refs['projectId'] ?? (op.payload['project_id'] as num).toInt();
        final viewId =
            refs['viewId'] ?? (op.payload['view_id'] as num).toInt();
        return _bucketDataSource.delete(projectId, viewId, primaryId!);
      case PendingOpType.taskMoveBucket:
        final taskId = refs['taskId'] ?? primaryId!;
        final bucketId =
            refs['bucketId'] ?? (op.payload['bucket_id'] as num).toInt();
        final projectId =
            refs['projectId'] ?? (op.payload['project_id'] as num).toInt();
        final viewId = (op.payload['view_id'] as num).toInt();
        return _bucketDataSource.updateTaskBucket(
          taskId,
          bucketId,
          projectId,
          viewId,
        );
      case PendingOpType.taskPosition:
        final taskId = refs['taskId'] ?? primaryId!;
        final viewId = (op.payload['view_id'] as num).toInt();
        final position = (op.payload['position'] as num).toDouble();
        return _bucketDataSource.updateTaskPosition(taskId, viewId, position);
      case PendingOpType.projectViewUpdate:
        return _projectViewDataSource.update(
          ProjectViewDto.fromJson(op.payload),
        );
      case PendingOpType.userSettings:
        return _userDataSource.setCurrentUserSettings(
          UserSettingsDto.fromJson(op.payload),
        );
      case PendingOpType.attachmentUpload:
        final taskId = refs['taskId'] ?? primaryId!;
        return _taskDataSource.uploadAttachments(
          taskId,
          op.localFilePaths ?? const [],
        );
      case PendingOpType.attachmentDelete:
        final taskId =
            refs['taskId'] ?? (op.payload['task_id'] as num).toInt();
        final attachmentId = (op.payload['attachment_id'] as num).toInt();
        return _taskDataSource.deleteAttachment(taskId, attachmentId);
    }
  }

  /// Ein Create-Payload darf keine (negative Temp-)ID an den Server senden:
  /// Vikunja deutet ein gesetztes/nicht-null `id` als bestehendes Objekt und
  /// antwortet mit 404. Die Temp-ID bleibt daher rein lokal (DB-Zeile +
  /// tempIdRefs-Mapping); im gesendeten Payload wird `id` auf 0 normalisiert.
  Map<String, dynamic> _createPayload(Map<String, dynamic> payload) =>
      Map<String, dynamic>.of(payload)..['id'] = 0;

  TaskDto _taskDto(Map<String, dynamic> payload, Map<String, int> refs) =>
      TaskDto.fromJson(_resolveTaskPayload(payload, refs));

  /// Setzt aufgelöste FK-Referenzen in ein Task-Payload zurück.
  Map<String, dynamic> _resolveTaskPayload(
    Map<String, dynamic> payload,
    Map<String, int> refs,
  ) {
    final p = Map<String, dynamic>.of(payload);
    if (refs.containsKey('projectId')) p['project_id'] = refs['projectId'];
    if (refs.containsKey('bucketId')) p['bucket_id'] = refs['bucketId'];
    return p;
  }

  List<UserDto> _userList(dynamic raw) => (raw as List? ?? const [])
      .map((e) => UserDto.fromJson((e as Map).cast<String, dynamic>()))
      .toList();

  List<LabelDto> _labelList(dynamic raw) => (raw as List? ?? const [])
      .map((e) => LabelDto.fromJson((e as Map).cast<String, dynamic>()))
      .toList();

  // --- Erfolgsbehandlung -----------------------------------------------------

  int serverIdOf(PendingOpType type, dynamic body) {
    switch (type) {
      case PendingOpType.taskCreate:
        return (body as TaskDto).id;
      case PendingOpType.commentCreate:
        return (body as TaskCommentDto).id;
      case PendingOpType.projectCreate:
        return (body as ProjectDto).id;
      case PendingOpType.bucketCreate:
        return (body as BucketDto).id;
      case PendingOpType.labelCreate:
        return (body as LabelDto).id;
      default:
        throw StateError('Kein Create-Typ: $type');
    }
  }

  /// Zieht die primäre Entität von der Temp-ID auf die Server-ID um und
  /// aktualisiert alle FK-Spalten abhängiger Zeilen.
  Future<void> migrateEntity(PendingOpType type, int temp, int server) async {
    switch (type) {
      case PendingOpType.taskCreate:
        await (_db.update(_db.tasks)..where((t) => t.id.equals(temp))).write(
          TasksCompanion(
            id: Value(server),
            remoteId: Value(server),
            isDirty: const Value(false),
          ),
        );
        await (_db.update(
          _db.taskComments,
        )..where((c) => c.taskId.equals(temp))).write(
          TaskCommentsCompanion(taskId: Value(server)),
        );
        await (_db.update(
          _db.taskLabels,
        )..where((r) => r.taskId.equals(temp))).write(
          TaskLabelsCompanion(taskId: Value(server)),
        );
        await (_db.update(
          _db.taskAssignees,
        )..where((r) => r.taskId.equals(temp))).write(
          TaskAssigneesCompanion(taskId: Value(server)),
        );
        await (_db.update(
          _db.taskAttachments,
        )..where((a) => a.taskId.equals(temp))).write(
          TaskAttachmentsCompanion(taskId: Value(server)),
        );
      case PendingOpType.projectCreate:
        await (_db.update(_db.projects)..where((p) => p.id.equals(temp))).write(
          ProjectsCompanion(
            id: Value(server),
            remoteId: Value(server),
            isDirty: const Value(false),
          ),
        );
        await (_db.update(_db.tasks)..where((t) => t.projectId.equals(temp)))
            .write(TasksCompanion(projectId: Value(server)));
        await (_db.update(_db.buckets)..where((b) => b.projectId.equals(temp)))
            .write(BucketsCompanion(projectId: Value(server)));
      case PendingOpType.bucketCreate:
        await (_db.update(_db.buckets)..where((b) => b.id.equals(temp))).write(
          BucketsCompanion(
            id: Value(server),
            remoteId: Value(server),
            isDirty: const Value(false),
          ),
        );
        await (_db.update(_db.tasks)..where((t) => t.bucketId.equals(temp)))
            .write(TasksCompanion(bucketId: Value(server)));
      case PendingOpType.labelCreate:
        await (_db.update(_db.labels)..where((l) => l.id.equals(temp))).write(
          LabelsCompanion(
            id: Value(server),
            remoteId: Value(server),
            isDirty: const Value(false),
          ),
        );
        await (_db.update(_db.taskLabels)..where((r) => r.labelId.equals(temp)))
            .write(TaskLabelsCompanion(labelId: Value(server)));
      case PendingOpType.commentCreate:
        await (_db.update(
          _db.taskComments,
        )..where((c) => c.id.equals(temp))).write(
          TaskCommentsCompanion(
            id: Value(server),
            remoteId: Value(server),
            isDirty: const Value(false),
          ),
        );
      default:
        break;
    }
  }

  /// Upsertet die Server-Antwort einer Create-Op in die lokale DB.
  Future<void> upsertCreated(
    PendingOp op,
    dynamic body,
    int serverId,
    DateTime now,
  ) async {
    switch (op.type) {
      case PendingOpType.taskCreate:
        final dto = body as TaskDto;
        await _tasksDao.upsertFromServer(
          _mapper.task(dto, now, projectId: dto.projectId),
        );
      case PendingOpType.projectCreate:
        await _projectsDao.upsertFromServer(_mapper.project(body, now));
      case PendingOpType.bucketCreate:
        final dto = body as BucketDto;
        final projectId =
            (op.payload['project_id'] as num?)?.toInt() ??
            (await _bucketsDao.getById(serverId))?.projectId ??
            0;
        await _bucketsDao.upsertFromServer(
          _mapper.bucket(dto, now, projectId: projectId),
        );
      case PendingOpType.labelCreate:
        await _labelsDao.upsertFromServer(_mapper.label(body, now));
      case PendingOpType.commentCreate:
        final dto = body as TaskCommentDto;
        final taskId =
            (await _commentTaskId(serverId)) ??
            (op.payload['task_id'] as num?)?.toInt() ??
            0;
        await _taskCommentsDao.upsertFromServer(
          _mapper.taskComment(dto, now, taskId: taskId),
        );
      default:
        break;
    }
  }

  Future<int?> _commentTaskId(int commentId) async {
    final row = await (_db.select(
      _db.taskComments,
    )..where((c) => c.id.equals(commentId))).getSingleOrNull();
    return row?.taskId;
  }

  /// Erfolg einer Nicht-Create-Op: lokale dirty-Markierung lösen bzw. Zeile
  /// entfernen und ggf. Server-Antwort upserten.
  Future<void> postNonCreate(
    PendingOp op,
    dynamic body,
    int primaryId,
    DateTime now,
  ) async {
    switch (op.type) {
      case PendingOpType.taskUpdate:
        await _clearTaskDirty(primaryId);
        await _tasksDao.upsertFromServer(
          _mapper.task(body as TaskDto, now, projectId: (body).projectId),
        );
      case PendingOpType.taskDelete:
        await (_db.delete(_db.tasks)..where((t) => t.id.equals(primaryId))).go();
        await (_db.delete(
          _db.taskLabels,
        )..where((r) => r.taskId.equals(primaryId))).go();
        await (_db.delete(
          _db.taskAssignees,
        )..where((r) => r.taskId.equals(primaryId))).go();
      case PendingOpType.taskSetAssignees:
        await (_db.update(
          _db.taskAssignees,
        )..where((r) => r.taskId.equals(primaryId))).write(
          const TaskAssigneesCompanion(isDirty: Value(false)),
        );
      case PendingOpType.taskLabelBulk:
        await (_db.update(
          _db.taskLabels,
        )..where((r) => r.taskId.equals(primaryId))).write(
          const TaskLabelsCompanion(isDirty: Value(false)),
        );
      case PendingOpType.taskMoveBucket:
      case PendingOpType.taskPosition:
        await _clearTaskDirty(primaryId);
      case PendingOpType.projectUpdate:
        await _clearProjectDirty(primaryId);
        await _projectsDao.upsertFromServer(_mapper.project(body, now));
      case PendingOpType.bucketUpdate:
        await _clearBucketDirty(primaryId);
      case PendingOpType.bucketDelete:
        await (_db.delete(
          _db.buckets,
        )..where((b) => b.id.equals(primaryId))).go();
      case PendingOpType.commentUpdate:
        await (_db.update(
          _db.taskComments,
        )..where((c) => c.id.equals(primaryId))).write(
          const TaskCommentsCompanion(isDirty: Value(false)),
        );
      case PendingOpType.commentDelete:
        await (_db.delete(
          _db.taskComments,
        )..where((c) => c.id.equals(primaryId))).go();
      case PendingOpType.attachmentUpload:
        await _applyUploadedAttachments(op, body, primaryId, now);
      case PendingOpType.attachmentDelete:
        final attachmentId = (op.payload['attachment_id'] as num).toInt();
        await (_db.delete(
          _db.taskAttachments,
        )..where((a) => a.remoteId.equals(attachmentId))).go();
      case PendingOpType.projectViewUpdate:
      case PendingOpType.userSettings:
        // Keine lokale dirty-Entität, die aufgeräumt werden müsste.
        break;
      default:
        break;
    }
  }

  /// Ersetzt die offline angelegten Platzhalter-Zeilen durch die Server-Anhänge
  /// und löscht die kopierten Upload-Dateien.
  Future<void> _applyUploadedAttachments(
    PendingOp op,
    dynamic body,
    int taskId,
    DateTime now,
  ) async {
    final dtos = (body as List).cast<TaskAttachmentDto>();
    final paths = op.localFilePaths ?? const <String>[];

    if (paths.isNotEmpty) {
      await (_db.delete(_db.taskAttachments)..where(
            (a) => a.taskId.equals(taskId) & a.localFilePath.isIn(paths),
          ))
          .go();
    }
    final syncedAt = now.toUtc().toIso8601String();
    for (final dto in dtos) {
      await _db.taskAttachmentsDao.upsertFromServer(
        attachmentCompanionFromDto(dto, taskId: taskId, syncedAt: syncedAt),
      );
    }
    await _deleteUploadedFiles(paths);
  }

  Future<void> _clearTaskDirty(int id) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        const TasksCompanion(isDirty: Value(false)),
      );

  Future<void> _clearProjectDirty(int id) =>
      (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
        const ProjectsCompanion(isDirty: Value(false)),
      );

  Future<void> _clearBucketDirty(int id) =>
      (_db.update(_db.buckets)..where((b) => b.id.equals(id))).write(
        const BucketsCompanion(isDirty: Value(false)),
      );

  // --- Mapping-Persistenz + Umschreiben -------------------------------------

  Future<Map<int, int>> loadMapping() async {
    final raw = await _keyValueDao.get(kvTempIdMapping);
    if (raw == null) return {};
    final m = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return m.map((k, v) => MapEntry(int.parse(k), (v as num).toInt()));
  }

  Future<void> saveMapping(Map<int, int> mapping) {
    final encodable = mapping.map((k, v) => MapEntry('$k', v));
    return _keyValueDao.set(kvTempIdMapping, jsonEncode(encodable));
  }

  /// Schreibt alle noch offenen Outbox-Payloads um: jede Referenz (localId,
  /// tempIdRefs, FK-Felder + Label-IDs im Payload) auf [temp] wird durch
  /// [server] ersetzt.
  Future<void> rewritePendingOps(int temp, int server) async {
    final rows = await _pendingOpsDao.nextBatch(limit: _maxOps);
    for (final row in rows) {
      final op = PendingOp.fromRow(row);
      var changed = false;

      final newRefs = Map<String, int>.of(op.tempIdRefs);
      op.tempIdRefs.forEach((name, value) {
        if (value == temp) {
          newRefs[name] = server;
          changed = true;
        }
      });

      var newLocalId = op.localId;
      if (op.localId == temp) {
        newLocalId = server;
        changed = true;
      }

      final newPayload = Map<String, dynamic>.of(op.payload);
      for (final key in const [
        'id',
        'project_id',
        'bucket_id',
        'task_id',
        'parent_task_id',
      ]) {
        if (newPayload[key] == temp) {
          newPayload[key] = server;
          changed = true;
        }
      }
      // Label-IDs in taskLabelBulk-Payloads (offline erzeugte Labels).
      final labels = newPayload['labels'];
      if (labels is List) {
        for (final label in labels) {
          if (label is Map && label['id'] == temp) {
            label['id'] = server;
            changed = true;
          }
        }
      }

      if (!changed) continue;

      final updated = op.copyWith(
        payload: newPayload,
        tempIdRefs: newRefs,
        localId: newLocalId,
      );
      await (_db.update(_db.pendingOps)..where((o) => o.opId.equals(row.opId)))
          .write(
            PendingOpsCompanion(
              payloadJson: Value(updated.encodePayload()),
              localId: Value(newLocalId),
            ),
          );
    }
  }
}
