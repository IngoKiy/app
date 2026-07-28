import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/smart_list.dart';

/// Smart-List-Queries (MS-To-Do-Stil) auf der lokalen Tasks-Tabelle.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  final now = DateTime.now();
  final endOfToday = endOfTodayUtcIso(now);
  String iso(DateTime dt) => dt.toUtc().toIso8601String();

  Future<void> seed({
    required int id,
    String? title,
    String description = '',
    String? dueDate,
    bool done = false,
    bool favorite = false,
    bool deleted = false,
    String updatedAt = '2026-01-01T00:00:00.000Z',
  }) => db
      .into(db.tasks)
      .insert(
        TasksCompanion.insert(
          id: Value(id),
          projectId: 1,
          title: title ?? 'T$id',
          description: Value(description),
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: updatedAt,
          rawJson:
              '{"id":$id,"title":"${title ?? 'T$id'}","project_id":1,'
              '"description":"$description",'
              '"done":$done,"updated":"$updatedAt",'
              '"created":"2026-01-01T00:00:00.000Z"}',
          done: Value(done),
          isFavorite: Value(favorite),
          dueDate: Value(dueDate),
          isDeleted: Value(deleted),
        ),
      );

  final dayKey = localDayKey(now);

  Future<List<int>> ids(SmartList list, {int? userId}) async =>
      (await db.tasksDao
              .watchSmartList(
                list,
                endOfTodayIso: endOfToday,
                dayKey: dayKey,
                userId: userId,
              )
              .first)
          .map((r) => r.id)
          .toList();

  Future<int> count(SmartList list, {int? userId}) => db.tasksDao
      .watchSmartListCount(
        list,
        endOfTodayIso: endOfToday,
        dayKey: dayKey,
        userId: userId,
      )
      .first;

  test(
    'Mein Tag: heute fällig + überfällig, ohne erledigte/gelöschte',
    () async {
      await seed(id: 1, dueDate: iso(now.subtract(const Duration(days: 1))));
      await seed(id: 2, dueDate: iso(now));
      await seed(id: 3, dueDate: iso(now.add(const Duration(days: 1))));
      await seed(id: 4); // ohne Fälligkeit
      await seed(id: 5, dueDate: iso(now), done: true);
      await seed(id: 6, dueDate: iso(now), deleted: true);

      expect(await ids(SmartList.today), [1, 2]);
      expect(await count(SmartList.today), 2);
    },
  );

  test('Wichtig: nur offene Favoriten', () async {
    await seed(id: 1, favorite: true);
    await seed(id: 2, favorite: true, done: true);
    await seed(id: 3);

    expect(await ids(SmartList.important), [1]);
    expect(await count(SmartList.important), 1);
  });

  test('Geplant: nur mit Fälligkeit, nach Fälligkeit sortiert', () async {
    await seed(id: 1, dueDate: iso(now.add(const Duration(days: 5))));
    await seed(id: 2, dueDate: iso(now.add(const Duration(days: 1))));
    await seed(id: 3); // ohne Fälligkeit

    expect(await ids(SmartList.planned), [2, 1]);
    expect(await count(SmartList.planned), 2);
  });

  test('Alle: offene Aufgaben, ohne Fälligkeit ans Ende', () async {
    await seed(id: 1); // ohne Fälligkeit
    await seed(id: 2, dueDate: iso(now));
    await seed(id: 3, done: true);

    expect(await ids(SmartList.all), [2, 1]);
    expect(await count(SmartList.all), 2);
  });

  test('Erledigt: erledigte Aufgaben, zuletzt geänderte zuerst', () async {
    await seed(id: 1, done: true, updatedAt: '2026-07-01T00:00:00.000Z');
    await seed(id: 2, done: true, updatedAt: '2026-07-20T00:00:00.000Z');
    await seed(id: 3);

    expect(await ids(SmartList.completed), [2, 1]);
  });

  test('Mein Tag Hybrid: manuell Hinzugefügtes erscheint zusätzlich', () async {
    await seed(id: 1); // ohne Fälligkeit
    await seed(id: 2, dueDate: iso(now));

    await db.tasksDao.addToMyDay(1, dayKey);
    expect(await ids(SmartList.today), [2, 1]);
    expect(await count(SmartList.today), 2);

    await db.tasksDao.removeFromMyDay(1, dayKey);
    expect(await ids(SmartList.today), [2]);
  });

  test(
    'Mein Tag: Einträge früherer Tage verfallen beim nächsten Hinzufügen',
    () async {
      await seed(id: 1);
      await seed(id: 2);

      await db.tasksDao.addToMyDay(1, '2020-01-01');
      expect(await ids(SmartList.today), isEmpty); // alter Tag zählt nicht

      await db.tasksDao.addToMyDay(2, dayKey); // räumt alte Einträge weg
      expect(await ids(SmartList.today), [2]);
      expect(await db.tasksDao.watchInMyDay(1, '2020-01-01').first, isFalse);
    },
  );

  test('Mir zugewiesen: nur offene Aufgaben mit eigener Zuweisung', () async {
    await seed(id: 1);
    await seed(id: 2);
    await seed(id: 3, done: true);
    await db
        .into(db.taskAssignees)
        .insert(TaskAssigneesCompanion.insert(taskId: 1, userId: 7));
    await db
        .into(db.taskAssignees)
        .insert(TaskAssigneesCompanion.insert(taskId: 3, userId: 7));

    expect(await ids(SmartList.assignedToMe, userId: 7), [1]);
    expect(await count(SmartList.assignedToMe, userId: 7), 1);
    // Ohne bekannten Benutzer (offline vor erstem Login): leer.
    expect(await ids(SmartList.assignedToMe), isEmpty);
  });

  test('Suche: Titel + Beschreibung, case-insensitiv, Offene zuerst', () async {
    await seed(id: 1, title: 'Dach reparieren');
    await seed(id: 2, title: 'Einkaufen', description: 'Dachrinne besorgen');
    await seed(id: 3, title: 'DACH prüfen', done: true);
    await seed(id: 4, title: 'Unrelated');

    final rows = await db.tasksDao.watchSearch('dach').first;
    expect(rows.map((r) => r.id).toList(), [1, 2, 3]);
  });
}
