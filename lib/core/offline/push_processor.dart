import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/offline/op_executor.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
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

// Re-Export, damit bestehende Importe (`kvTempIdMapping`) weiter funktionieren.
export 'package:vikunja_app/core/offline/op_executor.dart' show kvTempIdMapping;

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
///
/// Die eigentliche Sende-/Migrations-Logik steckt im [OpExecutor], den sich der
/// Processor mit dem `OfflineWriter` teilt.
class PushProcessor {
  PushProcessor({
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
    OpExecutor? executor,
  }) : _db = db,
       _pendingOpsDao = pendingOpsDao,
       _executor =
           executor ??
           OpExecutor(
             db: db,
             taskDataSource: taskDataSource,
             taskCommentDataSource: taskCommentDataSource,
             projectDataSource: projectDataSource,
             bucketDataSource: bucketDataSource,
             taskLabelBulkDataSource: taskLabelBulkDataSource,
             labelDataSource: labelDataSource,
             projectViewDataSource: projectViewDataSource,
             userDataSource: userDataSource,
             tasksDao: tasksDao,
             projectsDao: projectsDao,
             bucketsDao: bucketsDao,
             labelsDao: labelsDao,
             taskCommentsDao: taskCommentsDao,
             pendingOpsDao: pendingOpsDao,
             keyValueDao: keyValueDao,
             mapper: mapper,
           );

  final AppDatabase _db;
  final PendingOpsDao _pendingOpsDao;
  final OpExecutor _executor;

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
    final mapping = await _executor.loadMapping();
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
        resp = await _executor.dispatch(op, resolvedRefs, primaryId);
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

  Future<void> _onSuccess(
    PendingOp op,
    dynamic body,
    int? primaryId,
    Map<int, int> mapping,
  ) async {
    final now = DateTime.now();
    if (op.type.isCreate) {
      final serverId = _executor.serverIdOf(op.type, body);
      mapping[op.localId] = serverId;
      await _db.transaction(() async {
        // (a) Mapping persistieren (Crash-Sicherheit).
        await _executor.saveMapping(mapping);
        // (b) DB-Zeile + abhängige FK-Spalten von Temp-ID auf Server-ID.
        await _executor.migrateEntity(op.type, op.localId, serverId);
        // (c) restliche Outbox-Payloads umschreiben.
        await _executor.rewritePendingOps(op.localId, serverId);
        // (e) Server-Response upserten (dirty ist durch (b) schon gelöscht).
        await _executor.upsertCreated(op, body, serverId, now);
        // (d) Op löschen.
        await _pendingOpsDao.deleteOp(op.opId!);
      });
    } else {
      await _db.transaction(() async {
        await _executor.postNonCreate(op, body, primaryId!, now);
        await _pendingOpsDao.deleteOp(op.opId!);
      });
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
        await (_db.delete(
          _db.taskAttachments,
        )..where((a) => a.taskId.equals(temp))).go();
      });
      cancelled.add(createOpId);
      cancelled.add(op.opId!);
    }
    return cancelled;
  }
}
