import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/offline/temp_ids.dart';
import 'package:vikunja_app/data/local/dao/pending_ops_dao.dart';

/// Schreibende Fassade der Push-Sync-Outbox.
///
/// [enqueue] persistiert eine [PendingOp] in FIFO-Reihenfolge (opId
/// autoIncrement). Die Aktualisierung des `pendingOps`-Zählers im
/// [SyncStateNotifier] erfolgt über die watchCount-Verkabelung im
/// `offlineProvider` — nicht hier, damit die Outbox seiteneffektfrei bleibt.
class Outbox {
  Outbox({
    required PendingOpsDao pendingOpsDao,
    required TempIdAllocator tempIds,
  }) : _dao = pendingOpsDao,
       _tempIds = tempIds;

  final PendingOpsDao _dao;
  final TempIdAllocator _tempIds;

  /// Persistiert [op] und liefert die vergebene `opId`.
  Future<int> enqueue(PendingOp op) => _dao.enqueue(op.toCompanion());

  /// Enqueue mit Last-Write-Wins-Koaleszierung für Voll-Updates (Autosave):
  /// Ist die jüngste wartende Op derselben Entität eine Op gleichen Typs, wird
  /// sie gelöscht und [op] ans Queue-Ende gesetzt, statt die Queue mit
  /// Zwischenständen wachsen zu lassen. Nur die jüngste Op wird ersetzt —
  /// liegt eine andersartige Op (z.B. taskSetAssignees) dahinter, bleibt die
  /// FIFO-Reihenfolge unangetastet und [op] wird normal angehängt.
  ///
  /// Delete + Insert (statt Payload-Update in place) ist bewusst: ein gerade
  /// laufender Push-Durchlauf hält die alte Op bereits im Speicher; sein
  /// deleteOp nach Erfolg trifft dann die schon gelöschte Zeile statt der
  /// neuen Op — der neue Stand geht nie verloren.
  Future<int> enqueueCoalesced(PendingOp op) {
    return _dao.transaction(() async {
      final latest = await _dao.latestForEntity(op.type.entityType, op.localId);
      if (latest != null && latest.opType == op.type.name) {
        await _dao.deleteOp(latest.opId);
      }
      return _dao.enqueue(op.toCompanion());
    });
  }

  /// Nächste negative Temp-ID für eine offline erzeugte Entität.
  Future<int> nextTempId() => _tempIds.next();
}
