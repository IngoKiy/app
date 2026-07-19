import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/op_executor.dart';
import 'package:vikunja_app/core/offline/outbox.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/local/dao/buckets_dao.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
import 'package:vikunja_app/data/local/dao/labels_dao.dart';
import 'package:vikunja_app/data/local/dao/pending_ops_dao.dart';
import 'package:vikunja_app/data/local/dao/projects_dao.dart';
import 'package:vikunja_app/data/local/dao/task_assignees_dao.dart';
import 'package:vikunja_app/data/local/dao/task_comments_dao.dart';
import 'package:vikunja_app/data/local/dao/task_labels_dao.dart';
import 'package:vikunja_app/data/local/dao/tasks_dao.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/bucket_dto.dart';
import 'package:vikunja_app/data/models/label_dto.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/data/models/project_view_dto.dart';
import 'package:vikunja_app/data/models/task_comment_dto.dart';
import 'package:vikunja_app/data/models/task_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';
import 'package:vikunja_app/domain/entities/bucket.dart';
import 'package:vikunja_app/domain/entities/label.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_comment.dart';
import 'package:vikunja_app/domain/entities/user.dart';

/// KeyValue-Schlüssel des zwischengespeicherten aktuellen Nutzers (Spiegel der
/// `/user`-Antwort). Wird bei einem lokalen userSettings-Schreibvorgang
/// gepatcht. Muss mit `sync_service.dart` (`kvCurrentUser`) übereinstimmen.
const String _kvCurrentUser = 'current_user';

/// Ausgang eines Offline-Schreibvorgangs.
enum OfflineWriteStatus {
  /// Online direkt erfolgreich gesendet (Server-Antwort übernommen).
  synced,

  /// Netzwerkfehler → optimistisch lokal angewendet + in die Outbox gelegt.
  queued,

  /// Server hat abgelehnt (4xx/5xx) → lokale Änderung zurückgerollt.
  rejected,
}

class OfflineWriteResult {
  const OfflineWriteResult(this.status, {this.body, this.error});

  final OfflineWriteStatus status;

  /// Server-Antwort bei [OfflineWriteStatus.synced].
  final Object? body;

  /// Fehler-Response bei [OfflineWriteStatus.rejected].
  final ErrorResponse<dynamic>? error;

  /// Aus UI-Sicht ist alles außer einer Ablehnung ein Erfolg (optimistisch).
  bool get ok => status != OfflineWriteStatus.rejected;
}

/// Zentrale Hilfsklasse für alle schreibenden Operationen im Local-First-Modus.
///
/// Ablauf pro Write (siehe docs/offline.md, Paket E2):
/// 1. **Lokal anwenden:** Entität in die DB schreiben (Create: neue Temp-ID +
///    `isDirty`; Update: Zeile patchen + `isDirty`; Delete: Temp-Zeile löschen
///    bzw. Tombstone).
/// 2. **Online versuchen:** dieselbe Data-Source-Methode wie der Push aufrufen
///    (über den geteilten [OpExecutor]).
/// 3. **Netzwerkfehler:** Op in die Outbox (FIFO = Abhängigkeit). Die UI sieht
///    weiterhin die optimistische lokale Änderung, das Banner zählt sie.
/// 4. **Server-Ablehnung (4xx):** kein Enqueue, lokale Änderung zurückrollen,
///    Fehler an die UI.
class OfflineWriter {
  OfflineWriter({
    required AppDatabase db,
    required Outbox outbox,
    required OpExecutor executor,
    required TasksDao tasksDao,
    required ProjectsDao projectsDao,
    required BucketsDao bucketsDao,
    required LabelsDao labelsDao,
    required TaskCommentsDao taskCommentsDao,
    required TaskLabelsDao taskLabelsDao,
    required TaskAssigneesDao taskAssigneesDao,
    required PendingOpsDao pendingOpsDao,
    required KeyValueDao keyValueDao,
    DtoCompanionMapper mapper = const DtoCompanionMapper(),
  }) : _db = db,
       _outbox = outbox,
       _executor = executor,
       _tasksDao = tasksDao,
       _projectsDao = projectsDao,
       _bucketsDao = bucketsDao,
       _labelsDao = labelsDao,
       _taskCommentsDao = taskCommentsDao,
       _taskLabelsDao = taskLabelsDao,
       _taskAssigneesDao = taskAssigneesDao,
       _pendingOpsDao = pendingOpsDao,
       _keyValueDao = keyValueDao,
       _mapper = mapper;

