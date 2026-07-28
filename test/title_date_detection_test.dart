import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/utils/title_date_detection.dart';

void main() {
  // Montag, 27. Juli 2026.
  final now = DateTime(2026, 7, 27, 10);

  test('erkennt "morgen" und entfernt es aus dem Titel', () {
    final d = detectDueDateInTitle('Milch kaufen morgen', now: now)!;
    expect(d.dueDate.day, 28);
    expect(d.cleanedTitle, 'Milch kaufen');
  });

  test('erkennt "heute"', () {
    final d = detectDueDateInTitle('heute Bericht senden', now: now)!;
    expect(d.dueDate.day, 27);
    expect(d.cleanedTitle, 'Bericht senden');
  });

  test('erkennt "nächste Woche" (nächster Montag)', () {
    final d = detectDueDateInTitle('Review nächste Woche', now: now)!;
    expect(d.dueDate.day, 3);
    expect(d.dueDate.month, 8);
  });

  test('erkennt Wochentag mit "am"', () {
    final d = detectDueDateInTitle('Anruf am Freitag', now: now)!;
    expect(d.dueDate.weekday, DateTime.friday);
    expect(d.dueDate.day, 31);
    expect(d.cleanedTitle, 'Anruf');
  });

  test('erkennt numerisches Datum ohne Jahr (Zukunft)', () {
    final d = detectDueDateInTitle('TÜV 15.09.', now: now)!;
    expect(d.dueDate.month, 9);
    expect(d.dueDate.year, 2026);
  });

  test('numerisches Datum in der Vergangenheit rollt ins nächste Jahr', () {
    final d = detectDueDateInTitle('Jahresplanung 15.01.', now: now)!;
    expect(d.dueDate.year, 2027);
  });

  test('kein Datum → null', () {
    expect(detectDueDateInTitle('Einfach nur ein Titel', now: now), isNull);
  });
}
