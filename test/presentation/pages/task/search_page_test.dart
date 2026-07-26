import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_page_model.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/task/search_page.dart';
import 'package:vikunja_app/presentation/widgets/task/round_checkbox.dart';

/// Erfasst den beim Abhaken/Favorisieren übergebenen Task; ansonsten
/// No-Op-Controller (kein Netzwerk/Outbox-Zugriff nötig).
class _MockTaskPageController extends TaskPageController {
  Task? captured;

  @override
  Future<TaskPageModel> build() async => TaskPageModel([], false, 0, false);

  @override
  Future<bool> updateTask(Task task) async {
    captured = task;
    return true;
  }
}

Future<void> _seedTask(
  AppDatabase db, {
  required int id,
  required String title,
  String description = '',
}) => db
    .into(db.tasks)
    .insert(
      TasksCompanion.insert(
        id: Value(id),
        projectId: 1,
        title: title,
        description: Value(description),
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-01T00:00:00.000Z',
        rawJson:
            '{"id":$id,"title":"$title","project_id":1,'
            '"description":"$description","done":false,'
            '"updated":"2026-01-01T00:00:00.000Z",'
            '"created":"2026-01-01T00:00:00.000Z"}',
      ),
    );

void main() {
  late AppDatabase db;
  late _MockTaskPageController mock;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mock = _MockTaskPageController();
  });
  tearDown(() => db.close());

  Future<void> pumpSearchPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          taskPageControllerProvider.overrideWith(() => mock),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SearchPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Drift-Stream beim Abbau: zero-duration Close-Timer leeren, sonst
  // "A Timer is still pending even after the widget tree was disposed"
  // (siehe task_edit_page_test.dart).
  Future<void> flushDisposeTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  }

  testWidgets('Leere Eingabe zeigt keine Treffer', (tester) async {
    await _seedTask(db, id: 1, title: 'Milch kaufen');

    await pumpSearchPage(tester);

    expect(find.byType(ListView), findsNothing);
    expect(find.text('No results'), findsNothing);

    await flushDisposeTimers(tester);
  });

  testWidgets('Suche filtert reaktiv nach Titel (debounced)', (tester) async {
    await _seedTask(db, id: 1, title: 'Milch kaufen');
    await _seedTask(db, id: 2, title: 'Bericht schreiben');

    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'Milch');
    // Debounce (~300ms) noch nicht abgelaufen.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Milch kaufen'), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Milch kaufen'), findsOneWidget);
    expect(find.text('Bericht schreiben'), findsNothing);

    await flushDisposeTimers(tester);
  });

  testWidgets('Kein Treffer zeigt EmptyState mit l10n-Text', (tester) async {
    await _seedTask(db, id: 1, title: 'Milch kaufen');

    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'xyz-nichts');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('No results'), findsOneWidget);

    await flushDisposeTimers(tester);
  });

  testWidgets('Abhaken eines Treffers ruft updateTask mit done=true', (
    tester,
  ) async {
    await _seedTask(db, id: 1, title: 'Milch kaufen');

    await pumpSearchPage(tester);

    await tester.enterText(find.byType(TextField), 'Milch');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Milch kaufen'), findsOneWidget);

    await tester.tap(find.byType(RoundCheckbox).first);
    await tester.pumpAndSettle();

    expect(mock.captured, isNotNull);
    expect(mock.captured!.id, 1);
    expect(mock.captured!.done, isTrue);

    await flushDisposeTimers(tester);
  });
}