  final AppDatabase _db;
  final Outbox _outbox;
  final OpExecutor _executor;
  final TasksDao _tasksDao;
  final ProjectsDao _projectsDao;
  final BucketsDao _bucketsDao;
  final LabelsDao _labelsDao;
  final TaskCommentsDao _taskCommentsDao;
  final TaskLabelsDao _taskLabelsDao;
  final TaskAssigneesDao _taskAssigneesDao;
  final PendingOpsDao _pendingOpsDao;
  final KeyValueDao _keyValueDao;
  final DtoCompanionMapper _mapper;

  DateTime get _now => DateTime.now();
  String get _nowIso => DateTime.now().toUtc().toIso8601String();

  // --- Generischer Kern ------------------------------------------------------

  /// Wendet [op] optimistisch an ([applyLocal]), versucht online zu senden und
  /// legt bei Netzwerkfehler die Op in die Outbox bzw. rollt bei Ablehnung
  /// zurück ([rollback]). [onlineRefs]/[onlinePrimaryId] sind die aufgelösten
  /// (realen) IDs für den direkten Online-Versuch.
  Future<OfflineWriteResult> _execute({
    required PendingOp op,
    required Future<void> Function() applyLocal,
    Future<void> Function()? rollback,
    Map<String, int> onlineRefs = const {},
    int? onlinePrimaryId,
    bool forceQueue = false,
  }) async {
    await applyLocal();

    // Nicht online adressierbar: Update/Delete auf einer Temp-Entität, eine
    // Temp-Referenz oder explizit erzwungen (z.B. Bulk mit Temp-Label).
    final hasTempRef = onlineRefs.values.any((v) => v < 0);
    if (forceQueue ||
        hasTempRef ||
        (!op.type.isCreate && op.localId < 0)) {
      await _outbox.enqueue(op);
      return const OfflineWriteResult(OfflineWriteStatus.queued);
    }

    final Response<dynamic> resp;
    try {
      resp = await _executor.dispatch(op, onlineRefs, onlinePrimaryId);
    } catch (_) {
      await _outbox.enqueue(op);
      return const OfflineWriteResult(OfflineWriteStatus.queued);
    }

    switch (resp) {
      case ExceptionResponse():
        await _outbox.enqueue(op);
        return const OfflineWriteResult(OfflineWriteStatus.queued);
      case ErrorResponse():
        if (rollback != null) await rollback();
        return OfflineWriteResult(OfflineWriteStatus.rejected, error: resp);
      case SuccessResponse():
        await _applyOnlineSuccess(op, resp.body, onlinePrimaryId);
        return OfflineWriteResult(OfflineWriteStatus.synced, body: resp.body);
    }
  }

  /// Übernimmt die Server-Antwort eines direkt erfolgreichen Online-Writes —
  /// dieselbe Migrations-/Merge-Logik wie im [PushProcessor], nur ohne
  /// Outbox-Eintrag.
  Future<void> _applyOnlineSuccess(
    PendingOp op,
    dynamic body,
    int? primaryId,
  ) async {
    final now = _now;
    if (op.type.isCreate) {
      final mapping = await _executor.loadMapping();
      final serverId = _executor.serverIdOf(op.type, body);
      mapping[op.localId] = serverId;
      await _db.transaction(() async {
        await _executor.saveMapping(mapping);
        await _executor.migrateEntity(op.type, op.localId, serverId);
        await _executor.rewritePendingOps(op.localId, serverId);
        await _executor.upsertCreated(op, body, serverId, now);
      });
    } else {
      await _db.transaction(
        () => _executor.postNonCreate(op, body, primaryId!, now),
      );
    }
  }

  // --- Tasks -----------------------------------------------------------------

