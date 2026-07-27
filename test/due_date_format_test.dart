import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/utils/due_date_format.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

Future<AppLocalizations> loadDe(WidgetTester tester) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return l10n;
}

void main() {
  // Fester Bezugspunkt: Montag, 27. Juli 2026.
  final now = DateTime(2026, 7, 27, 10, 30);

  testWidgets('Nachbartage als Gestern/Heute/Morgen', (tester) async {
    final l10n = await loadDe(tester);
    expect(
      formatDueDate(l10n, 'de', DateTime(2026, 7, 26, 23, 59), now: now),
      'Gestern',
    );
    expect(
      formatDueDate(l10n, 'de', DateTime(2026, 7, 27, 0, 1), now: now),
      'Heute',
    );
    expect(
      formatDueDate(l10n, 'de', DateTime(2026, 7, 28, 8, 0), now: now),
      'Morgen',
    );
  });

  testWidgets('gleiches Jahr: Wochentag + Tag + Monat', (tester) async {
    final l10n = await loadDe(tester);
    final label = formatDueDate(l10n, 'de', DateTime(2026, 3, 31), now: now);
    expect(label, contains('31. März'));
    expect(label, isNot(contains('2026')));
  });

  testWidgets('anderes Jahr: mit Jahreszahl', (tester) async {
    final l10n = await loadDe(tester);
    final label = formatDueDate(l10n, 'de', DateTime(2028, 9, 30), now: now);
    expect(label, contains('2028'));
  });

  test('isOverdue vergleicht Kalendertage', () {
    expect(isOverdue(DateTime(2026, 7, 26, 23, 59), now: now), isTrue);
    expect(isOverdue(DateTime(2026, 7, 27, 0, 0), now: now), isFalse);
    expect(isOverdue(DateTime(2026, 7, 28), now: now), isFalse);
  });
}
