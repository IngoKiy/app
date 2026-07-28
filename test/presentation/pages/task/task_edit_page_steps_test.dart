import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/core/utils/task_steps.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_page_model.dart';
import 'package:vikunja_app/domain/repositories/task_repository.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/manager/task_page_controller.dart';
import 'package:vikunja_app/presentation/pages/task/task_edit_page.dart';

import '../../../core/offline/offline_test_fakes.dart';

// Deckt den Schritte-Editor der Detailseite end-to-end ab: neue Zeile
// hinzufügen, Text eingeben, abhaken — und prüfen, dass das gespeicherte
// updateTask-Payload die Checkliste im TipTap-Format enthält (siehe
// lib/core/utils/task_steps.dart für das Format).

final _t = DateTime.utc(2026, 1, 1);
const _mapper = DtoCompanionMapper();

// taskPageControllerProvider ist autoDispose: sobald in einem Test mehrere
// Schritt-Interaktionen hintereinander je einen ref.read(...notifier) lösen
// (Debounce + späteres Immediate-Save), kann der Provider zwischendurch
// abgebaut und neu erzeugt werden. overrideWith muss daher bei jedem Aufbau
// eine frische Notifier-Instanz liefern (sonst schlägt die interne
// late-Feld-Initialisierung beim zweiten Mal fehl) — das erfasste Ergebnis
// wird deshalb in einer externen Box statt im Notifier selbst gehalten.
class _CapturedBox {
  Task? captured;
}

class _MockTaskPageController extends TaskPageController {
  _MockTaskPageController(this._box);

  final _CapturedBox _box;

  @override
  Future<TaskPageModel> build() async => TaskPageModel([], false, 0, false);

  @override
  Future<bool> updateTask(Task task) async {
    _box.captured = task;
    return true;
  }
}

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

Future<_CapturedBox> _pumpEditPage(
  WidgetTester tester,
  AppDatabase db,
  Task task,
) async {
  final box = _CapturedBox();
  final navKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        offlineWriterProvider.overrideWithValue(
          buildWriter(db, buildExecutor(db)),
        ),
        taskRepositoryProvider.overrideWithValue(_FakeTaskRepository()),
        taskPageControllerProvider.overrideWith(
          () => _MockTaskPageController(box),
        ),
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

  return box;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets(
    'Schritt hinzufügen + abhaken speichert die Checkliste als TipTap-HTML',
    (tester) async {
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

      final box = await _pumpEditPage(tester, db, task);

      // Noch keine Schritte vorhanden.
      expect(find.text('Next step'), findsOneWidget);

      // Neue Zeile hinzufügen und Text eintragen.
      await tester.tap(find.text('Next step'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, 'Milch kaufen');
      await tester.pump();

      // Direkt abhaken (immediate) — löst den Autosave sofort aus, ohne auf
      // den Text-Debounce warten zu müssen.
      await tester.tap(find.byType(InkResponse).last);
      await tester.pumpAndSettle();

      expect(box.captured, isNotNull);
      final savedDescription = box.captured!.description;
      final steps = parseSteps(savedDescription);
      expect(steps, hasLength(1));
      expect(steps.single.text, 'Milch kaufen');
      expect(steps.single.done, isTrue);
      expect(
        savedDescription,
        contains('data-type="taskList"'),
        reason: 'Schritte müssen als TipTap-Checkliste codiert sein',
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Bestehende Schritte werden geladen und die Notiz-Kachel zeigt nur den Text ohne Checkliste',
    (tester) async {
      await _seedProject(db, id: 1, title: 'Projekt Eins');

      final description = buildDescription(
        note: '<p>Wochenendplanung</p>',
        steps: const [TaskStep('Getränke', done: true), TaskStep('Snacks')],
      );

      final task = Task(
        id: 7,
        title: 'Party',
        createdBy: null,
        projectId: 1,
        priority: 0,
        description: description,
        created: _t,
        updated: _t,
      );

      await _pumpEditPage(tester, db, task);

      expect(find.text('Getränke'), findsOneWidget);
      expect(find.text('Snacks'), findsOneWidget);

      // Notiz-Kachel zeigt nur die Notiz — ohne die Checklisten-Tags, die
      // stattdessen im Schritte-Editor darüber angezeigt werden. Die Kachel
      // sitzt am Ende der langen Formularliste, also erst dorthin scrollen.
      await tester.scrollUntilVisible(
        find.byType(HtmlWidget),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
      expect(htmlWidget.html, '<p>Wochenendplanung</p>');
      expect(htmlWidget.html, isNot(contains('taskList')));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
