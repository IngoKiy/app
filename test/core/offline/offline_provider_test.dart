import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';
import 'package:vikunja_app/data/local/database.dart';

class _StubConnectivity extends ConnectivityStatus {
  @override
  bool build() => true;
}

PendingOp _op(int localId) => PendingOp(
  type: PendingOpType.taskUpdate,
  localId: localId,
  payload: const {'id': 1, 'title': 'x'},
  createdAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        connectivityStatusProvider.overrideWith(() => _StubConnectivity()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('TempIdAllocator vergibt fortlaufend negative IDs', () async {
    final alloc = container.read(tempIdAllocatorProvider);
    expect(await alloc.next(), -1);
    expect(await alloc.next(), -2);
    expect(await alloc.next(), -3);
  });

  test('Outbox.enqueue erhöht pendingOps im SyncStateNotifier', () async {
    // Outbox lesen aktiviert die watchCount-Verkabelung.
    final outbox = container.read(outboxProvider);

    await outbox.enqueue(_op(1));
    await outbox.enqueue(_op(2));

    // Auf die Drift-Stream-Emission warten.
    var count = 0;
    for (var i = 0; i < 50; i++) {
      count = container.read(syncStateNotifierProvider).pendingOps;
      if (count == 2) break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(count, 2);
  });
}
