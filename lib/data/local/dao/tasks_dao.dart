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

  /// Übersicht (Landing-Page): offene Tasks projektübergreifend. Sortiert wie
  /// bisher serverseitig nach Fälligkeitsdatum, dann id. [onlyDueDate] blendet
  /// Tasks ohne Fälligkeit aus.
  Stream<List<TaskRow>> watchOverviewTasks({bool onlyDueDate = false}) {
    final query = select(tasks)
      ..where((t) => t.isDeleted.equals(false) & t.done.equals(false));
    if (onlyDueDate) {
      query.where((t) => t.dueDate.isNotNull());
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.dueDate),
      (t) => OrderingTerm(expression: t.id),
    ]);
    return query.watch();
  }

  /// Anzahl offener (nicht erledigter, nicht gelöschter) Tasks je projectId.
  /// Additive Query für die Untertitel der Projekt-Ordnerkarten. Liefert nur
  /// Projekte mit mindestens einer offenen Aufgabe (GROUP BY).
  Stream<Map<int, int>> watchOpenTaskCountsByProject() {
    final count = tasks.id.count();
    final query = selectOnly(tasks)
      ..addColumns([tasks.projectId, count])
      ..where(tasks.isDeleted.equals(false) & tasks.done.equals(false))
      ..groupBy([tasks.projectId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows) row.read(tasks.projectId)!: row.read(count)!,
      },
    );
  }

  /// Löscht eine einzelne Zeile (z.B. nach erfolgreichem Server-Delete).
  Future<int> deleteById(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

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

  /// Wie [deleteMissingClean], aber auf ein Projekt beschränkt. Der Pull-Sync
  /// synchronisiert Tasks projektweise; damit ein Teilabbruch (z.B. Netzfehler
  /// bei einem späteren Projekt) nicht die Tasks anderer Projekte löscht, wird
  /// pro Projekt-Scope aufgeräumt.
  Future<int> deleteMissingCleanForProject(
    int projectId,
    Iterable<int> keepRemoteIds,
  ) {
    return (delete(tasks)..where(
          (t) =>
              t.projectId.equals(projectId) &
              t.isDirty.equals(false) &
              t.remoteId.isNotNull() &
              t.remoteId.isNotIn(keepRemoteIds),
        ))
        .go();
  }

  Future<int> wipeAll() => delete(tasks).go();

  /// Offene, nicht gelöschte Tasks für Home-Widget und Notification-Planung
  /// (Meilenstein M3/F2, siehe docs/offline.md). Einmaliger Read statt
  /// `watch*()`, da beide Aufrufer (widget_controller.dart,
  /// notifications.dart) außerhalb des UI-Lebenszyklus laufen können
  /// (Headless-Isolate). Fälligkeits-/Reminder-Filterung erfolgt in den
  /// Aufrufern, da Reminder-Termine nur im [TaskRow.rawJson] stecken und
  /// hier nicht per SQL filterbar sind.
  Future<List<TaskRow>> getOpenTasks() => (select(
    tasks,
  )..where((t) => t.isDeleted.equals(false) & t.done.equals(false))).get();
}
