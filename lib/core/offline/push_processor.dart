import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/data_sources/bucket_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_data_source.dart';
import 'package:vikunja_app/data/data_sources/project_view_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_comment_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/data_sources/task_label_bulk_data_source.dart';
import 'package:vikunja_app/data/data_sources/user_data_source.dart';
import 'package:vikunja_app/data/local/dao/buckets_dao.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
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

/// Ergebnis eines [PushProcessor.pushAll]-Durchlaufs.
class PushResult {
  const PushResult({
    required this.success,
    required this.offline,
    required this.pushed,
    required this.failed,
  });

  /// Alle Ops abgearbeitet, keine offen (außer als failed markierte).
  final bool success;

  /// Abbruch, weil das Gerät/der Server nicht erreichbar war (kein Fehler).
  final bool offline;

  /// Anzahl erfolgreich gesendeter Ops.
  final int pushed;

  /// Anzahl als failed markierter Ops (4xx/5xx oder unauflösbare Referenz).
  final int failed;
}

/// Arbeitet die Outbox (`pending_ops`) ab und sendet lokale Änderungen an den
/// Vikunja-Server.
///
/// Reihenfolge: strikt FIFO nach `opId`. Die Enqueue-Reihenfolge respektiert
/// Abhängigkeiten bereits (eine liefernde Create-Op liegt immer vor ihren
/// Nutzern), daher wird NICHT umsortiert.
///
/// Temp-IDs: Offline erzeugte Entitäten tragen negative IDs. Beim Create-Erfolg
/// wird die Server-ID im [kvTempIdMapping] persistiert, die DB-Zeile (id +
/// remoteId) sowie alle abhängigen FK-Spalten umgezogen und die restlichen
/// Outbox-Payloads umgeschrieben. Ist eine referenzierte Temp-ID unauflösbar
/// (liefernde Op fehlt/failed), wird die Op als failed markiert; die Kaskade
/// ergibt sich automatisch, weil abhängige Ops dieselbe fehlende Zuordnung
/// nicht auflösen können.
///
/// Fehlerbehandlung: `ErrorResponse` (4xx/5xx) markiert die Op als failed und
/// fährt fort; `ExceptionResponse` (offline) bricht den Lauf ab, ohne
/// retryCount zu erhöhen (offline ist kein Fehlversuch).
class PushProcessor {
  PushProcessor({
    required AppDatabase db,
    required TaskDataSource taskDataSource,
    required TaskCommentDataSource taskCommentDataSource,
    required ProjectDataSource projectDataSource,
    required BucketDataSource bucketDataSource,
    required TaskLabelBulkDataSource taskLabelBulkDataSource,
    required ProjectViewDataSource projectViewDataSource,
    required UserDataSource userDataSource,
    required TasksDao tasksDao,
    required ProjectsDao projectsDao,
    required BucketsDao bucketsDao,
    required TaskCommentsDao taskCommentsDao,
    required PendingOpsDao pendingOpsDao,
    required KeyValueDao keyValueDao,
    DtoCompanionMapper mapper = const DtoCompanionMapper(),
  }) : _db = db,
       _taskDataSource = taskDataSource,
       _taskCommentDataSource = taskCommentDataSource,
       _projectDataSource = projectDataSource,
       _bucketDataSource = bucketDataSource,
       _taskLabelBulkDataSource = taskLabelBulkDataSource,
       _projectViewDataSource = projectViewDataSource,
       _userDataSource = userDataSource,
       _tasksDao = tasksDao,
       _projectsDao = projectsDao,
       _bucketsDao = bucketsDao,
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
  final ProjectViewDataSource _projectViewDataSource;
  final UserDataSource _userDataSource;

  final TasksDao _tasksDao;
  final ProjectsDao _projectsDao;
  final BucketsDao _bucketsDao;
  final TaskCommentsDao _taskCommentsDao;
  final PendingOpsDao _pendingOpsDao;
  final KeyValueDao _keyValueDao;
  final DtoCompanionMapper _mapper;

  /// Sicherheitsnetz gegen fehlerhafte Zustände (Ops-Zahl ist ohnehin klein).
  static const int _maxOps = 100000;

  /// Laufender Push; Single-Flight — ein zweiter Aufruf wartet auf denselben
  /// Future statt einen weiteren Durchlauf zu starten.
  Future<PushResult>? _inFlight;

