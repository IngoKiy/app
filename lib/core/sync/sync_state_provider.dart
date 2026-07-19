import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/core/sync/sync_state.dart';

part 'sync_state_provider.g.dart';

/// Global, app-wide sync/offline status.
///
/// This provider only exposes the *interface*: a stable [SyncState] plus a
/// handful of setters. The actual population (starting a sync round,
/// reporting progress/pending-op counts, surfacing errors) is the
/// responsibility of the future `SyncService` (outbox/pull-sync milestone).
/// Until that lands, the phase simply tracks [ConnectivityStatus] so the
/// offline banner already works end-to-end.
@Riverpod(keepAlive: true)
class SyncStateNotifier extends _$SyncStateNotifier {
  @override
  SyncState build() {
    final isOnline = ref.watch(connectivityStatusProvider);
    return SyncState(phase: isOnline ? SyncPhase.idle : SyncPhase.offline);
  }

  /// Marks a sync round (pull and/or push) as currently in progress.
  void setSyncing() {
    state = state.copyWith(phase: SyncPhase.syncing, clearErrorMessage: true);
  }

  /// Marks the sync engine as idle, optionally recording when the last
  /// successful sync round completed.
  void setIdle({DateTime? lastSyncAt}) {
    state = state.copyWith(
      phase: SyncPhase.idle,
      lastSyncAt: lastSyncAt,
      clearErrorMessage: true,
    );
  }

  /// Records that the last sync attempt failed with [message].
  void setError(String message) {
    state = state.copyWith(phase: SyncPhase.error, errorMessage: message);
  }

  /// Updates the number of operations still queued in the outbox.
  void setPendingOps(int count) {
    state = state.copyWith(pendingOps: count);
  }
}
