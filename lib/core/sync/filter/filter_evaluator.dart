import 'package:vikunja_app/core/sync/filter/filter_ast.dart';
import 'package:vikunja_app/domain/entities/task.dart';

/// Wertet einen [FilterExpr] gegen einen [Task] aus (lokaler Ersatz für die
/// serverseitige Filterung gespeicherter Übersichts-Filter).
///
/// Datums-Semantik: `now`-Ausdrücke werden gegen [now] (Default: jetzt) in UTC
/// aufgelöst. Leere Vikunja-Daten (Jahr 1) bzw. `null` gelten als „nicht
/// gesetzt"; jeder Vergleich damit ist `false`. Gleiches gilt für fehlende
/// Priorität/Prozent (`null`).
bool matches(Task task, FilterExpr expr, {DateTime? now}) {
  final base = (now ?? DateTime.now()).toUtc();
  return _eval(task, expr, base);
}

bool _eval(Task task, FilterExpr expr, DateTime now) {
  switch (expr) {
    case LogicNode(:final op, :final left, :final right):
      final l = _eval(task, left, now);
      return op == LogicOp.and
          ? l && _eval(task, right, now)
          : l || _eval(task, right, now);
    case ConditionNode():
      return _evalCondition(task, expr, now);
  }
}

bool _evalCondition(Task task, ConditionNode node, DateTime now) {
  switch (node.field) {
    case 'done':
      final want = (node.value as BoolValue).value;
      return node.op == CompareOp.eq ? task.done == want : task.done != want;
    case 'priority':
      return _compareNumOrNull(task.priority?.toDouble(), node);
    case 'percent_done':
      return _compareNumOrNull(task.percentDone, node);
    case 'due_date':
      return _compareDate(task.dueDate, node, now);
    case 'start_date':
      return _compareDate(task.startDate, node, now);
    case 'end_date':
      return _compareDate(task.endDate, node, now);
    case 'labels':
      return _compareIds(task.labels.map((l) => l.id), node);
    case 'assignees':
      return _compareIds(task.assignees.map((u) => u.id), node);
    case 'project':
      final id = task.projectId;
      return _compareIds(id == null ? const <int>[] : [id], node);
    case 'title':
      return _compareTitle(task.title, node);
    default:
      // Sollte nach dem Parser nicht vorkommen.
      return false;
  }
}

bool _compareNumOrNull(num? taskValue, ConditionNode node) {
  if (taskValue == null) return false; // nicht gesetzt -> immer false
  final want = (node.value as NumValue).value;
  return _compareNum(taskValue, node.op, want);
}

bool _compareNum(num a, CompareOp op, num b) => switch (op) {
  CompareOp.eq => a == b,
  CompareOp.neq => a != b,
  CompareOp.gt => a > b,
  CompareOp.lt => a < b,
  CompareOp.gte => a >= b,
  CompareOp.lte => a <= b,
  _ => false,
};

bool _compareDate(DateTime? taskDate, ConditionNode node, DateTime now) {
  // Leere/ungesetzte Daten (null oder Jahr 1) -> jeder Vergleich false.
  if (taskDate == null || taskDate.year <= 1) return false;
  final a = taskDate.toUtc();
  final b = _resolveDate(node.value, now);
  return switch (node.op) {
    CompareOp.eq => a.isAtSameMomentAs(b),
    CompareOp.neq => !a.isAtSameMomentAs(b),
    CompareOp.gt => a.isAfter(b),
    CompareOp.lt => a.isBefore(b),
    CompareOp.gte => a.isAfter(b) || a.isAtSameMomentAs(b),
    CompareOp.lte => a.isBefore(b) || a.isAtSameMomentAs(b),
    _ => false,
  };
}

/// Löst einen Datumswert (absolut oder `now`-Ausdruck) in UTC auf.
DateTime _resolveDate(FilterValue value, DateTime now) {
  if (value is DateValue) return value.value.toUtc();
  if (value is NowValue) {
    var dt = now;
    for (final step in value.steps) {
      dt = switch (step) {
        NowRound(:final unit) => _round(dt, unit),
        NowOffset(:final amount, :final unit) => _offset(dt, amount, unit),
      };
    }
    return dt;
  }
  // Andere Typen sind für Datumsfelder ungültig -> unerreichbarer Wert.
  throw StateError('Ungültiger Datumswert');
}

DateTime _round(DateTime dt, String unit) => switch (unit) {
  's' => DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second),
  'm' => DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute),
  'h' => DateTime.utc(dt.year, dt.month, dt.day, dt.hour),
  'd' => DateTime.utc(dt.year, dt.month, dt.day),
  _ => dt,
};

DateTime _offset(DateTime dt, int amount, String unit) => switch (unit) {
  's' => dt.add(Duration(seconds: amount)),
  'm' => dt.add(Duration(minutes: amount)),
  'h' => dt.add(Duration(hours: amount)),
  'd' => dt.add(Duration(days: amount)),
  'w' => dt.add(Duration(days: amount * 7)),
  'M' => DateTime.utc(
    dt.year,
    dt.month + amount,
    dt.day,
    dt.hour,
    dt.minute,
    dt.second,
    dt.millisecond,
  ),
  'y' => DateTime.utc(
    dt.year + amount,
    dt.month,
    dt.day,
    dt.hour,
    dt.minute,
    dt.second,
    dt.millisecond,
  ),
  _ => dt,
};

bool _compareIds(Iterable<int> taskIds, ConditionNode node) {
  final ids = taskIds.toSet();
  switch (node.op) {
    case CompareOp.eq:
      return ids.contains((node.value as NumValue).value.toInt());
    case CompareOp.neq:
      return !ids.contains((node.value as NumValue).value.toInt());
    case CompareOp.inList:
      final wanted = (node.value as ListValue).values
          .map((v) => (v as NumValue).value.toInt())
          .toSet();
      return ids.intersection(wanted).isNotEmpty;
    default:
      return false;
  }
}

bool _compareTitle(String title, ConditionNode node) {
  final want = (node.value as StringValue).value;
  final t = title.toLowerCase();
  switch (node.op) {
    case CompareOp.like:
      // Vikunja `like` entspricht SQL LIKE %wert%; umschließende %/_ entfernen.
      final needle = want.replaceAll('%', '').toLowerCase();
      return t.contains(needle);
    case CompareOp.eq:
      return t == want.toLowerCase();
    case CompareOp.neq:
      return t != want.toLowerCase();
    default:
      return false;
  }
}
