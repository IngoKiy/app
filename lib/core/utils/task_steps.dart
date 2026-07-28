/// Schritte („Nächster Schritt", MS-To-Do-Stil) als Checkliste in der
/// Aufgaben-Beschreibung.
///
/// Format ist die TipTap-Task-List von Vikunja-Web:
/// `<ul data-type="taskList"><li data-checked="…" data-type="taskItem">…`
/// — dadurch zeigt die Weboberfläche dieselben Schritte an und zählt sie
/// ebenfalls als „x von y". Die App hält die Schritte ans Ende der
/// Beschreibung; davor stehender HTML-Text bleibt als Notiz erhalten.
library;

class TaskStep {
  final String text;
  final bool done;

  const TaskStep(this.text, {this.done = false});

  TaskStep copyWith({String? text, bool? done}) =>
      TaskStep(text ?? this.text, done: done ?? this.done);
}

final _taskListPattern = RegExp(
  r'<ul[^>]*data-type="taskList"[^>]*>(.*?)</ul>',
  dotAll: true,
);

final _taskItemPattern = RegExp(
  r'<li[^>]*data-checked="(true|false)"[^>]*>(.*?)</li>',
  dotAll: true,
);

final _tagPattern = RegExp(r'<[^>]+>');

String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&');

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Alle Schritte aus der Beschreibung (über sämtliche Task-Lists hinweg,
/// in Dokumentreihenfolge).
List<TaskStep> parseSteps(String description) {
  final steps = <TaskStep>[];
  for (final list in _taskListPattern.allMatches(description)) {
    for (final item in _taskItemPattern.allMatches(list.group(1)!)) {
      final text = _unescape(
        item.group(2)!.replaceAll(_tagPattern, ' '),
      ).replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isNotEmpty) {
        steps.add(TaskStep(text, done: item.group(1) == 'true'));
      }
    }
  }
  return steps;
}

/// Die Beschreibung ohne die Schritt-Listen (die „Notiz").
String stripSteps(String description) =>
    description.replaceAll(_taskListPattern, '').trim();

/// Baut die Beschreibung aus Notiz + Schritten im Vikunja-Web-Format wieder
/// zusammen. Ohne Schritte bleibt nur die Notiz übrig.
String buildDescription({required String note, required List<TaskStep> steps}) {
  final trimmedNote = note.trim();
  if (steps.isEmpty) return trimmedNote;

  final items = steps
      .map(
        (s) =>
            '<li data-checked="${s.done}" data-type="taskItem">'
            '<label><input type="checkbox"${s.done ? ' checked="checked"' : ''}>'
            '<span></span></label>'
            '<div><p>${_escape(s.text)}</p></div></li>',
      )
      .join();
  final list = '<ul data-type="taskList">$items</ul>';
  return trimmedNote.isEmpty ? list : '$trimmedNote$list';
}

/// Fortschritt („x von y") der Schritte einer Beschreibung.
({int done, int total}) stepProgress(String description) {
  final steps = parseSteps(description);
  return (done: steps.where((s) => s.done).length, total: steps.length);
}
