import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/sync/filter/filter_evaluator.dart' as ev;
import 'package:vikunja_app/core/sync/filter/filter_parser.dart';
import 'package:vikunja_app/domain/entities/label.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';

final _user = User(id: 1, username: 'u');

Label _label(int id) => Label(id: id, title: 'L$id', createdBy: _user);

Task _task({
  String title = 'Task',
  bool done = false,
  int? priority,
  double? percentDone,
  DateTime? dueDate,
  DateTime? startDate,
  DateTime? endDate,
  List<int> labelIds = const [],
  List<int> assigneeIds = const [],
  int? projectId = 1,
}) => Task(
  title: title,
  done: done,
  priority: priority,
  percentDone: percentDone,
  dueDate: dueDate,
  startDate: startDate,
  endDate: endDate,
  labels: labelIds.map(_label).toList(),
  assignees: assigneeIds.map((id) => User(id: id, username: 'u$id')).toList(),
  projectId: projectId,
  createdBy: _user,
);

/// Fixe Referenzzeit für deterministische now-Auswertung.
final _now = DateTime.utc(2026, 7, 18, 12, 0, 0);

bool _match(Task t, String filter) =>
    ev.matches(t, FilterParser.parse(filter), now: _now);

void main() {
  group('bool / done', () {
    final t = _task(done: false);
    test('done = false', () => expect(_match(t, 'done = false'), isTrue));
    test('done = true', () => expect(_match(t, 'done = true'), isFalse));
    test('done != false', () => expect(_match(t, 'done != false'), isFalse));
  });

  group('priority (numerisch, inkl. fehlend)', () {
    final p5 = _task(priority: 5);
    final p0 = _task(priority: 0);
    final pNull = _task(priority: null);
    test('5 >= 3', () => expect(_match(p5, 'priority >= 3'), isTrue));
    test('5 < 3', () => expect(_match(p5, 'priority < 3'), isFalse));
    test('5 = 5', () => expect(_match(p5, 'priority = 5'), isTrue));
    test('0 = 0', () => expect(_match(p0, 'priority = 0'), isTrue));
    // Fehlende Priorität (null) -> jeder Vergleich false, auch !=.
    test('null >= 3', () => expect(_match(pNull, 'priority >= 3'), isFalse));
    test('null = 0', () => expect(_match(pNull, 'priority = 0'), isFalse));
    test('null != 3', () => expect(_match(pNull, 'priority != 3'), isFalse));
  });

  group('percent_done', () {
    final half = _task(percentDone: 0.5);
    final none = _task(percentDone: null);
    test('0.5 >= 0.5', () => expect(_match(half, 'percent_done >= 0.5'), isTrue));
    test('0.5 > 0.5', () => expect(_match(half, 'percent_done > 0.5'), isFalse));
    test('null < 1', () => expect(_match(none, 'percent_done < 1'), isFalse));
  });

  group('Datum inkl. now-Arithmetik und Jahr-1', () {
    final future = _task(dueDate: DateTime.utc(2026, 7, 20));
    final morning = _task(dueDate: DateTime.utc(2026, 7, 18, 6));
    final unsetYear1 = _task(dueDate: DateTime.utc(1, 1, 1));
    final unsetNull = _task(dueDate: null);

    test('due > now/d (Tagesanfang)',
        () => expect(_match(future, 'due_date > now/d'), isTrue));
    test('due < now+7d',
        () => expect(_match(future, 'due_date < now+7d'), isTrue));
    test('due > now+7d',
        () => expect(_match(future, 'due_date > now+7d'), isFalse));
    // /d-Rundung: 06:00 liegt vor now (12:00), aber nach now/d (00:00).
    test('morgens > now/d',
        () => expect(_match(morning, 'due_date > now/d'), isTrue));
    test('morgens > now',
        () => expect(_match(morning, 'due_date > now'), isFalse));
    test('now-1w Vergangenheit',
        () => expect(_match(future, 'due_date > now-1w'), isTrue));
    // Jahr-1 und null zählen als nicht gesetzt -> alle Vergleiche false.
    test('Jahr-1 > now/d',
        () => expect(_match(unsetYear1, 'due_date > now/d'), isFalse));
    test('Jahr-1 != now',
        () => expect(_match(unsetYear1, 'due_date != now'), isFalse));
    test('null > now/d',
        () => expect(_match(unsetNull, 'due_date > now/d'), isFalse));
    // start_date / end_date analog.
    test('start_date < now',
        () => expect(
            _match(_task(startDate: DateTime.utc(2026, 1, 1)),
                'start_date < now'),
            isTrue));
    test('end_date >= now',
        () => expect(
            _match(_task(endDate: DateTime.utc(2027, 1, 1)),
                'end_date >= now'),
            isTrue));
  });

  group('labels / assignees / project (IDs)', () {
    final t = _task(labelIds: [1, 3], assigneeIds: [5], projectId: 4);
    test('labels in 1,2', () => expect(_match(t, 'labels in 1,2'), isTrue));
    test('labels in 2,4', () => expect(_match(t, 'labels in 2,4'), isFalse));
    test('labels = 3', () => expect(_match(t, 'labels = 3'), isTrue));
    test('labels != 5', () => expect(_match(t, 'labels != 5'), isTrue));
    test('labels = 5', () => expect(_match(t, 'labels = 5'), isFalse));
    test('assignees in 5', () => expect(_match(t, 'assignees in 5'), isTrue));
    test('assignees in 6', () => expect(_match(t, 'assignees in 6'), isFalse));
    test('project = 4', () => expect(_match(t, 'project = 4'), isTrue));
    test('project in 1,2', () => expect(_match(t, 'project in 1, 2'), isFalse));
    test('project in 4,5', () => expect(_match(t, 'project in 4, 5'), isTrue));
    test('project null = 4',
        () => expect(_match(_task(projectId: null), 'project = 4'), isFalse));
  });

  group('title like / =', () {
    final t = _task(title: 'Buy milk');
    test('like milk', () => expect(_match(t, 'title like milk'), isTrue));
    test('like MILK (case-insensitive)',
        () => expect(_match(t, 'title like MILK'), isTrue));
    test('like bread', () => expect(_match(t, 'title like bread'), isFalse));
    test('= exact ci',
        () => expect(_match(t, "title = 'buy milk'"), isTrue));
    test('!= other', () => expect(_match(t, 'title != x'), isTrue));
  });

  group('Verknüpfungen und Präzedenz', () {
    final t = _task(done: false, priority: 5, dueDate: DateTime.utc(2026, 7, 20));
    test('&& beide wahr',
        () => expect(_match(t, 'done = false && priority >= 3'), isTrue));
    test('|| eine wahr',
        () => expect(_match(t, 'done = true || priority >= 3'), isTrue));
    test('Präzedenz && vor ||',
        () => expect(
            _match(t, 'done = true && priority < 3 || due_date > now/d'),
            isTrue));
    test('Klammern kehren Präzedenz um',
        () => expect(
            _match(t, 'done = true && (priority < 3 || due_date > now/d)'),
            isFalse));
  });
}
