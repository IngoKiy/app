import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/sync/sync_service.dart';
import 'package:vikunja_app/data/models/server_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';
import 'package:vikunja_app/domain/entities/auth_model.dart';
import 'package:vikunja_app/domain/entities/server.dart';
import 'package:vikunja_app/domain/entities/version.dart';

sealed class InitOutcome {
  const InitOutcome();
}

class InitGoLogin extends InitOutcome {
  final bool loginExpired;
  final Version? serverVersion;

  const InitGoLogin({this.loginExpired = false, this.serverVersion});
}

class InitGoHome extends InitOutcome {
  final Version? serverVersion;

  const InitGoHome({required this.serverVersion});
}

final initControllerProvider = FutureProvider<InitOutcome>((ref) {
  return _runInit(ref).timeout(const Duration(seconds: 3));
});

Future<InitOutcome> _runInit(Ref ref) async {
  final settingsRepo = ref.read(settingsRepositoryProvider);

  final server = await settingsRepo.getServer();
  if (server == null) {
    return const InitGoLogin();
  }

  ref.read(authDataProvider.notifier).set(AuthModel(server));

  final token = await settingsRepo.getUserToken();

  // Offline-fähiger Start: liegen Server-URL + Token vor und existiert ein
  // gespeicherter Nutzer in der DB, gehen wir sofort auf Home (aus der DB) und
  // synchronisieren im Hintergrund. Der 3s-Timeout wird so nicht blockiert.
  if (token != null) {
    final offline = await _tryOfflineHome(ref);
    if (offline != null) return offline;
  }

  // --- Bisheriger Online-Weg -------------------------------------------------
  Version? serverVersion;
  final Response<Server> info = await ref
      .read(serverRepositoryProvider)
      .getInfo();
  if (info.isSuccessful) {
    Sentry.configureScope(
      (scope) =>
          scope.setTag('server.version', info.toSuccess().body.version ?? '-'),
    );

    serverVersion = Version.fromServerString(
      info.toSuccess().body.version ?? '-',
    );
  }

  if (token == null) {
    return InitGoLogin(serverVersion: serverVersion);
  }

  await settingsRepo.getRefreshToken();

  final userResponse = await ref.read(userRepositoryProvider).getCurrentUser();

  if (userResponse.isSuccessful) {
    ref.read(currentUserProvider.notifier).set(userResponse.toSuccess().body);
    // Nach erfolgreichem Online-Init einmal Hintergrund-Sync anstoßen.
    _triggerBackgroundSync(ref);
    return InitGoHome(serverVersion: serverVersion);
  }

  if (userResponse.isError) {
    final err = userResponse.toError();
    if (err.statusCode == 401) {
      await settingsRepo.saveUserToken(null);
      await settingsRepo.saveRefreshToken(null);
      return InitGoLogin(loginExpired: true, serverVersion: serverVersion);
    }

    throw err.error['message'] ?? err.error;
  }

  throw userResponse.toException().exception;
}

/// Versucht, den Start rein aus der DB zu bedienen. Rückgabe null bedeutet
/// "kein lokaler Nutzer vorhanden" -> Aufrufer nutzt den Online-Weg.
Future<InitOutcome?> _tryOfflineHome(Ref ref) async {
  final keyValueDao = ref.read(keyValueDaoProvider);

  final userJson = await keyValueDao.get(kvCurrentUser);
  if (userJson == null) return null;

  try {
    final user = UserDto.fromJson(
      jsonDecode(userJson) as Map<String, dynamic>,
    ).toDomain();
    ref.read(currentUserProvider.notifier).set(user);
  } catch (_) {
    return null;
  }

  // Server-Version aus gespeicherter Server-Info (optional, für den
  // Versions-Check der UI).
  Version? serverVersion;
  final infoJson = await keyValueDao.get(kvServerInfo);
  if (infoJson != null) {
    try {
      final v = ServerDto.fromJson(
        jsonDecode(infoJson) as Map<String, dynamic>,
      ).version;
      if (v != null) serverVersion = Version.fromServerString(v);
    } catch (_) {
      // Ungültige Server-Info ignorieren.
    }
  }

  // Hintergrund-Sync (nicht awaiten, Fehler still — Offline-Fall).
  _triggerBackgroundSync(ref);

  return InitGoHome(serverVersion: serverVersion);
}

/// Stößt einen Hintergrund-Sync an, ohne den Init je scheitern zu lassen
/// (Offline, Testumgebung ohne Plattform-Kanäle etc.).
void _triggerBackgroundSync(Ref ref) {
  try {
    unawaited(ref.read(syncServiceProvider).syncNow());
  } catch (_) {
    // Bewusst still.
  }
}
