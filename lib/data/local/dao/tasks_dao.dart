import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/tasks_table.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<TaskRow>> watchTasksByProject(int projectId) =>
      (select(tasks)..where(
            (t) => t.projectId.equals(projectId) & t.isDeleted.equals(false),
          ))
          .watch();

  Stream<List<TaskRow>> watchTasksByBucket(int bucketId) =>
      (select(tasks)..where(
            (t) => t.bucketId.equals(bucketId) & t.isDeleted.equals(false),
          ))
          .watch();

  Stream<TaskRow?> watchTask(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<TaskRow?> getById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Merge vom Server, siehe [ProjectsDao.upsertFromServer].
  Future<void> upsertFromServer(TasksCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      tasks,
    )..where((t) => t.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(tasks).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  /// Siehe [ProjectsDao.upsertLocal].
  Future<void> upsertLocal(TasksCompanion data) async {
    await into(
      tasks,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  /// Siehe [ProjectsDao.deleteMissingClean].
  Future<int> deleteMissingClean(Iterable<int> keepRemoteIds) {
    return (delete(tasks)..where(
          (t) =>
              t.isDirty.equals(false) &
              t.remoteId.isNotNull() &
              t.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(tasks).go();
}
