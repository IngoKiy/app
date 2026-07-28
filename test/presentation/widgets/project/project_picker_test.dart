import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/sync/dto_companion_mapper.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/project_dto.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/project/project_picker.dart';
import 'package:vikunja_app/presentation/widgets/task/add_task_dialog.dart';

final _t = DateTime.utc(2026, 1, 1);
const _mapper = DtoCompanionMapper();

Future<void> _seedProject(
  AppDatabase db, {
  required int id,
  required String title,
  int parentProjectId = 0,
}) {
  final dto = ProjectDto(
    id: id,
    title: title,
    parentProjectId: parentProjectId,
    created: _t,
    updated: _t,
  );
  return db.projectsDao.upsertFromServer(_mapper.project(dto, _t));
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('projectPickerItemsProvider', () {
    test(
      'listet nur echte Projekte (id > 0), keine Filter/Favoriten/Temp',
      () async {
        await _seedProject(db, id: 1, title: 'Echt A');
        await _seedProject(db, id: 2, title: 'Echt B');
        // Favoriten-Pseudo (-1), gespeicherter Filter (-2), offline Temp (-5).
        await _seedProject(db, id: -1, title: 'Favoriten');
        await _seedProject(db, id: -2, title: 'Gespeicherter Filter');
        await _seedProject(db, id: -5, title: 'Offline-Temp');

        final items = await container().read(projectPickerItemsProvider.future);

        expect(items.map((i) => i.project.id).toSet(), {1, 2});
      },
    );

    test(
      'sortiert Unterprojekte unter ihr Elternprojekt (mit Tiefe)',
      () async {
        await _seedProject(db, id: 1, title: 'Eltern');
        await _seedProject(db, id: 2, title: 'Kind', parentProjectId: 1);
        await _seedProject(db, id: 3, title: 'Solo');

        final items = await container().read(projectPickerItemsProvider.future);
        final byId = {for (final i in items) i.project.id: i};

        // Kind folgt direkt auf Eltern und ist tiefer eingerückt.
        final ids = items.map((i) => i.project.id).toList();
        expect(ids.indexOf(2), ids.indexOf(1) + 1);
        expect(byId[1]!.depth, 0);
        expect(byId[2]!.depth, 1);
        expect(byId[3]!.depth, 0);
      },
    );
  });

  group('AddTaskDialog mit Projektauswahl', () {
    testWidgets('legt mit dem gewählten (Default-)Projekt an', (tester) async {
      await _seedProject(db, id: 7, title: 'Standardprojekt');
      await _seedProject(db, id: 8, title: 'Anderes Projekt');

      int? capturedProjectId;
      String? capturedTitle;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: AddTaskDialog(
                defaultProjectId: 7,
                selectableProject: true,
                onAddTask: (title, dueDate, projectId) {
                  capturedTitle = title;
                  capturedProjectId = projectId;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Neue Aufgabe');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(capturedTitle, 'Neue Aufgabe');
      expect(capturedProjectId, 7);

      await _drainDriftStreamTimers(tester);
    });

    testWidgets('übernimmt ein im Picker geändertes Zielprojekt', (
      tester,
    ) async {
      await _seedProject(db, id: 7, title: 'Standardprojekt');
      await _seedProject(db, id: 8, title: 'Anderes Projekt');

      int? capturedProjectId;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: AddTaskDialog(
                defaultProjectId: 7,
                selectableProject: true,
                onAddTask: (title, dueDate, projectId) =>
                    capturedProjectId = projectId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Aufgabe');
      // Picker-Feld öffnen (zeigt aktuell das Standardprojekt).
      await tester.tap(find.text('Standardprojekt'));
      await tester.pumpAndSettle();
      // Anderes Projekt im Auswahldialog wählen.
      await tester.tap(find.text('Anderes Projekt').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(capturedProjectId, 8);

      await _drainDriftStreamTimers(tester);
    });
  });
}

/// Baut den Widgetbaum ab und leert den zero-duration Close-Timer, den der
/// Drift-Stream beim Abbestellen einplant. Ohne das schlägt der Test mit
/// "A Timer is still pending even after the widget tree was disposed" fehl.
Future<void> _drainDriftStreamTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
}
