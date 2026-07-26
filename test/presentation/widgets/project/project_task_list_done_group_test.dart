import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/project_page_model.dart';
import 'package:vikunja_app/domain/entities/project_view.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/entities/view_kind.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/project_controller.dart';
import 'package:vikunja_app/presentation/widgets/project/project_task_list.dart';

class _MockProjectController extends ProjectController {
  final ProjectPageModel model;
  _MockProjectController(this.model);

  @override
  Future<ProjectPageModel> build(Project project) async => model;
}

void main() {
  testWidgets(
    'Erledigte Aufgaben stecken eingeklappt in einer eigenen Gruppe',
    (WidgetTester tester) async {
      final user = User(username: 'demo');
      final project = Project(
        id: 1,
        title: 'Project',
        parentProjectId: 0,
        views: [
          ProjectView(
            DateTime.now(),
            0,
            0,
            1,
            0.0,
            1,
            'List View',
            DateTime.now(),
            null,
            [],
            'manual',
            ViewKind.list,
          ),
        ],
      );

      final openTask = Task(
        id: 1,
        title: 'Open task',
        createdBy: user,
        projectId: 1,
        done: false,
      );
      final doneTask = Task(
        id: 2,
        title: 'Done task',
        createdBy: user,
        projectId: 1,
        done: true,
      );

      final model = ProjectPageModel(
        project,
        0,
        [openTask, doneTask],
        [],
        true,
        false,
      );
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            projectControllerProvider(
              project,
            ).overrideWith(() => _MockProjectController(model)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(body: ProjectTaskList(project)),
          ),
        ),
      );

      await tester.pump();

      // Offene Aufgabe ist sofort sichtbar.
      expect(find.text('Open task'), findsOneWidget);

      // Erledigte Aufgabe steckt zunächst eingeklappt in der Gruppe.
      expect(find.text('Completed 1'), findsOneWidget);
      expect(find.text('Done task'), findsNothing);

      // Tipp auf die Kopfzeile klappt die Gruppe auf.
      await tester.tap(find.text('Completed 1'));
      await tester.pumpAndSettle();

      expect(find.text('Done task'), findsOneWidget);

      // Erneuter Tipp klappt wieder ein.
      await tester.tap(find.text('Completed 1'));
      await tester.pumpAndSettle();

      expect(find.text('Done task'), findsNothing);
    },
  );
}
