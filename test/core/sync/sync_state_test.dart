import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';

void main() {
  group('SyncState', () {
    test('defaults to idle with no pending ops', () {
      const state = SyncState();

      expect(state.phase, SyncPhase.idle);
      expect(state.pendingOps, 0);
      expect(state.lastSyncAt, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith overrides only the given fields', () {
      const state = SyncState();
      final updated = state.copyWith(phase: SyncPhase.syncing, pendingOps: 3);

      expect(updated.phase, SyncPhase.syncing);
      expect(updated.pendingOps, 3);
      expect(updated.lastSyncAt, isNull);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith keeps unrelated fields untouched', () {
      final syncedAt = DateTime(2026, 1, 1);
      final state = SyncState(
        phase: SyncPhase.idle,
        pendingOps: 2,
        lastSyncAt: syncedAt,
      );

      final updated = state.copyWith(phase: SyncPhase.error);

      expect(updated.phase, SyncPhase.error);
      expect(updated.pendingOps, 2);
      expect(updated.lastSyncAt, syncedAt);
    });

    test('copyWith can explicitly clear lastSyncAt and errorMessage', () {
      final state = SyncState(
        phase: SyncPhase.error,
        lastSyncAt: DateTime(2026, 1, 1),
        errorMessage: 'boom',
      );

      final cleared = state.copyWith(
        phase: SyncPhase.idle,
        clearLastSyncAt: true,
        clearErrorMessage: true,
      );

      expect(cleared.lastSyncAt, isNull);
      expect(cleared.errorMessage, isNull);
    });

    test('equality and hashCode are value-based', () {
      final a = SyncState(
        phase: SyncPhase.error,
        pendingOps: 5,
        errorMessage: 'x',
      );
      final b = SyncState(
        phase: SyncPhase.error,
        pendingOps: 5,
        errorMessage: 'x',
      );
      final c = SyncState(phase: SyncPhase.syncing, pendingOps: 5);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a == c, isFalse);
    });

    test('userInitiated defaults to false', () {
      const state = SyncState();
      expect(state.userInitiated, isFalse);

      const syncing = SyncState(phase: SyncPhase.syncing);
      expect(syncing.userInitiated, isFalse);
    });

    test('copyWith can set userInitiated', () {
      const state = SyncState(phase: SyncPhase.syncing);
      final updated = state.copyWith(userInitiated: true);

      expect(updated.userInitiated, isTrue);
      expect(updated.phase, SyncPhase.syncing);
    });

    test('userInitiated participates in equality and hashCode', () {
      const a = SyncState(phase: SyncPhase.syncing, userInitiated: true);
      const b = SyncState(phase: SyncPhase.syncing, userInitiated: true);
      const c = SyncState(phase: SyncPhase.syncing, userInitiated: false);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a == c, isFalse);
    });
  });
}
