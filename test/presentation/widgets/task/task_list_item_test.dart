import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/task/task_list_item.dart';

/// Baut den Widget-Baum ab, bevor tearDown die DB schließt — sonst hält der
/// noch abonnierte Drift-Stream (taskInMyDayProvider) db.close() endlos auf.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
}

Widget _wrap(Widget child, AppDatabase db) => ProviderScope(
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

  testWidgets('shows the originating project as a coloured chip', (
    WidgetTester tester,
  ) async {
    const projectColor = Color(0xFF009688);
    final task = Task(
      id: 1,
      title: 'Water the plants',
      createdBy: User(username: 'demo'),
      projectId: 5,
    );
    task.project = Project(id: 5, title: 'Balcony', color: projectColor);

    await tester.pumpWidget(
      _wrap(
        TaskListItem(
          task: task,
          onTap: () {},
          onEdit: () {},
          onCheckedChanged: (_) {},
        ),
        db,
      ),
    );

    // Herkunft ist als Projektname sichtbar.
    expect(find.text('Balcony'), findsOneWidget);

    // Der farbige Punkt trägt die Projektfarbe. (Gefüllter Kreis — der leere
    // Kreis der runden Checkbox hat keine Füllfarbe.)
    final dot = tester.widgetList<Container>(find.byType(Container)).firstWhere(
      (c) =>
          c.decoration is BoxDecoration &&
          (c.decoration as BoxDecoration).shape == BoxShape.circle &&
          (c.decoration as BoxDecoration).color != null,
    );
    expect((dot.decoration as BoxDecoration).color, projectColor);

    await _unmount(tester);
  });

  testWidgets('Tipp öffnet Bearbeiten, Long-Press die Schnellvorschau', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    var detailsShown = false;
    final task = Task(
      id: 1,
      title: 'Water the plants',
      createdBy: User(username: 'demo'),
      projectId: 5,
    );

    await tester.pumpWidget(
      _wrap(
        TaskListItem(
          task: task,
          onTap: () => tapped = true,
          onEdit: () {},
          onCheckedChanged: (_) {},
          onShowDetails: () => detailsShown = true,
        ),
        db,
      ),
    );

    await tester.tap(find.text('Water the plants'));
    expect(tapped, isTrue);
    expect(detailsShown, isFalse);

    await tester.longPress(find.text('Water the plants'));
    expect(detailsShown, isTrue);

    await _unmount(tester);
  });

  testWidgets('Stern zeigt Favoritenstatus und feuert den Toggle', (
    WidgetTester tester,
  ) async {
    var toggled = false;
    final task = Task(
      id: 1,
      title: 'Water the plants',
      createdBy: User(username: 'demo'),
      projectId: 5,
      isFavorite: true,
    );

    await tester.pumpWidget(
      _wrap(
        TaskListItem(
          task: task,
          onTap: () {},
          onEdit: () {},
          onCheckedChanged: (_) {},
          onFavoriteToggle: () => toggled = true,
        ),
        db,
      ),
    );

    // Favorit → gefüllter Stern.
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNothing);

    await tester.tap(find.byIcon(Icons.star));
    expect(toggled, isTrue);

    await _unmount(tester);
  });

  testWidgets('Wischen nach rechts hakt die Aufgabe ab', (
    WidgetTester tester,
  ) async {
    bool? checkedValue;
    final task = Task(
      id: 1,
      title: 'Water the plants',
      createdBy: User(username: 'demo'),
      projectId: 5,
      done: false,
    );

    await tester.pumpWidget(
      _wrap(
        TaskListItem(
          task: task,
          onTap: () {},
          onEdit: () {},
          onCheckedChanged: (value) => checkedValue = value,
        ),
        db,
      ),
    );

    // Nach rechts wischen (startToEnd) löst das Abhaken aus; die Zeile bleibt
    // bestehen (confirmDismiss liefert false, Dismissible federt zurück).
    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(checkedValue, isTrue);
    expect(find.byType(Dismissible), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('zeigt den Schritte-Fortschritt "x von y" in der Metazeile', (
    WidgetTester tester,
  ) async {
    final task = Task(
      id: 1,
      title: 'Water the plants',
      createdBy: User(username: 'demo'),
      projectId: 5,
      description:
          '<ul data-type="taskList">'
          '<li data-checked="true" data-type="taskItem"><p>Fill can</p></li>'
          '<li data-checked="false" data-type="taskItem"><p>Water</p></li>'
          '</ul>',
    );

    await tester.pumpWidget(
      _wrap(
        TaskListItem(
          task: task,
          onTap: () {},
          onEdit: () {},
          onCheckedChanged: (_) {},
        ),
        db,
      ),
    );

    expect(find.text('1 of 2'), findsOneWidget);

    await _unmount(tester);
  });
}
