import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/project_list_model.dart';
import 'package:vikunja_app/presentation/manager/projects_controller.dart';
import 'package:vikunja_app/presentation/pages/project/project_list_page.dart';
import 'package:vikunja_app/presentation/widgets/project/project_card.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

class MockProjectsController extends ProjectsController {
  final ProjectListModel model;
  MockProjectsController(this.model);

  @override
  Future<ProjectListModel> build() async => model;
}

Widget _wrap(ProjectListModel model, {Map<int, int> counts = const {}}) =>
    ProviderScope(
  overrides: [
    projectsControllerProvider.overrideWith(() => MockProjectsController(model)),
    // Zähler-Provider (DB-gestützt) durch statischen Wert ersetzen.
    openTaskCountsProvider.overrideWith((ref) => Stream.value(counts)),
  ],
  child: const MaterialApp(
    home: ProjectListPage(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('en'),
  ),
);

void main() {
  testWidgets('ProjectListPage renders projects as folder cards and can '
      'expand subprojects', (WidgetTester tester) async {
    final subproject = Project(id: 2, title: 'Subproject 1', parentProjectId: 1);
    final parentProject = Project(id: 1, title: 'Parent Project');
    parentProject.subprojects = [subproject];

    await tester.pumpWidget(_wrap(ProjectListModel([parentProject])));
    await tester.pump();

    // Projekt wird als Ordner-Karte dargestellt.
    expect(find.byType(ProjectCard), findsOneWidget);
    expect(find.text('Parent Project'), findsOneWidget);
    expect(find.byIcon(Icons.folder_rounded), findsOneWidget);

    // Subprojekt zunächst eingeklappt, nach Tap auf Expand sichtbar.
    expect(find.text('Subproject 1'), findsNothing);
    await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
    await tester.pump();
    expect(find.text('Subproject 1'), findsOneWidget);
    expect(find.byType(ProjectCard), findsNWidgets(2));
  });

  testWidgets('Saved filters are shown in their own section with a filter icon',
      (WidgetTester tester) async {
    final project = Project(id: 1, title: 'Real Project');
    // Pseudo-Projekt: negative ID < -1 kennzeichnet einen gespeicherten Filter.
    final filter = Project(id: -2, title: 'My Filter');

    await tester.pumpWidget(_wrap(ProjectListModel([project, filter])));
    await tester.pump();

    expect(find.text('Filters'), findsOneWidget); // Abschnitts-Überschrift
    expect(find.text('My Filter'), findsOneWidget);
    // Filter bekommt das Trichter-Icon statt eines Ordner-Icons.
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.folder_rounded), findsOneWidget); // nur das Projekt
  });
}
