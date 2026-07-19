import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';

import 'test_database.dart';

BucketsCompanion _bucket({
  required int id,
  int? remoteId,
  int projectId = 10,
  String title = 'Bucket',
  bool isDirty = false,
}) => BucketsCompanion.insert(
  id: Value(id),
  projectId: projectId,
  title: title,
  rawJson: '{}',
  remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
  isDirty: Value(isDirty),
);

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('upsertFromServer + watchBucketsByProject liefert den Bucket', () async {
    await db.bucketsDao.upsertFromServer(
      _bucket(id: 1, remoteId: 1, title: 'Todo'),
    );

    final rows = await db.bucketsDao.watchBucketsByProject(10).first;
    expect(rows, hasLength(1));
    expect(rows.first.title, 'Todo');
  });

  test(
    'deleteMissingCleanForProject beschränkt sich auf den Projekt-Scope',
    () async {
      await db.bucketsDao.upsertFromServer(
        _bucket(id: 1, remoteId: 1, projectId: 10),
      );
      await db.bucketsDao.upsertFromServer(
        _bucket(id: 2, remoteId: 2, projectId: 10),
      );
      await db.bucketsDao.upsertLocal(
        _bucket(id: 3, remoteId: 3, projectId: 10),
      );
      await db.bucketsDao.upsertFromServer(
        _bucket(id: 4, remoteId: 4, projectId: 20),
      );

      final deleted = await db.bucketsDao.deleteMissingCleanForProject(10, [1]);

      expect(deleted, 1);
      expect(await db.bucketsDao.getById(1), isNotNull);
      expect(await db.bucketsDao.getById(2), isNull);
      expect(await db.bucketsDao.getById(3), isNotNull); // dirty bleibt
      expect(await db.bucketsDao.getById(4), isNotNull); // anderes Projekt
    },
  );
}
