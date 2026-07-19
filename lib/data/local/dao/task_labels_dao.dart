import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/task_labels_table.dart';

part 'task_labels_dao.g.dart';

@DriftAccessor(tables: [TaskLabels])
class TaskLabelsDao extends DatabaseAccessor<AppDatabase>
    with _$TaskLabelsDaoMixin {
  TaskLabelsDao(super.db);

  Stream<List<TaskLabelRow>> watchLabelsForTask(int taskId) =>
      (select(taskLabels)..where((t) => t.taskId.equals(taskId))).watch();

  /// Legt die Relation an, falls sie fehlt; überschreibt keine dirty-Relation
  /// (z.B. eine noch nicht gepushte lokale Entfernung).
  Future<void> upsertFromServer(int taskId, int labelId) async {
    final existing = await (select(taskLabels)..where(
          (t) => t.taskId.equals(taskId) & t.labelId.equals(labelId),
        ))
        .getSingleOrNull();
    if (existing != null && existing.isDirty) return;

    await into(taskLabels).insertOnConflictUpdate(
      TaskLabelsCompanion.insert(
        taskId: taskId,
        labelId: labelId,
        isDirty: const Value(false),
      ),
    );
  }

  Future<void> upsertLocal(int taskId, int labelId) async {
    await into(taskLabels).insertOnConflictUpdate(
      TaskLabelsCompanion.insert(
        taskId: taskId,
        labelId: labelId,
        isDirty: const Value(true),
      ),
    );
  }

  /// Löscht nicht-dirty Relationen für [taskId], deren labelId nicht in
  /// [keepLabelIds] enthalten ist.
  Future<int> deleteMissingCleanForTask(
    int taskId,
    Iterable<int> keepLabelIds,
  ) {
    return (delete(taskLabels)..where(
          (t) =>
              t.taskId.equals(taskId) &
              t.isDirty.equals(false) &
              t.labelId.isNotIn(keepLabelIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(taskLabels).go();
}