  Future<OfflineWriteResult> addTask(int projectId, Task task) async {
    final tempId = await _outbox.nextTempId();
    final dto = TaskDto.fromDomain(
      task.copyWith(id: tempId, projectId: projectId),
    );
    final op = PendingOp(
      type: PendingOpType.taskCreate,
      localId: tempId,
      payload: <String, dynamic>{...dto.toJSON()},
      tempIdRefs: projectId < 0 ? {'projectId': projectId} : const {},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlineRefs: {'projectId': projectId},
      applyLocal: () => _tasksDao.upsertLocal(
        _mapper
            .task(dto, _now, projectId: projectId)
            .copyWith(remoteId: const Value(null)),
      ),
      rollback: () => _deleteTaskLocal(tempId),
    );
  }

  Future<OfflineWriteResult> updateTask(Task task) async {
    final dto = TaskDto.fromDomain(task);
    final backup = await _tasksDao.getById(task.id);
    final op = PendingOp(
      type: PendingOpType.taskUpdate,
      localId: task.id,
      payload: <String, dynamic>{...dto.toJSON()},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: task.id,
      applyLocal: () => _patchTaskLocal(dto, backup),
      rollback: () => _restoreTask(task.id, backup),
    );
  }

  Future<OfflineWriteResult> deleteTask(int id) async {
    final backup = await _tasksDao.getById(id);
    final op = PendingOp(
      type: PendingOpType.taskDelete,
      localId: id,
      payload: const {},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: id,
      applyLocal: () => id < 0 ? _deleteTaskLocal(id) : _tombstoneTask(id),
      rollback: () => _restoreTask(id, backup),
    );
  }

  /// Verschiebt einen Task in einen anderen Bucket + Position (zwei Ops, FIFO).
  Future<OfflineWriteResult> moveTask({
    required Task task,
    required int bucketId,
    required int projectId,
    required int viewId,
    required double position,
  }) async {
    final backup = await _tasksDao.getById(task.id);
    await _patchTaskMove(task.id, bucketId, position, backup);

    final moveOp = PendingOp(
      type: PendingOpType.taskMoveBucket,
      localId: task.id,
      payload: {
        'bucket_id': bucketId,
        'project_id': projectId,
        'view_id': viewId,
      },
      tempIdRefs: {
        if (task.id < 0) 'taskId': task.id,
        if (bucketId < 0) 'bucketId': bucketId,
        if (projectId < 0) 'projectId': projectId,
      },
      createdAt: _nowIso,
    );
    final posOp = PendingOp(
      type: PendingOpType.taskPosition,
      localId: task.id,
      payload: {'position': position, 'view_id': viewId},
      tempIdRefs: {if (task.id < 0) 'taskId': task.id},
      createdAt: _nowIso,
    );

    // Nicht online adressierbar → beide Ops in FIFO-Reihenfolge einreihen.
    if (task.id < 0 || bucketId < 0 || projectId < 0) {
      await _outbox.enqueue(moveOp);
      await _outbox.enqueue(posOp);
      return const OfflineWriteResult(OfflineWriteStatus.queued);
    }

    Response<dynamic> r1;
    try {
      r1 = await _executor.dispatch(moveOp, const {}, task.id);
    } catch (_) {
      await _outbox.enqueue(moveOp);
      await _outbox.enqueue(posOp);
      return const OfflineWriteResult(OfflineWriteStatus.queued);
    }
    switch (r1) {
      case ExceptionResponse():
        await _outbox.enqueue(moveOp);
        await _outbox.enqueue(posOp);
        return const OfflineWriteResult(OfflineWriteStatus.queued);
      case ErrorResponse():
        await _restoreTask(task.id, backup);
        return OfflineWriteResult(OfflineWriteStatus.rejected, error: r1);
      case SuccessResponse(:final body):
        await _db.transaction(
          () => _executor.postNonCreate(moveOp, body, task.id, _now),
        );
    }

    Response<dynamic> r2;
    try {
      r2 = await _executor.dispatch(posOp, const {}, task.id);
    } catch (_) {
      await _outbox.enqueue(posOp);
      return const OfflineWriteResult(OfflineWriteStatus.queued);
    }
    switch (r2) {
      case ExceptionResponse():
        await _outbox.enqueue(posOp);
        return const OfflineWriteResult(OfflineWriteStatus.queued);
      case ErrorResponse():
        // Bucket-Wechsel steht bereits; Position gleicht der nächste Pull ab.
        return OfflineWriteResult(OfflineWriteStatus.rejected, error: r2);
      case SuccessResponse(:final body):
        await _db.transaction(
          () => _executor.postNonCreate(posOp, body, task.id, _now),
        );
        return const OfflineWriteResult(OfflineWriteStatus.synced);
    }
  }

