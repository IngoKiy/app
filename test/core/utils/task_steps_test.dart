import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/utils/task_steps.dart';

void main() {
  const vikunjaHtml =
      '<p>Meine Notiz</p>'
      '<ul data-type="taskList">'
      '<li data-checked="true" data-type="taskItem">'
      '<label><input type="checkbox" checked="checked"><span></span></label>'
      '<div><p>Abdichtung prüfen</p></div></li>'
      '<li data-checked="false" data-type="taskItem">'
      '<label><input type="checkbox"><span></span></label>'
      '<div><p>Sturmsicherung &amp; Co</p></div></li>'
      '</ul>';

  test('parseSteps liest Vikunja-Web-Checklisten', () {
    final steps = parseSteps(vikunjaHtml);
    expect(steps, hasLength(2));
    expect(steps[0].text, 'Abdichtung prüfen');
    expect(steps[0].done, isTrue);
    expect(steps[1].text, 'Sturmsicherung & Co');
    expect(steps[1].done, isFalse);
  });

  test('stripSteps behält die Notiz ohne Checkliste', () {
    expect(stripSteps(vikunjaHtml), '<p>Meine Notiz</p>');
  });

  test('buildDescription + parseSteps ist ein Roundtrip', () {
    final description = buildDescription(
      note: '<p>Notiz</p>',
      steps: const [
        TaskStep('Erster <Schritt>', done: true),
        TaskStep('Zweiter', done: false),
      ],
    );

    final steps = parseSteps(description);
    expect(steps.map((s) => s.text).toList(), ['Erster <Schritt>', 'Zweiter']);
    expect(steps.map((s) => s.done).toList(), [true, false]);
    expect(stripSteps(description), '<p>Notiz</p>');
  });

  test('stepProgress zählt x von y', () {
    final progress = stepProgress(vikunjaHtml);
    expect(progress.done, 1);
    expect(progress.total, 2);
  });

  test('Beschreibung ohne Checkliste: keine Schritte, Notiz unverändert', () {
    expect(parseSteps('<p>Nur Text</p>'), isEmpty);
    expect(stripSteps('<p>Nur Text</p>'), '<p>Nur Text</p>');
    expect(buildDescription(note: '<p>Nur Text</p>', steps: const []),
        '<p>Nur Text</p>');
  });
}
