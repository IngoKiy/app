import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/task/task_list_item.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

void main() {
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
      ),
    );

    // Herkunft ist als Projektname sichtbar.
    expect(find.text('Balcony'), findsOneWidget);

    // Der farbige Punkt trägt die Projektfarbe.
    final dot = tester.widgetList<Container>(find.byType(Container)).firstWhere(
      (c) =>
          c.decoration is BoxDecoration &&
          (c.decoration as BoxDecoration).shape == BoxShape.circle,
    );
    expect((dot.decoration as BoxDecoration).color, projectColor);
  });
}
