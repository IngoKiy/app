import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/utils/task_steps.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/task/steps_editor.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('zeigt bestehende Schritte, erledigte durchgestrichen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        StepsEditor(
          steps: const [TaskStep('Milch kaufen'), TaskStep('Brot', done: true)],
          onTextChanged: (_, _) {},
          onToggle: (_, _) {},
          onRemove: (_) {},
          onAdd: () {},
        ),
      ),
    );

    expect(find.text('Milch kaufen'), findsOneWidget);
    expect(find.text('Brot'), findsOneWidget);

    final doneField = tester.widget<EditableText>(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Brot'),
        matching: find.byType(EditableText),
      ),
    );
    expect(
      doneField.style.decoration,
      TextDecoration.lineThrough,
      reason: 'Erledigter Schritt soll durchgestrichen dargestellt werden',
    );
  });

  testWidgets('"+ Nächster Schritt" ruft onAdd auf', (tester) async {
    var addCalled = false;
    await tester.pumpWidget(
      _wrap(
        StepsEditor(
          steps: const [],
          onTextChanged: (_, _) {},
          onToggle: (_, _) {},
          onRemove: (_) {},
          onAdd: () => addCalled = true,
        ),
      ),
    );

    expect(find.text('Next step'), findsOneWidget);
    await tester.tap(find.text('Next step'));
    await tester.pump();

    expect(addCalled, isTrue);
  });

  testWidgets('Text eingeben meldet Index + neuen Text', (tester) async {
    int? changedIndex;
    String? changedText;
    await tester.pumpWidget(
      _wrap(
        StepsEditor(
          steps: const [TaskStep('')],
          onTextChanged: (index, text) {
            changedIndex = index;
            changedText = text;
          },
          onToggle: (_, _) {},
          onRemove: (_) {},
          onAdd: () {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Käse holen');
    await tester.pump();

    expect(changedIndex, 0);
    expect(changedText, 'Käse holen');
  });

  testWidgets('Checkbox tippen meldet Abhaken', (tester) async {
    int? toggledIndex;
    bool? toggledDone;
    await tester.pumpWidget(
      _wrap(
        StepsEditor(
          steps: const [TaskStep('Milch kaufen')],
          onTextChanged: (_, _) {},
          onToggle: (index, done) {
            toggledIndex = index;
            toggledDone = done;
          },
          onRemove: (_) {},
          onAdd: () {},
        ),
      ),
    );

    // RoundCheckbox reagiert auf InkResponse-Tap.
    await tester.tap(find.byType(InkResponse));
    await tester.pump();

    expect(toggledIndex, 0);
    expect(toggledDone, isTrue);
  });

  testWidgets('X-Button meldet Entfernen', (tester) async {
    int? removedIndex;
    await tester.pumpWidget(
      _wrap(
        StepsEditor(
          steps: const [TaskStep('Milch kaufen')],
          onTextChanged: (_, _) {},
          onToggle: (_, _) {},
          onRemove: (index) => removedIndex = index,
          onAdd: () {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(removedIndex, 0);
  });
}
