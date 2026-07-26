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

// Deckt das Wiederholen-Preset-Mapping der Detailseite ab: Erkennung eines
// Presets beim Laden (exakter Match vs. „Benutzerdefiniert") sowie das
// Zurückschreiben der Werte, wenn der Nutzer ein Preset auswählt.

final _t = DateTime.utc(2026, 1, 1);
const _mapper = DtoCompanionMapper();

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

Task _taskWithRepeat({required Duration? repeatAfter}) => Task(
  id: 5,
  title: 'Aufgabe',
  createdBy: null,
  projectId: 1,
  priority: 0,
  repeatAfter: repeatAfter,
  created: _t,
  updated: _t,
);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> teardownPage(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  }

  testWidgets('Ohne Wiederholung wird "Never" (Preset Nie) erkannt', (
    tester,
  ) async {
    await _seedProject(db, id: 1, title: 'Projekt Eins');
    await _pumpEditPage(tester, db, _taskWithRepeat(repeatAfter: null));

    expect(find.text('Never'), findsOneWidget);
    await teardownPage(tester);
  });

  testWidgets('1 Tag wird als "Daily" erkannt', (tester) async {
    await _seedProject(db, id: 1, title: 'Projekt Eins');
    await _pumpEditPage(
      tester,
      db,
      _taskWithRepeat(repeatAfter: const Duration(days: 1)),
    );

    expect(find.text('Daily'), findsOneWidget);
    await teardownPage(tester);
  });

  testWidgets('7 Tage werden als "Weekly" erkannt', (tester) async {
    await _seedProject(db, id: 1, title: 'Projekt Eins');
    await _pumpEditPage(
      tester,
      db,
      _taskWithRepeat(repeatAfter: const Duration(days: 7)),
    );

    expect(find.text('Weekly'), findsOneWidget);
    await teardownPage(tester);
  });

  testWidgets('30 Tage werden als "Monthly" erkannt', (tester) async {
    await _seedProject(db, id: 1, title: 'Projekt Eins');
    await _pumpEditPage(
      tester,
      db,
      _taskWithRepeat(repeatAfter: const Duration(days: 30)),
    );

    expect(find.text('Monthly'), findsOneWidget);
    await teardownPage(tester);
  });

  testWidgets('365 Tage werden als "Yearly" erkannt', (tester) async {
    await _seedProject(db, id: 1, title: 'Projekt Eins');
    await _pumpEditPage(
      tester,
      db,
      _taskWithRepeat(repeatAfter: const Duration(days: 365)),
    );

    expect(find.text('Yearly'), findsOneWidget);
    await teardownPage(tester);
  });

  testWidgets(
    'Alle 3 Tage hat keine exakte Entsprechung -> "Custom", Felder sichtbar',
    (tester) async {
      await _seedProject(db, id: 1, title: 'Projekt Eins');
      await _pumpEditPage(
        tester,
        db,
        _taskWithRepeat(repeatAfter: const Duration(days: 3)),
      );

      expect(find.text('Custom'), findsOneWidget);
      // Die ausgeklappten Benutzerdefiniert-Felder zeigen den Rohwert.
      expect(find.text('3'), findsOneWidget);
      await teardownPage(tester);
    },
  );

  testWidgets(
    'Preset "Weekly" auswählen speichert 7 Tage (updateTask-Payload)',
    (tester) async {
      await _seedProject(db, id: 1, title: 'Projekt Eins');
      final box = await _pumpEditPage(
        tester,
        db,
        _taskWithRepeat(repeatAfter: null),
      );

      expect(find.text('Never'), findsOneWidget);

      await tester.tap(find.text('Never'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly').last);
      await tester.pumpAndSettle();

      expect(box.captured, isNotNull);
      expect(box.captured!.repeatAfter, const Duration(days: 7));

      await teardownPage(tester);
    },
  );
}