  Future<PushResult> pushAll() {
    return _inFlight ??= _pushAll().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<PushResult> _pushAll() async {
    final mapping = await _loadMapping();
    final rows = await _pendingOpsDao.nextBatch(limit: _maxOps);
    final ops = rows.map(PendingOp.fromRow).toList();

    // Sicherheitsnetz (echte Delete-Kompaktierung beim Enqueue = Paket E2):
    // taskDelete auf eine noch nicht gesyncte Temp-ID, deren taskCreate
    // ebenfalls noch in der Queue liegt → beide Ops (und die rein lokale
    // Temp-Zeile) verschwinden ohne Server-Call.
    final cancelled = await _compactUnsyncedCreateDelete(ops, mapping);

    var pushed = 0;
    var failed = 0;

    for (final op in ops) {
      if (cancelled.contains(op.opId)) continue;

      // Referenzen auflösen (Temp-ID → Server-ID über das In-Memory-Mapping,
      // das persistierte Mapping ist beim Start eingelesen).
      final resolvedRefs = <String, int>{};
      var unresolvable = false;
      op.tempIdRefs.forEach((name, id) {
        if (id < 0) {
          final server = mapping[id];
          if (server == null) {
            unresolvable = true;
          } else {
            resolvedRefs[name] = server;
          }
        } else {
          resolvedRefs[name] = id;
        }
      });

      final primaryId = op.localId < 0 ? mapping[op.localId] : op.localId;
      if (!op.type.isCreate && primaryId == null) {
        // Update/Delete auf einer Temp-Entität, deren Create fehlt/failed.
        unresolvable = true;
      }

      if (unresolvable) {
        await _pendingOpsDao.markError(op.opId!, 'unresolvable temp reference');
        failed++;
        continue;
      }

      final Response<dynamic> resp;
      try {
        resp = await _dispatch(op, resolvedRefs, primaryId);
      } catch (e) {
        await _pendingOpsDao.markError(op.opId!, 'dispatch error: $e');
        failed++;
        continue;
      }

      switch (resp) {
        case ExceptionResponse():
          // Offline: Abbruch. retryCount NICHT erhöhen, Rest bleibt pending.
          return PushResult(
            success: false,
            offline: true,
            pushed: pushed,
            failed: failed,
          );
        case ErrorResponse():
          await _pendingOpsDao.markError(
            op.opId!,
            'HTTP ${resp.statusCode}: ${resp.error}',
          );
          failed++;
        case SuccessResponse():
          await _onSuccess(op, resp.body, primaryId, mapping);
          pushed++;
      }
    }

    return PushResult(
      success: failed == 0,
      offline: false,
      pushed: pushed,
      failed: failed,
    );
  }

  // --- Erfolgsbehandlung -----------------------------------------------------

  Future<void> _onSuccess(
    PendingOp op,
    dynamic body,
    int? primaryId,
    Map<int, int> mapping,
  ) async {
    final now = DateTime.now();
    if (op.type.isCreate) {
      final serverId = _serverIdOf(op.type, body);
      mapping[op.localId] = serverId;
      await _db.transaction(() async {
        // (a) Mapping persistieren (Crash-Sicherheit).
        await _saveMapping(mapping);
        // (b) DB-Zeile + abhängige FK-Spalten von Temp-ID auf Server-ID.
        await _migrateEntity(op.type, op.localId, serverId);
        // (c) restliche Outbox-Payloads umschreiben.
        await _rewritePendingOps(op.localId, serverId);
        // (e) Server-Response upserten (dirty ist durch (b) schon gelöscht).
        await _upsertCreated(op, body, serverId, now);
        // (d) Op löschen.
        await _pendingOpsDao.deleteOp(op.opId!);
      });
    } else {
      await _db.transaction(() async {
        await _postNonCreate(op, body, primaryId!, now);
        await _pendingOpsDao.deleteOp(op.opId!);
      });
    }
  }

  int _serverIdOf(PendingOpType type, dynamic body) {
    switch (type) {
      case PendingOpType.taskCreate:
        return (body as TaskDto).id;
      case PendingOpType.commentCreate:
        return (body as TaskCommentDto).id;
      case PendingOpType.projectCreate:
        return (body as ProjectDto).id;
      case PendingOpType.bucketCreate:
        return (body as BucketDto).id;
      default:
        throw StateError('Kein Create-Typ: $type');
    }
  }

  /// Zieht die primäre Entität von der Temp-ID auf die Server-ID um und
  /// aktualisiert alle FK-Spalten abhängiger Zeilen.
  Future<void> _migrateEntity(PendingOpType type, int temp, int server) async {
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
  Future<void> _upsertCreated(
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
  Future<void> _postNonCreate(
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
      case PendingOpType.projectViewUpdate:
      case PendingOpType.userSettings:
      case PendingOpType.attachmentUpload:
      case PendingOpType.attachmentDelete:
        // Keine lokale dirty-Entität, die aufgeräumt werden müsste.
        break;
      default:
        break;
    }
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

  // --- Dispatch --------------------------------------------------------------

  /// Sendet eine Op an die passende Data-Source. [refs] enthält aufgelöste
  /// Temp-Referenzen (Server-IDs), [primaryId] die aufgelöste ID der primären
  /// Entität (bei Update/Delete).
  Future<Response<dynamic>> _dispatch(
    PendingOp op,
    Map<String, int> refs,
    int? primaryId,
  ) {
    switch (op.type) {
      case PendingOpType.taskCreate:
        final projectId =
            refs['projectId'] ?? (op.payload['project_id'] as num).toInt();
        return _taskDataSource.add(projectId, _taskDto(op.payload, refs));
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
      case PendingOpType.commentCreate:
        final taskId =
            refs['taskId'] ?? (op.payload['task_id'] as num).toInt();
        return _taskCommentDataSource.create(
          taskId,
          TaskCommentDto.fromJson(op.payload),
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
        return _projectDataSource.create(ProjectDto.fromJson(op.payload));
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
          BucketDto.fromJSON(op.payload),
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

  // --- Mapping-Persistenz + Umschreiben -------------------------------------

  Future<Map<int, int>> _loadMapping() async {
    final raw = await _keyValueDao.get(kvTempIdMapping);
    if (raw == null) return {};
    final m = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return m.map((k, v) => MapEntry(int.parse(k), (v as num).toInt()));
  }

  Future<void> _saveMapping(Map<int, int> mapping) {
    final encodable = mapping.map((k, v) => MapEntry('$k', v));
    return _keyValueDao.set(kvTempIdMapping, jsonEncode(encodable));
  }

  /// Schreibt alle noch offenen Outbox-Payloads um: jede Referenz (localId,
  /// tempIdRefs, FK-Felder im Payload) auf [temp] wird durch [server] ersetzt.
  Future<void> _rewritePendingOps(int temp, int server) async {
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

  /// Sicherheitsnetz: hebt Create+Delete-Paare auf einer nie gesyncten Temp-ID
  /// auf. Liefert die opIds, die im Hauptlauf übersprungen werden müssen.
  Future<Set<int>> _compactUnsyncedCreateDelete(
    List<PendingOp> ops,
    Map<int, int> mapping,
  ) async {
    final createOpByTemp = <int, int>{};
    for (final op in ops) {
      if (op.type == PendingOpType.taskCreate) {
        createOpByTemp[op.localId] = op.opId!;
      }
    }

    final cancelled = <int>{};
    for (final op in ops) {
      if (op.type != PendingOpType.taskDelete) continue;
      if (op.localId >= 0) continue;
      if (mapping.containsKey(op.localId)) continue;
      final createOpId = createOpByTemp[op.localId];
      if (createOpId == null) continue;

      final temp = op.localId;
      await _db.transaction(() async {
        await _pendingOpsDao.deleteOp(createOpId);
        await _pendingOpsDao.deleteOp(op.opId!);
        // Rein lokale Temp-Zeile + Junctions entfernen (nie synchronisiert).
        await (_db.delete(_db.tasks)..where((t) => t.id.equals(temp))).go();
        await (_db.delete(
          _db.taskLabels,
        )..where((r) => r.taskId.equals(temp))).go();
        await (_db.delete(
          _db.taskAssignees,
        )..where((r) => r.taskId.equals(temp))).go();
        await (_db.delete(
          _db.taskComments,
        )..where((c) => c.taskId.equals(temp))).go();
      });
      cancelled.add(createOpId);
      cancelled.add(op.opId!);
    }
    return cancelled;
  }
}
