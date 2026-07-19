import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/task_comments_table.dart';

part 'task_comments_dao.g.dart';

@DriftAccessor(tables: [TaskComments])
class TaskCommentsDao extends DatabaseAccessor<AppDatabase>
    with _$TaskCommentsDaoMixin {
  TaskCommentsDao(super.db);

  Stream<List<TaskCommentRow>> watchCommentsByTask(int taskId) =>
      (select(taskComments)
            ..where(
              (c) => c.taskId.equals(taskId) & c.isDeleted.equals(false),
            )
            ..orderBy([(c) => OrderingTerm(expression: c.createdAt)]))
          .watch();

  /// Merge vom Server, siehe [ProjectsDao.upsertFromServer].
  Future<void> upsertFromServer(TaskCommentsCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      taskComments,
    )..where((c) => c.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(
      taskComments,
    ).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  Future<void> upsertLocal(TaskCommentsCompanion data) async {
    await into(
      taskComments,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  Future<int> deleteMissingCleanForTask(
    int taskId,
    Iterable<int> keepRemoteIds,
  ) {
    return (delete(taskComments)..where(
          (c) =>
              c.taskId.equals(taskId) &
              c.isDirty.equals(false) &
              c.remoteId.isNotNull() &
              c.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(taskComments).go();
}