  /// Positionsänderung eines Tasks (Reorder in der List-View).
  Future<OfflineWriteResult> reorderTask({
    required int taskId,
    required int viewId,
    required double position,
  }) async {
    final backup = await _tasksDao.getById(taskId);
    final op = PendingOp(
      type: PendingOpType.taskPosition,
      localId: taskId,
      payload: {'position': position, 'view_id': viewId},
      tempIdRefs: {if (taskId < 0) 'taskId': taskId},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: taskId,
      applyLocal: () => _patchTaskPosition(taskId, position, backup),
      rollback: () => _restoreTask(taskId, backup),
    );
  }

  Future<OfflineWriteResult> setAssignees(int taskId, List<User> users) async {
    final backup = await _assigneeIds(taskId);
    final op = PendingOp(
      type: PendingOpType.taskSetAssignees,
      localId: taskId,
      payload: {
        'assignees': users.map((u) => UserDto.fromDomain(u).toJSON()).toList(),
      },
      tempIdRefs: {if (taskId < 0) 'taskId': taskId},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: taskId,
      applyLocal: () => _replaceAssignees(taskId, users),
      rollback: () => _restoreAssignees(taskId, backup),
    );
  }

  Future<OfflineWriteResult> setLabels(int taskId, List<Label> labels) async {
    final backup = await _labelIds(taskId);
    final hasTempLabel = labels.any((l) => l.id < 0);
    final op = PendingOp(
      type: PendingOpType.taskLabelBulk,
      localId: taskId,
      payload: {
        'labels': labels.map((l) => LabelDto.fromDomain(l).toJSON()).toList(),
      },
      tempIdRefs: {if (taskId < 0) 'taskId': taskId},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: taskId,
      // Temp-Label (offline erzeugt) kann online nicht referenziert werden.
      forceQueue: hasTempLabel,
      applyLocal: () => _replaceLabels(taskId, labels),
      rollback: () => _restoreLabels(taskId, backup),
    );
  }

  // --- Labels ----------------------------------------------------------------

  /// Legt ein Label an. Liefert das anzuzeigende Label (Server-Label bei
  /// Erfolg, Temp-Label bei Offline) oder `null` bei Server-Ablehnung.
  Future<Label?> createLabel(Label label) async {
    final tempId = await _outbox.nextTempId();
    final dto = _labelWithId(LabelDto.fromDomain(label), tempId);
    final op = PendingOp(
      type: PendingOpType.labelCreate,
      localId: tempId,
      payload: <String, dynamic>{...dto.toJSON()},
      createdAt: _nowIso,
    );
    final res = await _execute(
      op: op,
      applyLocal: () => _labelsDao.upsertLocal(
        _mapper.label(dto, _now).copyWith(remoteId: const Value(null)),
      ),
      rollback: () => _deleteLabelLocal(tempId),
    );
    switch (res.status) {
      case OfflineWriteStatus.rejected:
        return null;
      case OfflineWriteStatus.synced:
        return (res.body as LabelDto).toDomain();
      case OfflineWriteStatus.queued:
        return dto.toDomain();
    }
  }

  // --- Comments --------------------------------------------------------------

  Future<OfflineWriteResult> addComment(
    int taskId,
    String text,
    User author,
  ) async {
    final tempId = await _outbox.nextTempId();
    final dto = TaskCommentDto(
      id: tempId,
      comment: text,
      author: UserDto.fromDomain(author),
    );
    final op = PendingOp(
      type: PendingOpType.commentCreate,
      localId: tempId,
      payload: <String, dynamic>{...dto.toJSON(), 'task_id': taskId},
      tempIdRefs: taskId < 0 ? {'taskId': taskId} : const {},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlineRefs: {'taskId': taskId},
      applyLocal: () => _taskCommentsDao.upsertLocal(
        _mapper
            .taskComment(dto, _now, taskId: taskId)
            .copyWith(remoteId: const Value(null)),
      ),
      rollback: () => _deleteCommentLocal(tempId),
    );
  }

