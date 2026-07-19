import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/data_source_provider.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/network/image_disk_cache.dart';
import 'package:vikunja_app/core/offline/attachment_writer.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/core/offline/outbox.dart';
import 'package:vikunja_app/core/offline/push_processor.dart';
import 'package:vikunja_app/core/offline/temp_ids.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';

part 'offline_provider.g.dart';

/// Kapselt die auf der Platte liegenden Local-First-Verzeichnisse.
@Riverpod(keepAlive: true)
LocalFileStorage localFileStorage(Ref ref) => LocalFileStorage();

/// Platten-Cache für authentifizierte Bilder. Beim ersten Zugriff wird eine
/// Eviction (Alter/Größe) angestoßen.
@Riverpod(keepAlive: true)
ImageDiskCache imageDiskCache(Ref ref) {
  final cache = ImageDiskCache(
    dao: ref.watch(imageCacheDaoProvider),
    storage: ref.watch(localFileStorageProvider),
  );
  unawaited(cache.evict());
  return cache;
}

/// Schreibende Fassade für Anhänge (offline-fähiger Upload/Delete).
@Riverpod(keepAlive: true)
AttachmentWriter attachmentWriter(Ref ref) => AttachmentWriter(
  db: ref.watch(appDatabaseProvider),
  dataSource: ref.watch(taskDataSourceProvider),
  outbox: ref.watch(outboxProvider),
  attachmentsDao: ref.watch(taskAttachmentsDaoProvider),
  storage: ref.watch(localFileStorageProvider),
);

@Riverpod(keepAlive: true)
TempIdAllocator tempIdAllocator(Ref ref) => TempIdAllocator(
  db: ref.watch(appDatabaseProvider),
  keyValueDao: ref.watch(keyValueDaoProvider),
);

/// Reaktive Anzahl offener Outbox-Ops.
@Riverpod(keepAlive: true)
Stream<int> pendingOpsCount(Ref ref) =>
    ref.watch(pendingOpsDaoProvider).watchCount();

/// Schreibende Outbox-Fassade. Spiegelt zusätzlich den pending-Zähler aus dem
/// DAO-watch in den [SyncStateNotifier] (setPendingOps).
@Riverpod(keepAlive: true)
Outbox outbox(Ref ref) {
  ref.listen<AsyncValue<int>>(pendingOpsCountProvider, (previous, next) {
    final count = next.valueOrNull;
    if (count != null) {
      ref.read(syncStateNotifierProvider.notifier).setPendingOps(count);
    }
  }, fireImmediately: true);

  return Outbox(
    pendingOpsDao: ref.watch(pendingOpsDaoProvider),
    tempIds: ref.watch(tempIdAllocatorProvider),
  );
}

@Riverpod(keepAlive: true)
PushProcessor pushProcessor(Ref ref) => PushProcessor(
  db: ref.watch(appDatabaseProvider),
  taskDataSource: ref.watch(taskDataSourceProvider),
  taskCommentDataSource: ref.watch(taskCommentDataSourceProvider),
  projectDataSource: ref.watch(projectDataSourceProvider),
  bucketDataSource: ref.watch(bucketDataSourceProvider),
  taskLabelBulkDataSource: ref.watch(taskLabelBulkDataSourceProvider),
  projectViewDataSource: ref.watch(projectViewDataSourceProvider),
  userDataSource: ref.watch(userDataSourceProvider),
  tasksDao: ref.watch(tasksDaoProvider),
  projectsDao: ref.watch(projectsDaoProvider),
  bucketsDao: ref.watch(bucketsDaoProvider),
  taskCommentsDao: ref.watch(taskCommentsDaoProvider),
  pendingOpsDao: ref.watch(pendingOpsDaoProvider),
  keyValueDao: ref.watch(keyValueDaoProvider),
);
