import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';

part 'connectivity_provider.g.dart';

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
@Riverpod(keepAlive: true)
class ConnectivityStatus extends _$ConnectivityStatus {
  static const _debounceDuration = Duration(seconds: 2);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;

  @override
  bool build() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _debounce?.cancel();
    });

    // Kick off an initial check; until it resolves we optimistically assume
    // online so the app doesn't flash an offline banner on every cold start.
    unawaited(_checkInitialConnectivity());

    return true;
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChanged(results);
    } catch (_) {
      // Platform channel unavailable (e.g. some test hosts) — keep the
      // optimistic default.
    }
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final hasNetworkInterface = results.any(
      (result) => result != ConnectivityResult.none,
    );

    _debounce?.cancel();

    if (!hasNetworkInterface) {
      state = false;
      return;
    }

    _debounce = Timer(_debounceDuration, _confirmOnline);
  }

  Future<void> _confirmOnline() async {
    try {
      final serverRepository = ref.read(serverRepositoryProvider);
      final response = await serverRepository.getInfo();
      state = response.isSuccessful;
    } catch (_) {
      // No way to reach the server repository / issue the ping at all —
      // fall back to trusting connectivity_plus.
      state = true;
    }
  }
}
