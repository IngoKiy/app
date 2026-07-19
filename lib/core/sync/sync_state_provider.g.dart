// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncStateNotifierHash() => r'a816678828b538d6ca4806a930048274b560c070';

/// Global, app-wide sync/offline status.
///
/// This provider only exposes the *interface*: a stable [SyncState] plus a
/// handful of setters. The actual population (starting a sync round,
/// reporting progress/pending-op counts, surfacing errors) is the
/// responsibility of the future `SyncService` (outbox/pull-sync milestone).
/// Until that lands, the phase simply tracks [ConnectivityStatus] so the
/// offline banner already works end-to-end.
///
/// Copied from [SyncStateNotifier].
@ProviderFor(SyncStateNotifier)
final syncStateNotifierProvider =
    NotifierProvider<SyncStateNotifier, SyncState>.internal(
      SyncStateNotifier.new,
      name: r'syncStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncStateNotifier = Notifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
