// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityStatusHash() =>
    r'4bb11c2eeb31d0f9620a26d051103fd14b30cfef';

/// Tracks whether the app currently has a usable connection.
///
/// `connectivity_plus` only reports whether the device is attached to a
/// network interface (Wi-Fi/mobile/etc.) — it can't tell us whether the
/// configured Vikunja server is actually reachable (captive portals, VPNs,
/// server downtime, wrong address, ...). So whenever the OS reports that a
/// connection came back, we debounce briefly and then send a confirmation
/// ping (`GET /info`) through [serverRepositoryProvider] before flipping
/// back to "online". Going offline is applied immediately (no need to wait
/// for confirmation — the OS signal is trustworthy for that direction).
///
/// If the confirmation ping cannot be attempted at all (e.g. no server
/// repository available), we fall back to trusting the raw connectivity
/// signal.
///
/// Copied from [ConnectivityStatus].
@ProviderFor(ConnectivityStatus)
final connectivityStatusProvider =
    NotifierProvider<ConnectivityStatus, bool>.internal(
      ConnectivityStatus.new,
      name: r'connectivityStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectivityStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConnectivityStatus = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