  Future<OfflineWriteResult> updateComment(
    int taskId,
    TaskComment comment,
    String text,
  ) async {
    final dto = TaskCommentDto(
      id: comment.id,
      comment: text,
      author: UserDto.fromDomain(comment.author),
      created: comment.created,
    );
    final backup = await _commentRow(comment.id);
    final op = PendingOp(
      type: PendingOpType.commentUpdate,
      localId: comment.id,
      payload: <String, dynamic>{...dto.toJSON(), 'task_id': taskId},
      tempIdRefs: taskId < 0 ? {'taskId': taskId} : const {},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: comment.id,
      onlineRefs: {'taskId': taskId},
      applyLocal: () => _patchCommentLocal(dto, taskId, backup),
      rollback: () => _restoreComment(comment.id, backup),
    );
  }

  Future<OfflineWriteResult> deleteComment(int taskId, int commentId) async {
    final backup = await _commentRow(commentId);
    final op = PendingOp(
      type: PendingOpType.commentDelete,
      localId: commentId,
      payload: {'task_id': taskId},
      tempIdRefs: taskId < 0 ? {'taskId': taskId} : const {},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: commentId,
      onlineRefs: {'taskId': taskId},
      applyLocal: () =>
          commentId < 0 ? _deleteCommentLocal(commentId) : _tombstoneComment(commentId),
      rollback: () => _restoreComment(commentId, backup),
    );
  }

  // --- Projects --------------------------------------------------------------

  Future<OfflineWriteResult> createProject(Project project) async {
    final tempId = await _outbox.nextTempId();
    final dto = _projectWithId(ProjectDto.fromDomain(project), tempId);
    final op = PendingOp(
      type: PendingOpType.projectCreate,
      localId: tempId,
      payload: <String, dynamic>{...dto.toJSON()},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      applyLocal: () => _projectsDao.upsertLocal(
        _mapper.project(dto, _now).copyWith(remoteId: const Value(null)),
      ),
      rollback: () => _deleteProjectLocal(tempId),
    );
  }

  Future<OfflineWriteResult> updateProject(Project project) async {
    final dto = ProjectDto.fromDomain(project);
    final backup = await _projectsDao.getById(project.id);
    final op = PendingOp(
      type: PendingOpType.projectUpdate,
      localId: project.id,
      payload: <String, dynamic>{...dto.toJSON()},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: project.id,
      applyLocal: () => _patchProjectLocal(dto, backup),
      rollback: () => _restoreProject(project.id, backup),
    );
  }

  /// Aktualisiert die Metadaten einer Projekt-View (done-/default-Bucket). Das
  /// lokale Persistieren übernimmt [persistLocal] (die View steckt im Projekt).
  Future<OfflineWriteResult> updateProjectView(
    ProjectViewDto view, {
    required Future<void> Function() persistLocal,
    Future<void> Function()? rollback,
  }) {
    final op = PendingOp(
      type: PendingOpType.projectViewUpdate,
      localId: view.id,
      payload: <String, dynamic>{...view.toJSON()},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: view.id,
      applyLocal: persistLocal,
      rollback: rollback,
    );
  }

  // --- Buckets ---------------------------------------------------------------

  Future<OfflineWriteResult> addBucket(
    int projectId,
    int viewId,
    Bucket bucket,
  ) async {
    final tempId = await _outbox.nextTempId();
    final dto = BucketDto.fromDomain(bucket)..id = tempId;
    final op = PendingOp(
      type: PendingOpType.bucketCreate,
      localId: tempId,
      payload: <String, dynamic>{
        ...dto.toJSON(),
        'project_id': projectId,
        'view_id': viewId,
      },
      tempIdRefs: {
        if (projectId < 0) 'projectId': projectId,
        if (viewId < 0) 'viewId': viewId,
      },
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlineRefs: {'projectId': projectId, 'viewId': viewId},
      applyLocal: () => _bucketsDao.upsertLocal(
        _mapper
            .bucket(dto, _now, projectId: projectId, viewId: viewId)
            .copyWith(remoteId: const Value(null)),
      ),
      rollback: () => _deleteBucketLocal(tempId),
    );
  }

