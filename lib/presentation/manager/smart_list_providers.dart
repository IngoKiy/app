import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/row_mappers.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';
import 'package:vikunja_app/domain/entities/task.dart';

part 'smart_list_providers.g.dart';

/// Reaktive Aufgaben einer [SmartList] aus der lokalen DB, mit zugeordnetem
/// Projekt (für die Herkunfts-Zeile in der Liste). Offline-fähig; Änderungen
/// über den OfflineWriter tauchen über die Drift-Streams von selbst auf.
@riverpod
Stream<List<Task>> smartListTasks(Ref ref, SmartList list) {
  final tasksDao = ref.watch(tasksDaoProvider);
  final projectsDao = ref.watch(projectsDaoProvider);
  final endOfToday = endOfTodayUtcIso(DateTime.now());

  return tasksDao.watchSmartList(list, endOfTodayIso: endOfToday).asyncMap((
    rows,
  ) async {
    final tasks = rows.map(taskFromRow).toList();
    final projectRows = await projectsDao.getAll();
    final projectsById = {for (final r in projectRows) r.id: projectFromRow(r)};
    for (final task in tasks) {
      task.project = projectsById[task.projectId];
    }
    return tasks;
  });
}

/// Zähler einer [SmartList] für die Listen-Übersicht.
@riverpod
Stream<int> smartListCount(Ref ref, SmartList list) {
  final tasksDao = ref.watch(tasksDaoProvider);
  return tasksDao.watchSmartListCount(
    list,
    endOfTodayIso: endOfTodayUtcIso(DateTime.now()),
  );
}
