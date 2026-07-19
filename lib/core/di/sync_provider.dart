import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/data_source_provider.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/core/sync/sync_service.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';

part 'sync_provider.g.dart';

/// Stellt den [SyncService] bereit und verkabelt den automatischen Pull bei
/// Wiederherstellung der Verbindung (offline -> online).
@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final service = SyncService(
    serverDataSource: ref.watch(serverDataSourceProvider),
    userDataSource: ref.watch(userDataSourceProvider),
    labelDataSource: ref.watch(labelDataSourceProvider),
    projectDataSource: ref.watch(projectDataSourceProvider),
    taskDataSource: ref.watch(taskDataSourceProvider),
    bucketDataSource: ref.watch(bucketDataSourceProvider),
    taskCommentDataSource: ref.watch(taskCommentDataSourceProvider),
    projectsDao: ref.watch(projectsDaoProvider),
    tasksDao: ref.watch(tasksDaoProvider),
    bucketsDao: ref.watch(bucketsDaoProvider),
    labelsDao: ref.watch(labelsDaoProvider),
    usersDao: ref.watch(usersDaoProvider),
    taskLabelsDao: ref.watch(taskLabelsDaoProvider),
    taskAssigneesDao: ref.watch(taskAssigneesDaoProvider),
    taskCommentsDao: ref.watch(taskCommentsDaoProvider),
    keyValueDao: ref.watch(keyValueDaoProvider),
    syncState: ref.watch(syncStateNotifierProvider.notifier),
  );

  // Trigger: sobald die Verbindung von offline auf online wechselt, einen
  // Voll-Pull anstoßen (Single-Flight verhindert Doppelläufe).
  ref.listen<bool>(connectivityStatusProvider, (previous, next) {
    if (previous == false && next == true) {
      unawaited(service.pullAll());
    }
  });

  return service;
}
