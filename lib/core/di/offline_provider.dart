import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/data_source_provider.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/offline/offline_writer.dart';
import 'package:vikunja_app/core/offline/op_executor.dart';
import 'package:vikunja_app/core/offline/outbox.dart';
import 'package:vikunja_app/core/offline/pending_op.dart';
import 'package:vikunja_app/core/offline/push_processor.dart';
import 'package:vikunja_app/core/offline/temp_ids.dart';
import 'package:vikunja_app/core/sync/sync_state_provider.dart';

part 'offline_provider.g.dart';

@Riverpod(keepAlive: true)
TempIdAllocator tempIdAllocator(Ref ref) => TempIdAllocator(
  db: ref.watch(appDatabaseProvider),
  keyValueDao: ref.watch(keyValueDaoProvider),
);

/// Reaktive Anzahl offener Outbox-Ops.
@Riverpod(keepAlive: true)
Stream<int> pendingOpsCount(Ref ref) =>
    ref.watch(pendingOpsDaoProvider).watchCount();

/// Reaktive Gesamtliste der Outbox-Ops (für das Sync-Status-Sheet).
@riverpod
Stream<List<PendingOp>> pendingOpsList(Ref ref) => ref
    .watch(pendingOpsDaoProvider)
    .watchAll()
    .map((rows) => rows.map(PendingOp.fromRow).toList());

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

/// Geteilter Sende-/Migrations-Kern für Push und optimistische Writes.
@Riverpod(keepAlive: true)
OpExecutor opExecutor(Ref ref) => OpExecutor(
  db: ref.watch(appDatabaseProvider),
  taskDataSource: ref.watch(taskDataSourceProvider),
  taskCommentDataSource: ref.watch(taskCommentDataSourceProvider),
  projectDataSource: ref.watch(projectDataSourceProvider),
  bucketDataSource: ref.watch(bucketDataSourceProvider),
  taskLabelBulkDataSource: ref.watch(taskLabelBulkDataSourceProvider),
  labelDataSource: ref.watch(labelDataSourceProvider),
  projectViewDataSource: ref.watch(projectViewDataSourceProvider),
  userDataSource: ref.watch(userDataSourceProvider),
  tasksDao: ref.watch(tasksDaoProvider),
  projectsDao: ref.watch(projectsDaoProvider),
  bucketsDao: ref.watch(bucketsDaoProvider),
  labelsDao: ref.watch(labelsDaoProvider),
  taskCommentsDao: ref.watch(taskCommentsDaoProvider),
  pendingOpsDao: ref.watch(pendingOpsDaoProvider),
  keyValueDao: ref.watch(keyValueDaoProvider),
);

/// Zentrale Fassade für alle schreibenden Operationen (local-first + Outbox).
@Riverpod(keepAlive: true)
OfflineWriter offlineWriter(Ref ref) => OfflineWriter(
  db: ref.watch(appDatabaseProvider),
  outbox: ref.watch(outboxProvider),
  executor: ref.watch(opExecutorProvider),
  tasksDao: ref.watch(tasksDaoProvider),
  projectsDao: ref.watch(projectsDaoProvider),
  bucketsDao: ref.watch(bucketsDaoProvider),
  labelsDao: ref.watch(labelsDaoProvider),
  taskCommentsDao: ref.watch(taskCommentsDaoProvider),
  taskLabelsDao: ref.watch(taskLabelsDaoProvider),
  taskAssigneesDao: ref.watch(taskAssigneesDaoProvider),
  pendingOpsDao: ref.watch(pendingOpsDaoProvider),
  keyValueDao: ref.watch(keyValueDaoProvider),
);

@Riverpod(keepAlive: true)
PushProcessor pushProcessor(Ref ref) => PushProcessor(
  db: ref.watch(appDatabaseProvider),
  taskDataSource: ref.watch(taskDataSourceProvider),
  taskCommentDataSource: ref.watch(taskCommentDataSourceProvider),
  projectDataSource: ref.watch(projectDataSourceProvider),
  bucketDataSource: ref.watch(bucketDataSourceProvider),
  taskLabelBulkDataSource: ref.watch(taskLabelBulkDataSourceProvider),
  labelDataSource: ref.watch(labelDataSourceProvider),
  projectViewDataSource: ref.watch(projectViewDataSourceProvider),
  userDataSource: ref.watch(userDataSourceProvider),
  tasksDao: ref.watch(tasksDaoProvider),
  projectsDao: ref.watch(projectsDaoProvider),
  bucketsDao: ref.watch(bucketsDaoProvider),
  labelsDao: ref.watch(labelsDaoProvider),
  taskCommentsDao: ref.watch(taskCommentsDaoProvider),
  pendingOpsDao: ref.watch(pendingOpsDaoProvider),
  keyValueDao: ref.watch(keyValueDaoProvider),
  executor: ref.watch(opExecutorProvider),
);
