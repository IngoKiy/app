import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';

import 'test_database.dart';

PendingOpsCompanion _op(String entityType, int localId) =>
    PendingOpsCompanion.insert(
      entityType: entityType,
      localId: localId,
      opType: 'create',
      payloadJson: '{}',
      createdAt: '2026-07-19T00:00:00.000Z',
    );

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('enqueue + nextBatch liefert Ops in FIFO-Reihenfolge', () async {
    await db.pendingOpsDao.enqueue(_op('task', 1));
    await db.pendingOpsDao.enqueue(_op('task', 2));
    await db.pendingOpsDao.enqueue(_op('project', 3));

    final batch = await db.pendingOpsDao.nextBatch(limit: 2);

    expect(batch.length, 2);
    expect(batch[0].localId, 1);
    expect(batch[1].localId, 2);
    expect(batch[0].opId, lessThan(batch[1].opId));
  });

  test('nextBatch respektiert das limit', () async {
    for (var i = 0; i < 5; i++) {
      await db.pendingOpsDao.enqueue(_op('task', i));
    }

    final batch = await db.pendingOpsDao.nextBatch(limit: 3);
    expect(batch.length, 3);
  });

  test('watchCount zählt offene Ops', () async {
    expect(await db.pendingOpsDao.watchCount().first, 0);

    final opId = await db.pendingOpsDao.enqueue(_op('task', 1));
    expect(await db.pendingOpsDao.watchCount().first, 1);

    await db.pendingOpsDao.deleteOp(opId);
    expect(await db.pendingOpsDao.watchCount().first, 0);
  });

  test('markError erhöht retryCount und setzt lastError', () async {
    final opId = await db.pendingOpsDao.enqueue(_op('task', 1));

    await db.pendingOpsDao.markError(opId, 'Netzwerkfehler');
    await db.pendingOpsDao.markError(opId, 'Netzwerkfehler erneut');

    final batch = await db.pendingOpsDao.nextBatch();
    final row = batch.firstWhere((o) => o.opId == opId);
    expect(row.retryCount, 2);
    expect(row.lastError, 'Netzwerkfehler erneut');
  });
}
