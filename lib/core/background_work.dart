import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/di/sync_provider.dart';
import 'package:vikunja_app/domain/entities/auth_model.dart';
import 'package:vikunja_app/presentation/manager/notifications.dart';
import 'package:vikunja_app/presentation/manager/widget_controller.dart';
import 'package:workmanager/workmanager.dart';

@pragma("vm:entry-point")
Future<void> widgetCallback(Uri? uri) async {
  if (uri?.host == "completetask") {
    String? taskID = uri?.queryParameters['taskID'];
    if (taskID != null) {
      await completeTask(taskID);
    } else {
      developer.log("No TaskID provided for widget");
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  if (kIsWeb) {
    return;
  }
  Workmanager().executeTask((task, inputData) async {
    developer.log("Native called background task: $task");

    switch (task) {
      case "update-tasks":
        return updateTasks();
      default:
        return Future.value(true);
    }
  });
}

/// Aktualisiert das Home-Widget und plant Fälligkeits-/Reminder-
/// Benachrichtigungen (Meilenstein M3/F2, siehe docs/offline.md).
///
/// Läuft in einer eigenen Headless-Isolate (WorkManager-Callback) ohne
/// Zugriff auf den App-ProviderContainer. Baut sich deshalb einen eigenen,
/// kurzlebigen [ProviderContainer] auf — dieselben DI-Provider wie der
/// Haupt-Isolate (core/di/*), verkabelt analog zu init_controller.dart:
/// `authDataProvider` wird aus dem sicheren Speicher gesetzt, danach liefert
/// `clientProviderProvider`/`syncServiceProvider` einen einsatzbereiten
/// Client. Der Container wird nach diesem einen Durchlauf wieder verworfen
/// (kein `keepAlive` über den Callback hinaus nötig/möglich).
///
/// Reihenfolge: zuerst ein Best-Effort-Voll-Pull, der die lokale DB
/// aktualisiert (Fehler/Offline werden toleriert, `SyncService.pullAll()`
/// wirft dafür ohnehin nicht); danach werden Widget-Daten und
/// Notifications immer aus der (ggf. weiterhin alten) DB aufgebaut. Damit
/// funktioniert der Job auch offline (zeigt den letzten bekannten Stand)
/// und aktualisiert online zusätzlich die DB für Tasks, die auf dem Server
/// angelegt/geändert wurden, aber noch nicht in der App geladen sind.
Future<bool> updateTasks() async {
  final container = ProviderContainer();
  try {
    final settingsRepo = container.read(settingsRepositoryProvider);
    final base = await settingsRepo.getServer();
    final refreshToken = await settingsRepo.getRefreshToken();

    if (base == null || refreshToken == null) {
      return true;
    }

    container.read(authDataProvider.notifier).set(AuthModel(base));
    final ignoreCertificates = await settingsRepo.getIgnoreCertificates();
    container.read(clientProviderProvider).setIgnoreCerts(ignoreCertificates);

    try {
      await container.read(syncServiceProvider).pullAll();
    } catch (e, s) {
      developer.log(
        "Background pull failed (offline?):",
        error: e,
        stackTrace: s,
      );
    }

    final tasksDao = container.read(tasksDaoProvider);
    await updateWidget(tasksDao: tasksDao);

    // Headless-Isolate: eigene Zeitzonendatenbank nötig (Isolat teilt keine
    // Dart-Statics mit dem Haupt-Isolat), sonst schlägt tz.getLocation() in
    // scheduleNotification() fehl.
    tz.initializeTimeZones();
    final notificationHandler = NotificationHandler();
    await notificationHandler.initNotifications();
    await notificationHandler.scheduleDueNotifications(tasksDao);
  } finally {
    container.dispose();
  }

  return true;
}
