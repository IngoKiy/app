import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/utils/project_display_title.dart';
import 'package:vikunja_app/domain/entities/project.dart';
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
  testWidgets('Server-Titel „Inbox" erscheint deutsch als „Aufgaben"', (
    tester,
  ) async {
    final l10n = await loadDe(tester);
    final inbox = Project(id: 1, title: 'Inbox');

    expect(projectDisplayTitle(l10n, inbox), 'Aufgaben');
    // Der gespeicherte Titel bleibt unangetastet, sonst würde ein Speichern
    // die Liste auch im Web-Client umbenennen.
    expect(inbox.title, 'Inbox');
  });

  testWidgets('Favoriten-Pseudo-Projekt (ID -1) wird übersetzt', (
    tester,
  ) async {
    final l10n = await loadDe(tester);

    expect(
      projectDisplayTitle(l10n, Project(id: -1, title: 'Favorites')),
      'Favoriten',
    );
  });

  testWidgets('Eigene Listennamen bleiben unverändert', (tester) async {
    final l10n = await loadDe(tester);

    expect(
      projectDisplayTitle(l10n, Project(id: 5, title: 'Testprojekt')),
      'Testprojekt',
    );
    // Auch eine selbst angelegte Liste, die zufällig „Favorites" heißt,
    // behält ihren Namen — nur das Pseudo-Projekt mit ID -1 wird übersetzt.
    expect(
      projectDisplayTitle(l10n, Project(id: 7, title: 'Favorites')),
      'Favorites',
    );
  });
}