  Future<OfflineWriteResult> updateBucket(
    int projectId,
    int viewId,
    Bucket bucket,
  ) async {
    final dto = BucketDto.fromDomain(bucket);
    final backup = await _bucketsDao.getById(bucket.id);
    final op = PendingOp(
      type: PendingOpType.bucketUpdate,
      localId: bucket.id,
      payload: <String, dynamic>{
        ...dto.toJSON(),
        'project_id': projectId,
        'view_id': viewId,
      },
      tempIdRefs: {
        if (projectId < 0) 'projectId': projectId,
        if (viewId < 0) 'viewId': viewId,
      },
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: bucket.id,
      onlineRefs: {'projectId': projectId, 'viewId': viewId},
      applyLocal: () => _patchBucketLocal(dto, projectId, viewId, backup),
      rollback: () => _restoreBucket(bucket.id, backup),
    );
  }

  Future<OfflineWriteResult> deleteBucket(
    int projectId,
    int viewId,
    int bucketId,
  ) async {
    final backup = await _bucketsDao.getById(bucketId);
    final op = PendingOp(
      type: PendingOpType.bucketDelete,
      localId: bucketId,
      payload: {'project_id': projectId, 'view_id': viewId},
      tempIdRefs: {
        if (projectId < 0) 'projectId': projectId,
        if (viewId < 0) 'viewId': viewId,
      },
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: bucketId,
      onlineRefs: {'projectId': projectId, 'viewId': viewId},
      applyLocal: () =>
          bucketId < 0 ? _deleteBucketLocal(bucketId) : _tombstoneBucket(bucketId),
      rollback: () => _restoreBucket(bucketId, backup),
    );
  }

  // --- User-Settings ---------------------------------------------------------

  Future<OfflineWriteResult> updateUserSettings(UserSettingsDto settings) async {
    final backup = await _keyValueDao.get(_kvCurrentUser);
    final op = PendingOp(
      type: PendingOpType.userSettings,
      localId: 0,
      payload: <String, dynamic>{...settings.toJson()},
      createdAt: _nowIso,
    );
    return _execute(
      op: op,
      onlinePrimaryId: 0,
      applyLocal: () => _patchCurrentUserSettings(settings, backup),
      rollback: () async {
        if (backup != null) await _keyValueDao.set(_kvCurrentUser, backup);
      },
    );
  }

  // --- Verwerfen (Sync-Status-Sheet) -----------------------------------------

  /// Verwirft eine (meist fehlgeschlagene) Outbox-Op: entfernt sie und bereinigt
  /// die zugehörige lokale dirty-Markierung. Verwaiste Creates (Temp-Zeile ohne
  /// Server-Pendant) werden komplett gelöscht.
  Future<void> discardOp(PendingOp op) async {
    await _db.transaction(() async {
      if (op.opId != null) await _pendingOpsDao.deleteOp(op.opId!);
      await _cleanupAfterDiscard(op);
    });
  }

  Future<void> _cleanupAfterDiscard(PendingOp op) async {
    final id = op.localId;
    switch (op.type) {
      case PendingOpType.taskCreate:
        await _deleteTaskLocal(id);
      case PendingOpType.projectCreate:
        await _deleteProjectLocal(id);
      case PendingOpType.bucketCreate:
        await _deleteBucketLocal(id);
      case PendingOpType.commentCreate:
        await _deleteCommentLocal(id);
      case PendingOpType.labelCreate:
        await _deleteLabelLocal(id);
      case PendingOpType.taskUpdate:
      case PendingOpType.taskMoveBucket:
      case PendingOpType.taskPosition:
        await _clearTaskFlags(id);
      case PendingOpType.taskDelete:
        await _clearTaskFlags(id);
      case PendingOpType.taskSetAssignees:
        await (_db.update(_db.taskAssignees)..where((r) => r.taskId.equals(id)))
            .write(const TaskAssigneesCompanion(isDirty: Value(false)));
      case PendingOpType.taskLabelBulk:
        await (_db.update(_db.taskLabels)..where((r) => r.taskId.equals(id)))
            .write(const TaskLabelsCompanion(isDirty: Value(false)));
      case PendingOpType.projectUpdate:
        await (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
          const ProjectsCompanion(isDirty: Value(false), isDeleted: Value(false)),
        );
      case PendingOpType.bucketUpdate:
      case PendingOpType.bucketDelete:
        await (_db.update(_db.buckets)..where((b) => b.id.equals(id))).write(
          const BucketsCompanion(isDirty: Value(false), isDeleted: Value(false)),
        );
      case PendingOpType.commentUpdate:
      case PendingOpType.commentDelete:
        await (_db.update(_db.taskComments)..where((c) => c.id.equals(id)))
            .write(
              const TaskCommentsCompanion(
                isDirty: Value(false),
                isDeleted: Value(false),
              ),
            );
      case PendingOpType.projectViewUpdate:
      case PendingOpType.userSettings:
      case PendingOpType.attachmentUpload:
      case PendingOpType.attachmentDelete:
        break;
    }
  }

