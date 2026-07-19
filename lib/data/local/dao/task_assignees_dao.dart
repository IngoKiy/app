import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/task_assignees_table.dart';

part 'task_assignees_dao.g.dart';

@DriftAccessor(tables: [TaskAssignees])
class TaskAssigneesDao extends DatabaseAccessor<AppDatabase>
    with _$TaskAssigneesDaoMixin {
  TaskAssigneesDao(super.db);

  Stream<List<TaskAssigneeRow>> watchAssigneesForTask(int taskId) =>
      (select(taskAssignees)..where((t) => t.taskId.equals(taskId))).watch();

  /// Siehe [TaskLabelsDao.upsertFromServer].
  Future<void> upsertFromServer(int taskId, int userId) async {
    final existing = await (select(taskAssignees)..where(
          (t) => t.taskId.equals(taskId) & t.userId.equals(userId),
        ))
        .getSingleOrNull();
    if (existing != null && existing.isDirty) return;

    await into(taskAssignees).insertOnConflictUpdate(
      TaskAssigneesCompanion.insert(
        taskId: taskId,
        userId: userId,
        isDirty: const Value(false),
      ),
    );
  }

  Future<void> upsertLocal(int taskId, int userId) async {
    await into(taskAssignees).insertOnConflictUpdate(
      TaskAssigneesCompanion.insert(
        taskId: taskId,
        userId: userId,
        isDirty: const Value(true),
      ),
    );
  }

  Future<int> deleteMissingCleanForTask(
    int taskId,
    Iterable<int> keepUserIds,
  ) {
    return (delete(taskAssignees)..where(
          (t) =>
              t.taskId.equals(taskId) &
              t.isDirty.equals(false) &
              t.userId.isNotIn(keepUserIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(taskAssignees).go();
}
