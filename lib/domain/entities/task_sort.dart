import 'package:vikunja_app/domain/entities/task.dart';

/// Sortier-Modi einer Aufgabenliste (MS-To-Do-Stil). Die Auswahl wird pro
/// Liste im KeyValue-Store gemerkt (`sort_mode/<listKey>`).
enum TaskSortMode { dueDate, importance, alphabetical, created }

TaskSortMode taskSortModeFromName(String? name) => TaskSortMode.values
    .firstWhere((m) => m.name == name, orElse: () => TaskSortMode.dueDate);

/// Sortiert [tasks] stabil nach [mode]. Ohne Fälligkeit ans Ende (dueDate),
/// Favoriten/Priorität zuerst (importance).
List<Task> sortTasks(List<Task> tasks, TaskSortMode mode) {
  final sorted = List<Task>.of(tasks);
  int byDue(Task a, Task b) {
    final aDue = a.hasDueDate, bDue = b.hasDueDate;
    if (aDue != bDue) return aDue ? -1 : 1;
    if (aDue && bDue) {
      final cmp = a.dueDate!.compareTo(b.dueDate!);
      if (cmp != 0) return cmp;
    }
    return a.id.compareTo(b.id);
  }

  switch (mode) {
    case TaskSortMode.dueDate:
      sorted.sort(byDue);
    case TaskSortMode.importance:
      sorted.sort((a, b) {
        if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
        final cmp = (b.priority ?? 0).compareTo(a.priority ?? 0);
        if (cmp != 0) return cmp;
        return byDue(a, b);
      });
    case TaskSortMode.alphabetical:
      sorted.sort((a, b) {
        final cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      });
    case TaskSortMode.created:
      sorted.sort((a, b) {
        final cmp = b.created.compareTo(a.created);
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      });
  }
  return sorted;
}
