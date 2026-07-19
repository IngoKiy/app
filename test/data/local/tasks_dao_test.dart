import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';

import 'test_database.dart';

TasksCompanion _task({
  required int id,
  int? remoteId,
  int projectId = 1,
  String title = 'Task',
  bool isDirty = false,
}) => TasksCompanion.insert(
  id: Value(id),
  projectId: projectId,
  title: title,
  createdAt: '2026-07-19T00:00:00.000Z',
  updatedAt: '2026-07-19T00:00:00.000Z',
  rawJson: '{}',
  remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
  isDirty: Value(isDirty),
);

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('upsertFromServer + watchTask liefert den Task (Schema-Roundtrip)', () async {
    await db.tasksDao.upsertFromServer(
      _task(id: 1, remoteId: 1, title: 'Vom Server'),
    );

    final row = await db.tasksDao.watchTask(1).first;

    expect(row, isNotNull);
    expect(row!.title, 'Vom Server');
    expect(row.remoteId, 1);
    expect(row.isDirty, isFalse);
  });

  test('upsertFromServer überschreibt dirty Datensätze nicht', () async {
    // Lokale, dirty Änderung.
    await db.tasksDao.upsertLocal(
      _task(id: 5, remoteId: 42, title: 'Lokal geändert'),
    );

    // Server liefert eine andere Version desselben remoteId.
    await db.tasksDao.upsertFromServer(
      _task(id: 5, remoteId: 42, title: 'Vom Server überschrieben?'),
    );

    final row = await db.tasksDao.getById(5);
    expect(row, isNotNull);
    expect(row!.title, 'Lokal geändert');
    expect(row.isDirty, isTrue);
  });

  test('upsertFromServer aktualisiert nicht-dirty Datensätze', () async {
    await db.tasksDao.upsertFromServer(_task(id: 1, remoteId: 1, title: 'v1'));
    await db.tasksDao.upsertFromServer(_task(id: 1, remoteId: 1, title: 'v2'));

    final row = await db.tasksDao.getById(1);
    expect(row!.title, 'v2');
  });

  test(
    'deleteMissingClean löscht nicht-dirty Datensätze außerhalb der Liste, '
    'dirty Datensätze bleiben erhalten',
    () async {
      await db.tasksDao.upsertFromServer(
        _task(id: 1, remoteId: 1, title: 'bleibt (in keepList)'),
      );
      await db.tasksDao.upsertFromServer(
        _task(id: 2, remoteId: 2, title: 'wird gelöscht (clean, fehlt)'),
      );
      await db.tasksDao.upsertLocal(
        _task(id: 3, remoteId: 3, title: 'bleibt (dirty, fehlt)'),
      );

      await db.tasksDao.deleteMissingClean([1]);

      expect(await db.tasksDao.getById(1), isNotNull);
      expect(await db.tasksDao.getById(2), isNull);
      final dirtyRow = await db.tasksDao.getById(3);
      expect(dirtyRow, isNotNull);
      expect(dirtyRow!.isDirty, isTrue);
    },
  );

  test(
    'deleteMissingClean lässt rein lokale Datensätze ohne remoteId unangetastet',
    () async {
      await db.tasksDao.upsertLocal(_task(id: -1, title: 'offline erzeugt'));

      await db.tasksDao.deleteMissingClean([999]);

      expect(await db.tasksDao.getById(-1), isNotNull);
    },
  );

  test('negative lokale IDs (offline erzeugt) können eingefügt werden', () async {
    await db.tasksDao.upsertLocal(_task(id: -42, title: 'Offline-Task'));

    final row = await db.tasksDao.getById(-42);
    expect(row, isNotNull);
    expect(row!.id, -42);
    expect(row.isDirty, isTrue);
    expect(row.remoteId, isNull);
  });

  test('watchTasksByProject filtert nach projectId', () async {
    await db.tasksDao.upsertFromServer(
      _task(id: 1, remoteId: 1, projectId: 10),
    );
    await db.tasksDao.upsertFromServer(
      _task(id: 2, remoteId: 2, projectId: 20),
    );

    final result = await db.tasksDao.watchTasksByProject(10).first;
    expect(result.length, 1);
    expect(result.first.id, 1);
  });
}
