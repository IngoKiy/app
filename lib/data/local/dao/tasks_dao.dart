import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/local/tables/my_day_entries_table.dart';
import 'package:vikunja_app/data/local/tables/task_assignees_table.dart';
import 'package:vikunja_app/data/local/tables/tasks_table.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [Tasks, MyDayEntries, TaskAssignees])
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

  /// Filterbedingung einer [SmartList]. [endOfTodayIso] ist die (UTC-ISO-)
  /// Grenze für „Mein Tag" (heute fällig oder überfällig), [dayKey] der
  /// lokale Kalendertag für manuelle Mein-Tag-Einträge, [userId] der aktuelle
  /// Benutzer für „Mir zugewiesen". Die Spalte `dueDate` ist null, wenn keine
  /// echte Fälligkeit gesetzt ist.
  Expression<bool> _smartListPredicate(
    $TasksTable t,
    SmartList list, {
    required String endOfTodayIso,
    required String dayKey,
    int? userId,
  }) {
    final visible = t.isDeleted.equals(false);
    switch (list) {
      case SmartList.today:
        final dueToday =
            t.dueDate.isNotNull() &
            t.dueDate.isSmallerThanValue(endOfTodayIso);
        final addedManually = existsQuery(
          select(myDayEntries)..where(
            (e) => e.taskId.equalsExp(t.id) & e.day.equals(dayKey),
          ),
        );
        return visible & t.done.equals(false) & (dueToday | addedManually);
      case SmartList.important:
        return visible & t.done.equals(false) & t.isFavorite.equals(true);
      case SmartList.planned:
        return visible & t.done.equals(false) & t.dueDate.isNotNull();
      case SmartList.assignedToMe:
        final assigned = userId == null
            ? const Constant(false)
            : existsQuery(
                select(taskAssignees)..where(
                  (a) => a.taskId.equalsExp(t.id) & a.userId.equals(userId),
                ),
              );
        return visible & t.done.equals(false) & assigned;
      case SmartList.all:
        return visible & t.done.equals(false);
      case SmartList.completed:
        return visible & t.done.equals(true);
    }
  }

  /// Reaktive Smart-List (MS-To-Do-Stil). Offene Listen sortieren nach
  /// Fälligkeit (ohne Fälligkeit ans Ende), „Erledigt" nach letzter Änderung.
  Stream<List<TaskRow>> watchSmartList(
    SmartList list, {
    required String endOfTodayIso,
    required String dayKey,
    int? userId,
  }) {
    final query = select(tasks)
      ..where(
        (t) => _smartListPredicate(
          t,
          list,
          endOfTodayIso: endOfTodayIso,
          dayKey: dayKey,
          userId: userId,
        ),
      );
    if (list == SmartList.completed) {
      query.orderBy([
        (t) =>
            OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    } else {
      query.orderBy([
        (t) => OrderingTerm(expression: t.dueDate.isNull()),
        (t) => OrderingTerm(expression: t.dueDate),
        (t) => OrderingTerm(expression: t.id),
      ]);
    }
    return query.watch();
  }

  /// Zähler einer Smart-List für die Listen-Übersicht.
  Stream<int> watchSmartListCount(
    SmartList list, {
    required String endOfTodayIso,
    required String dayKey,
    int? userId,
  }) {
    final count = countAll();
    return (selectOnly(tasks)
          ..addColumns([count])
          ..where(
            _smartListPredicate(
              tasks,
              list,
              endOfTodayIso: endOfTodayIso,
              dayKey: dayKey,
              userId: userId,
            ),
          ))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  // --- Mein Tag (manuelle Einträge, rein lokal) ------------------------------

  /// Nimmt [taskId] für den Tag [dayKey] manuell in „Mein Tag" auf und räumt
  /// dabei abgelaufene Einträge früherer Tage weg.
  Future<void> addToMyDay(int taskId, String dayKey) async {
    await pruneMyDay(dayKey);
    await into(myDayEntries).insertOnConflictUpdate(
      MyDayEntriesCompanion.insert(taskId: taskId, day: dayKey),
    );
  }

  /// Entfernt [taskId] aus den manuellen Mein-Tag-Einträgen des Tages.
  Future<void> removeFromMyDay(int taskId, String dayKey) => (delete(
    myDayEntries,
  )..where((e) => e.taskId.equals(taskId) & e.day.equals(dayKey))).go();

  /// Reaktiv: ist [taskId] für [dayKey] manuell in „Mein Tag"?
  Stream<bool> watchInMyDay(int taskId, String dayKey) =>
      (select(myDayEntries)
            ..where((e) => e.taskId.equals(taskId) & e.day.equals(dayKey)))
          .watch()
          .map((rows) => rows.isNotEmpty);

  /// Löscht Einträge, die nicht (mehr) zum Tag [dayKey] gehören.
  Future<int> pruneMyDay(String dayKey) =>
      (delete(myDayEntries)..where((e) => e.day.equals(dayKey).not())).go();

  // --- Suche -----------------------------------------------------------------

  /// Lokale Volltextsuche über Titel und Beschreibung (case-insensitiv).
  /// Offene Aufgaben zuerst, danach nach Fälligkeit.
  Stream<List<TaskRow>> watchSearch(String query) {
    final pattern = '%${query.replaceAll('%', r'\%')}%';
    return (select(tasks)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                (t.title.like(pattern) | t.description.like(pattern)),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.done),
            (t) => OrderingTerm(expression: t.dueDate.isNull()),
            (t) => OrderingTerm(expression: t.dueDate),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .watch();
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
