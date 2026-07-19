import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';

import 'test_database.dart';

ProjectsCompanion _project({
  required int id,
  int? remoteId,
  String title = 'Projekt',
  bool isDirty = false,
}) => ProjectsCompanion.insert(
  id: Value(id),
  title: title,
  rawJson: '{}',
  remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
  isDirty: Value(isDirty),
);

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('upsertFromServer + watchProjects liefert das Projekt', () async {
    await db.projectsDao.upsertFromServer(
      _project(id: 1, remoteId: 1, title: 'Vom Server'),
    );

    final all = await db.projectsDao.watchProjects().first;
    expect(all, hasLength(1));
    expect(all.first.title, 'Vom Server');
  });

  test('upsertFromServer überschreibt dirty Projekte nicht', () async {
    await db.projectsDao.upsertLocal(
      _project(id: 1, remoteId: 7, title: 'Lokal'),
    );
    await db.projectsDao.upsertFromServer(
      _project(id: 1, remoteId: 7, title: 'Server'),
    );

    final row = await db.projectsDao.getById(1);
    expect(row!.title, 'Lokal');
  });

  test('deleteMissingClean entfernt nur nicht-dirty, fehlende Projekte', () async {
    await db.projectsDao.upsertFromServer(_project(id: 1, remoteId: 1));
    await db.projectsDao.upsertLocal(_project(id: 2, remoteId: 2));

    await db.projectsDao.deleteMissingClean([]);

    expect(await db.projectsDao.getById(1), isNull);
    expect(await db.projectsDao.getById(2), isNotNull);
  });
}
