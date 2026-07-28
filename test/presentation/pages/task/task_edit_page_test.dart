import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_page_model.dart';
import 'package:vikunja_app/domain/repositories/task_repository.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/task/task_edit_page.dart';

import '../../../core/offline/offline_test_fakes.dart';

final _t = DateTime.utc(2026, 1, 1);
const _mapper = DtoCompanionMapper();

/// Erfasst den beim Speichern übergebenen Task; ansonsten No-Op-Controller.
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

/// Fake-Repository: liefert nur leere Anhang-Header (Attachments-Section init).
class _FakeTaskRepository implements TaskRepository {
  @override
  Future<Map<String, String>> attachmentHeaders() async => const {};

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

Future<void> _seedProject(
  AppDatabase db, {
  required int id,
  required String title,
}) {
  final dto = ProjectDto(id: id, title: title, created: _t, updated: _t);
  return db.projectsDao.upsertFromServer(_mapper.project(dto, _t));
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets(
    'Projektwechsel setzt projectId und ruft updateTask mit neuem Projekt',
    (tester) async {
      await _seedProject(db, id: 1, title: 'Projekt Eins');
      await _seedProject(db, id: 2, title: 'Projekt Zwei');

      final task = Task(
        id: 5,
        title: 'Aufgabe',
        createdBy: null,
        projectId: 1,
        // Priorität explizit gesetzt: der Prioritäts-Dropdown der Edit-Seite
        // verlangt einen Wert, der genau einem Eintrag entspricht (null -> '').
        priority: 0,
        created: _t,
        updated: _t,
      );

      final mock = _MockTaskPageController();
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            offlineWriterProvider.overrideWithValue(
              buildWriter(db, buildExecutor(db)),
            ),
            taskRepositoryProvider.overrideWithValue(_FakeTaskRepository()),
            taskPageControllerProvider.overrideWith(() => mock),
          ],
          child: MaterialApp(
            navigatorKey: navKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: SizedBox()),
          ),
        ),
      );

      navKey.currentState!.push(
        MaterialPageRoute(builder: (_) => TaskEditPage(task: task)),
      );
      await tester.pumpAndSettle();

      // Kein Speichern-Button mehr — Änderungen werden automatisch gesichert.
      expect(find.byIcon(Icons.save), findsNothing);

      // Projekt ist jetzt eine To-Do-Aktionszeile im Hauptteil; Tipp öffnet
      // das Auswahl-Sheet.
      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(find.text('Projekt Eins'), findsOneWidget);
      await tester.tap(find.text('Projekt Eins'));
      await tester.pumpAndSettle();

      // Diskretes Feld: Autosave feuert sofort, ohne Speichern-Button.
      await tester.tap(find.text('Projekt Zwei').last);
      await tester.pumpAndSettle();

      expect(mock.captured, isNotNull);
      expect(mock.captured!.id, 5);
      expect(mock.captured!.projectId, 2);

      // Drift-Stream beim Abbau: zero-duration Close-Timer leeren, sonst
      // "A Timer is still pending even after the widget tree was disposed".
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Titeländerung speichert automatisch nach Tipppause', (
    tester,
  ) async {
    await _seedProject(db, id: 1, title: 'Projekt Eins');

    final task = Task(
      id: 5,
      title: 'Aufgabe',
      createdBy: null,
      projectId: 1,
      priority: 0,
      created: _t,
      updated: _t,
    );

    final mock = _MockTaskPageController();
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          offlineWriterProvider.overrideWithValue(
            buildWriter(db, buildExecutor(db)),
          ),
          taskRepositoryProvider.overrideWithValue(_FakeTaskRepository()),
          taskPageControllerProvider.overrideWith(() => mock),
        ],
        child: MaterialApp(
          navigatorKey: navKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: SizedBox()),
        ),
      ),
    );

    navKey.currentState!.push(
      MaterialPageRoute(builder: (_) => TaskEditPage(task: task)),
    );
    await tester.pumpAndSettle();

    // Erstes Textfeld ist der Titel.
    await tester.enterText(find.byType(TextFormField).first, 'Neuer Titel');

    // Debounce (1,5 s) noch nicht abgelaufen: noch kein Save.
    await tester.pump(const Duration(milliseconds: 500));
    expect(mock.captured, isNull);

    // Nach der Tipppause wird automatisch gespeichert.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
    expect(mock.captured, isNotNull);
    expect(mock.captured!.title, 'Neuer Titel');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
