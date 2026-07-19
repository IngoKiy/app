import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/task_attachments_table.dart';

part 'task_attachments_dao.g.dart';

@DriftAccessor(tables: [TaskAttachments])
class TaskAttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$TaskAttachmentsDaoMixin {
  TaskAttachmentsDao(super.db);

  Stream<List<TaskAttachmentRow>> watchAttachmentsByTask(int taskId) =>
      (select(taskAttachments)..where(
            (a) => a.taskId.equals(taskId) & a.isDeleted.equals(false),
          ))
          .watch();

  /// Merge vom Server, siehe [ProjectsDao.upsertFromServer].
  Future<void> upsertFromServer(TaskAttachmentsCompanion data) async {
    final remoteId = data.remoteId.value;
    if (remoteId == null) {
      throw ArgumentError('upsertFromServer benötigt eine remoteId');
    }
    final existing = await (select(
      taskAttachments,
    )..where((a) => a.remoteId.equals(remoteId))).getSingleOrNull();

    if (existing != null && existing.isDirty) return;

    final localId = existing?.id ?? remoteId;
    await into(
      taskAttachments,
    ).insertOnConflictUpdate(data.copyWith(id: Value(localId)));
  }

  Future<void> upsertLocal(TaskAttachmentsCompanion data) async {
    await into(
      taskAttachments,
    ).insertOnConflictUpdate(data.copyWith(isDirty: const Value(true)));
  }

  Future<int> deleteMissingCleanForTask(
    int taskId,
    Iterable<int> keepRemoteIds,
  ) {
    return (delete(taskAttachments)..where(
          (a) =>
              a.taskId.equals(taskId) &
              a.isDirty.equals(false) &
              a.remoteId.isNotNull() &
              a.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(taskAttachments).go();
}
