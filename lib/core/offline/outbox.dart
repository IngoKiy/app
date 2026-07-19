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
  Outbox({required PendingOpsDao pendingOpsDao, required TempIdAllocator tempIds})
    : _dao = pendingOpsDao,
      _tempIds = tempIds;

  final PendingOpsDao _dao;
  final TempIdAllocator _tempIds;

  /// Persistiert [op] und liefert die vergebene `opId`.
  Future<int> enqueue(PendingOp op) => _dao.enqueue(op.toCompanion());

  /// Nächste negative Temp-ID für eine offline erzeugte Entität.
  Future<int> nextTempId() => _tempIds.next();
}
