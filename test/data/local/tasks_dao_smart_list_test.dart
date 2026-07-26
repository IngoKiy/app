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
          title: 'T$id',
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: updatedAt,
          rawJson:
              '{"id":$id,"title":"T$id","project_id":1,"description":"",'
              '"done":$done,"updated":"$updatedAt",'
              '"created":"2026-01-01T00:00:00.000Z"}',
          done: Value(done),
          isFavorite: Value(favorite),
          dueDate: Value(dueDate),
          isDeleted: Value(deleted),
        ),
      );

  Future<List<int>> ids(SmartList list) async => (await db.tasksDao
          .watchSmartList(list, endOfTodayIso: endOfToday)
          .first)
      .map((r) => r.id)
      .toList();

  Future<int> count(SmartList list) =>
      db.tasksDao.watchSmartListCount(list, endOfTodayIso: endOfToday).first;

  test('Mein Tag: heute fällig + überfällig, ohne erledigte/gelöschte',
      () async {
    await seed(id: 1, dueDate: iso(now.subtract(const Duration(days: 1))));
    await seed(id: 2, dueDate: iso(now));
    await seed(id: 3, dueDate: iso(now.add(const Duration(days: 1))));
    await seed(id: 4); // ohne Fälligkeit
    await seed(id: 5, dueDate: iso(now), done: true);
    await seed(id: 6, dueDate: iso(now), deleted: true);

    expect(await ids(SmartList.today), [1, 2]);
    expect(await count(SmartList.today), 2);
  });

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
}
