import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/sort_chip.dart';

/// Baut den Widget-Baum ab, bevor tearDown die DB schließt — sonst hält der
/// noch abonnierte Drift-Stream (listSortModeProvider) db.close() endlos auf.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
}

Widget _wrap(AppDatabase db, Widget child) => ProviderScope(
  overrides: [appDatabaseProvider.overrideWithValue(db)],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  ),
);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets(
    'Smart-List-Chip zeigt ohne gespeicherten Modus den Standard (Fälligkeit)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(db, const SortChip(listKey: 'smart/today')),
      );
      await tester.pump();

      expect(find.text('Sorted by Due date'), findsOneWidget);

      await _unmount(tester);
    },
  );

  testWidgets(
    'Projekt-Chip zeigt ohne gespeicherten Modus "Sort" (manuelle Reihenfolge)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          db,
          const SortChip(listKey: 'project/1', allowManualOrder: true),
        ),
      );
      await tester.pump();

      expect(find.text('Sort'), findsOneWidget);

      await _unmount(tester);
    },
  );

  testWidgets(
    'Auswahl im Menü persistiert den Modus und aktualisiert den Chip-Text',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          db,
          const SortChip(listKey: 'project/1', allowManualOrder: true),
        ),
      );
      await tester.pump();
      expect(find.text('Sort'), findsOneWidget);

      await tester.tap(find.byType(Chip));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alphabetically').last);
      await tester.pumpAndSettle();

      expect(find.text('Sorted by Alphabetically'), findsOneWidget);

      // Persistiert im KeyValue-Store unter dem erwarteten Schlüssel.
      final stored = await db.keyValueDao.get('sort_mode/project/1');
      expect(stored, 'alphabetical');

      await _unmount(tester);
    },
  );
}
