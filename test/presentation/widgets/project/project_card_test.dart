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
  testWidgets('renders folder icon in project color, count and favourite star',
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
    expect(find.text('3 open tasks'), findsOneWidget);

    // Ordner-Icon in der Projektfarbe (farbiges Badge).
    expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    final badge = tester.widget<Container>(
      find.ancestor(
        of: find.byIcon(Icons.folder_rounded),
        matching: find.byType(Container),
      ),
    );
    expect((badge.decoration as BoxDecoration).color, projectColor);

    // Favoriten-Stern und Öffnen-Affordanz.
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('saved filter shows filter icon and filter label', (
    WidgetTester tester,
  ) async {
    final filter = Project(id: -2, title: 'Due soon');

    await tester.pumpWidget(_wrap(ProjectCard(project: filter)));

    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.folder_rounded), findsNothing);
    expect(find.text('Filter'), findsOneWidget);
  });

  testWidgets('single open task uses singular subtitle', (
    WidgetTester tester,
  ) async {
    final project = Project(id: 1, title: 'Home');
    await tester.pumpWidget(
      _wrap(ProjectCard(project: project, openTaskCount: 1)),
    );
    expect(find.text('1 open task'), findsOneWidget);
  });
}
