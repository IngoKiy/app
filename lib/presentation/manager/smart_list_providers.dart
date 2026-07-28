import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_sort.dart';

part 'smart_list_providers.g.dart';

/// Persistierter Sortier-Modus einer Liste; `null` = kein Modus gespeichert
/// (Smart-Lists: Standard Fälligkeit, Projektlisten: manuelle Reihenfolge).
/// [listKey] ist `smart/<name>` für Smart-Lists bzw. `project/<id>`.
@riverpod
Stream<TaskSortMode?> listSortMode(Ref ref, String listKey) {
  final kv = ref.watch(keyValueDaoProvider);
  return kv
      .watch('sort_mode/$listKey')
      .map((name) => name == null ? null : taskSortModeFromName(name))
      .distinct();
}

/// Setzt und persistiert den Sortier-Modus einer Liste.
Future<void> setListSortMode(
  KeyValueDao kv,
  String listKey,
  TaskSortMode mode,
) => kv.set('sort_mode/$listKey', mode.name);

/// Setzt eine Liste auf die Standard-Reihenfolge zurück (löscht den
/// gespeicherten Sortier-Modus). Für Projektlisten bedeutet das: zurück zur
/// manuellen Positionsreihenfolge (Drag & Drop).
Future<void> clearListSortMode(KeyValueDao kv, String listKey) =>
    kv.remove('sort_mode/$listKey');

/// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
/// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
/// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
@riverpod
Stream<List<Task>> smartListTasks(Ref ref, SmartList list) {
  final tasksDao = ref.watch(tasksDaoProvider);
  final projectsDao = ref.watch(projectsDaoProvider);
  final now = DateTime.now();
  // Sortier-Modus beim Aufbau beobachten (ref.watch ist nur hier erlaubt);
  // Änderungen bauen den Stream neu auf.
  final sortMode = list == SmartList.completed
      ? null
      : ref.watch(listSortModeProvider('smart/${list.name}')).value ??
            TaskSortMode.dueDate;

  return tasksDao
      .watchSmartList(
        list,
        endOfTodayIso: endOfTodayUtcIso(now),
        dayKey: localDayKey(now),
        userId: ref.watch(currentUserProvider)?.id,
      )
      .asyncMap((rows) async {
        final tasks = rows.map(taskFromRow).toList();
        final projectRows = await projectsDao.getAll();
        final projectsById = {
          for (final r in projectRows) r.id: projectFromRow(r),
        };
        for (final task in tasks) {
          task.project = projectsById[task.projectId];
        }
        // Persistierten Sortier-Modus anwenden ("Erledigt" bleibt bei
        // zuletzt-geändert-zuerst aus der Query).
        return sortMode == null ? tasks : sortTasks(tasks, sortMode);
      });
}

/// Zähler einer [SmartList] für die Listen-Übersicht.
@riverpod
Stream<int> smartListCount(Ref ref, SmartList list) {
  final tasksDao = ref.watch(tasksDaoProvider);
  final now = DateTime.now();
  return tasksDao.watchSmartListCount(
    list,
    endOfTodayIso: endOfTodayUtcIso(now),
    dayKey: localDayKey(now),
    userId: ref.watch(currentUserProvider)?.id,
  );
}

/// Reaktiv: ist die Aufgabe heute manuell in „Mein Tag"? (Detailseite/Swipe.)
@riverpod
Stream<bool> taskInMyDay(Ref ref, int taskId) {
  final tasksDao = ref.watch(tasksDaoProvider);
  return tasksDao.watchInMyDay(taskId, localDayKey(DateTime.now()));
}

/// Lokale Suche über alle Aufgaben (Titel + Beschreibung), mit Projekten.
@riverpod
Stream<List<Task>> taskSearch(Ref ref, String query) {
  if (query.trim().isEmpty) {
    return Stream.value(const <Task>[]);
  }
  final tasksDao = ref.watch(tasksDaoProvider);
  final projectsDao = ref.watch(projectsDaoProvider);
  return tasksDao.watchSearch(query.trim()).asyncMap((rows) async {
    final tasks = rows.map(taskFromRow).toList();
    final projectRows = await projectsDao.getAll();
    final projectsById = {for (final r in projectRows) r.id: projectFromRow(r)};
    for (final task in tasks) {
      task.project = projectsById[task.projectId];
    }
    return tasks;
  });
}