  Future<void> _clearTaskFlags(int id) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        const TasksCompanion(isDirty: Value(false), isDeleted: Value(false)),
      );

  // --- Lokale Anwendung / Rollback (Tasks) -----------------------------------

  Future<void> _patchTaskLocal(TaskDto dto, TaskRow? backup) async {
    final companion = _mapper
        .task(
          dto,
          _now,
          projectId: dto.projectId ?? backup?.projectId ?? 0,
          bucketId: dto.bucketId ?? backup?.bucketId,
        )
        .copyWith(remoteId: Value(backup?.remoteId), isDirty: const Value(true));
    await _db.into(_db.tasks).insertOnConflictUpdate(companion);
  }

  Future<void> _patchTaskMove(
    int id,
    int bucketId,
    double position,
    TaskRow? backup,
  ) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        bucketId: Value(bucketId),
        position: Value(position),
        isDirty: const Value(true),
      ),
    );
  }

  Future<void> _patchTaskPosition(
    int id,
    double position,
    TaskRow? backup,
  ) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(position: Value(position), isDirty: const Value(true)),
    );
  }

  Future<void> _tombstoneTask(int id) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(isDeleted: Value(true), isDirty: Value(true)),
    );
  }

  Future<void> _deleteTaskLocal(int id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    await (_db.delete(_db.taskLabels)..where((r) => r.taskId.equals(id))).go();
    await (_db.delete(_db.taskAssignees)..where((r) => r.taskId.equals(id)))
        .go();
    await (_db.delete(_db.taskComments)..where((c) => c.taskId.equals(id))).go();
  }

  Future<void> _restoreTask(int id, TaskRow? backup) async {
    if (backup == null) {
      await _deleteTaskLocal(id);
    } else {
      await _db
          .into(_db.tasks)
          .insertOnConflictUpdate(backup.toCompanion(false));
    }
  }

  // --- Assignees / Labels ----------------------------------------------------

  Future<List<int>> _assigneeIds(int taskId) async {
    final rows = await (_db.select(
      _db.taskAssignees,
    )..where((r) => r.taskId.equals(taskId))).get();
    return rows.map((r) => r.userId).toList();
  }

  Future<void> _replaceAssignees(int taskId, List<User> users) async {
    await (_db.delete(
      _db.taskAssignees,
    )..where((r) => r.taskId.equals(taskId))).go();
    for (final user in users) {
      await _taskAssigneesDao.upsertLocal(taskId, user.id);
    }
  }

  Future<void> _restoreAssignees(int taskId, List<int> userIds) async {
    await (_db.delete(
      _db.taskAssignees,
    )..where((r) => r.taskId.equals(taskId))).go();
    for (final userId in userIds) {
      await _taskAssigneesDao.upsertFromServer(taskId, userId);
    }
  }

  Future<List<int>> _labelIds(int taskId) async {
    final rows = await (_db.select(
      _db.taskLabels,
    )..where((r) => r.taskId.equals(taskId))).get();
    return rows.map((r) => r.labelId).toList();
  }

  Future<void> _replaceLabels(int taskId, List<Label> labels) async {
    await (_db.delete(
      _db.taskLabels,
    )..where((r) => r.taskId.equals(taskId))).go();
    for (final label in labels) {
      await _taskLabelsDao.upsertLocal(taskId, label.id);
    }
  }

  Future<void> _restoreLabels(int taskId, List<int> labelIds) async {
    await (_db.delete(
      _db.taskLabels,
    )..where((r) => r.taskId.equals(taskId))).go();
    for (final labelId in labelIds) {
      await _taskLabelsDao.upsertFromServer(taskId, labelId);
    }
  }

  Future<void> _deleteLabelLocal(int id) async {
    await (_db.delete(_db.labels)..where((l) => l.id.equals(id))).go();
    await (_db.delete(_db.taskLabels)..where((r) => r.labelId.equals(id))).go();
  }

  // --- Comments --------------------------------------------------------------

  Future<TaskCommentRow?> _commentRow(int id) => (_db.select(
    _db.taskComments,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> _patchCommentLocal(
    TaskCommentDto dto,
    int taskId,
    TaskCommentRow? backup,
  ) async {
    final companion = _mapper
        .taskComment(dto, _now, taskId: taskId)
        .copyWith(remoteId: Value(backup?.remoteId), isDirty: const Value(true));
    await _db.into(_db.taskComments).insertOnConflictUpdate(companion);
  }

  Future<void> _tombstoneComment(int id) async {
    await (_db.update(_db.taskComments)..where((c) => c.id.equals(id))).write(
      const TaskCommentsCompanion(isDeleted: Value(true), isDirty: Value(true)),
    );
  }

  Future<void> _deleteCommentLocal(int id) =>
      (_db.delete(_db.taskComments)..where((c) => c.id.equals(id))).go();

  Future<void> _restoreComment(int id, TaskCommentRow? backup) async {
    if (backup == null) {
      await _deleteCommentLocal(id);
    } else {
      await _db
          .into(_db.taskComments)
          .insertOnConflictUpdate(backup.toCompanion(false));
    }
  }

  // --- Projects --------------------------------------------------------------

  Future<void> _patchProjectLocal(ProjectDto dto, ProjectRow? backup) async {
    final companion = _mapper
        .project(dto, _now)
        .copyWith(remoteId: Value(backup?.remoteId), isDirty: const Value(true));
    await _db.into(_db.projects).insertOnConflictUpdate(companion);
  }

  Future<void> _deleteProjectLocal(int id) =>
      (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();

  Future<void> _restoreProject(int id, ProjectRow? backup) async {
    if (backup == null) {
      await _deleteProjectLocal(id);
    } else {
      await _db
          .into(_db.projects)
          .insertOnConflictUpdate(backup.toCompanion(false));
    }
  }

  // --- Buckets ---------------------------------------------------------------

  Future<void> _patchBucketLocal(
    BucketDto dto,
    int projectId,
    int viewId,
    BucketRow? backup,
  ) async {
    final companion = _mapper
        .bucket(dto, _now, projectId: projectId, viewId: viewId)
        .copyWith(remoteId: Value(backup?.remoteId), isDirty: const Value(true));
    await _db.into(_db.buckets).insertOnConflictUpdate(companion);
  }

  Future<void> _tombstoneBucket(int id) async {
    await (_db.update(_db.buckets)..where((b) => b.id.equals(id))).write(
      const BucketsCompanion(isDeleted: Value(true), isDirty: Value(true)),
    );
  }

  Future<void> _deleteBucketLocal(int id) =>
      (_db.delete(_db.buckets)..where((b) => b.id.equals(id))).go();

  Future<void> _restoreBucket(int id, BucketRow? backup) async {
    if (backup == null) {
      await _deleteBucketLocal(id);
    } else {
      await _db
          .into(_db.buckets)
          .insertOnConflictUpdate(backup.toCompanion(false));
    }
  }

  // --- User-Settings ---------------------------------------------------------

  Future<void> _patchCurrentUserSettings(
    UserSettingsDto settings,
    String? backup,
  ) async {
    if (backup == null) return;
    final map = (jsonDecode(backup) as Map).cast<String, dynamic>();
    map['user_settings'] = settings.toJson();
    await _keyValueDao.set(_kvCurrentUser, jsonEncode(map));
  }

  // --- DTO-Helfer ------------------------------------------------------------

  ProjectDto _projectWithId(ProjectDto base, int id) => ProjectDto(
    id: id,
    title: base.title,
    description: base.description,
    parentProjectId: base.parentProjectId,
    position: base.position,
    color: base.color,
    isArchived: base.isArchived,
    isFavourite: base.isFavourite,
    owner: base.owner,
    views: base.views,
    created: base.created,
    updated: base.updated,
  );

  LabelDto _labelWithId(LabelDto base, int id) => LabelDto(
    id: id,
    title: base.title,
    description: base.description,
    color: base.color,
    created: base.created,
    updated: base.updated,
    createdBy: base.createdBy,
  );
}
