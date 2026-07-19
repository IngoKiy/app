/// Pure state model for the global sync/offline status.
///
/// This file intentionally has **no** dependency on the local database
/// (Drift) — it is a stable contract shared between the connectivity
/// tracking (this package), the sync service (populated in a later
/// milestone) and the UI banner.
library;

/// The high-level phase the app's sync engine is currently in.
enum SyncPhase {
  /// Online and nothing to do (or a sync completed successfully).
  idle,

  /// A sync round (pull and/or push) is currently in progress.
  syncing,

  /// The device has no confirmed connection to the configured server.
  offline,

  /// The last sync attempt failed with an error.
  error,
}

/// Snapshot of the app's sync/offline status, as surfaced by
/// [lib/core/sync/sync_state_provider.dart] and consumed by
/// [lib/presentation/widgets/sync_status_banner.dart].
class SyncState {
  final SyncPhase phase;

  /// Number of local operations (creates/updates/deletes) that are queued
  /// in the outbox and still waiting to be pushed to the server.
  final int pendingOps;

  /// Timestamp of the last successful sync round, if any.
  final DateTime? lastSyncAt;

  /// Human-readable error message set when [phase] is [SyncPhase.error].
  final String? errorMessage;

  /// Whether the current/last [SyncPhase.syncing] round was triggered by the
  /// user (pull-to-refresh, "sync now" in the sync sheet) rather than
  /// automatically (app start, reconnect, background work). Only meaningful
  /// while [phase] is [SyncPhase.syncing]; always `false` otherwise.
  final bool userInitiated;

  const SyncState({
    this.phase = SyncPhase.idle,
    this.pendingOps = 0,
    this.lastSyncAt,
    this.errorMessage,
    this.userInitiated = false,
  });

  SyncState copyWith({
    SyncPhase? phase,
    int? pendingOps,
    DateTime? lastSyncAt,
    String? errorMessage,
    bool? userInitiated,
    bool clearLastSyncAt = false,
    bool clearErrorMessage = false,
  }) {
    return SyncState(
      phase: phase ?? this.phase,
      pendingOps: pendingOps ?? this.pendingOps,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      userInitiated: userInitiated ?? this.userInitiated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncState &&
          runtimeType == other.runtimeType &&
          phase == other.phase &&
          pendingOps == other.pendingOps &&
          lastSyncAt == other.lastSyncAt &&
          errorMessage == other.errorMessage &&
          userInitiated == other.userInitiated;

  @override
  int get hashCode =>
      Object.hash(phase, pendingOps, lastSyncAt, errorMessage, userInitiated);

  @override
  String toString() =>
      'SyncState(phase: $phase, pendingOps: $pendingOps, '
      'lastSyncAt: $lastSyncAt, errorMessage: $errorMessage, '
      'userInitiated: $userInitiated)';
}
