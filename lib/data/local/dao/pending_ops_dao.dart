import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/pending_ops_table.dart';

part 'pending_ops_dao.g.dart';

/// Grundgerüst der Push-Sync-Outbox. Die eigentliche Verarbeitung
/// (Abhängigkeitssortierung, Temp-ID-Mapping) folgt in M2.
@DriftAccessor(tables: [PendingOps])
class PendingOpsDao extends DatabaseAccessor<AppDatabase>
    with _$PendingOpsDaoMixin {
  PendingOpsDao(super.db);

  Future<int> enqueue(PendingOpsCompanion op) => into(pendingOps).insert(op);

  Stream<int> watchCount() {
    final count = countAll();
    return (selectOnly(pendingOps)..addColumns([count]))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  /// Reaktive Gesamtliste in FIFO-Reihenfolge (für das Sync-Status-Sheet).
  Stream<List<PendingOpRow>> watchAll() =>
      (select(pendingOps)
            ..orderBy([(t) => OrderingTerm(expression: t.opId)]))
          .watch();

  /// Jüngste wartende Op derselben Entität (höchste [opId]) — Grundlage der
  /// Enqueue-Koaleszierung von Voll-Updates.
  Future<PendingOpRow?> latestForEntity(String entityType, int localId) {
    return (select(pendingOps)
          ..where(
            (t) => t.entityType.equals(entityType) & t.localId.equals(localId),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.opId, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Nächste Charge in FIFO-Reihenfolge (aufsteigend nach [opId]).
  Future<List<PendingOpRow>> nextBatch({int limit = 20}) {
    return (select(pendingOps)
          ..orderBy([(t) => OrderingTerm(expression: t.opId)])
          ..limit(limit))
        .get();
  }

  Future<void> deleteOp(int opId) =>
      (delete(pendingOps)..where((t) => t.opId.equals(opId))).go();

  Future<void> markError(int opId, String error) async {
    final row = await (select(
      pendingOps,
    )..where((t) => t.opId.equals(opId))).getSingleOrNull();
    if (row == null) return;
    await (update(pendingOps)..where((t) => t.opId.equals(opId))).write(
      PendingOpsCompanion(
        lastError: Value(error),
        retryCount: Value(row.retryCount + 1),
      ),
    );
  }

  Future<int> wipeAll() => delete(pendingOps).go();
}
