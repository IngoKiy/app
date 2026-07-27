import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/project/project_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

void main() {
  testWidgets(
    'flache To-Do-Zeile: Listen-Icon in Projektfarbe, Zähler, Stern',
    (WidgetTester tester) async {
      const projectColor = Color(0xFF3F51B5);
      final project = Project(
        id: 1,
        title: 'Groceries',
        color: projectColor,
        isFavourite: true,
      );

      await tester.pumpWidget(
        _wrap(ProjectCard(project: project, openTaskCount: 3)),
      );

      expect(find.text('Groceries'), findsOneWidget);
      // Zähler als dezente Zahl rechts (kein Untertitel mehr).
      expect(find.text('3'), findsOneWidget);

      // Kleines Listen-Icon in der Projektfarbe statt Ordner-Badge.
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.format_list_bulleted),
      );
      expect(icon.color, projectColor);

      // Favoriten-Stern; ohne Kinder kein Chevron.
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
    },
  );

  testWidgets('Gruppe zeigt Ordner-Icon und Auf-/Zuklapp-Chevron', (
    WidgetTester tester,
  ) async {
    final group = Project(id: 1, title: 'Team');

    await tester.pumpWidget(
      _wrap(ProjectCard(project: group, expandable: true)),
    );

    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
  });

  testWidgets('saved filter shows filter icon', (WidgetTester tester) async {
    final filter = Project(id: -2, title: 'Due soon');

    await tester.pumpWidget(_wrap(ProjectCard(project: filter)));

    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
  });
}
