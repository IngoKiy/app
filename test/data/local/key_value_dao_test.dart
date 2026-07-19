import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/data/local/database.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('KeyValue-Roundtrip: set/get', () async {
    await db.keyValueDao.set('lastSync', '2026-07-19T12:00:00.000Z');

    final value = await db.keyValueDao.get('lastSync');
    expect(value, '2026-07-19T12:00:00.000Z');
  });

  test('get liefert null für unbekannten key', () async {
    expect(await db.keyValueDao.get('unknown'), isNull);
  });

  test('set überschreibt einen bestehenden Wert', () async {
    await db.keyValueDao.set('flag', 'a');
    await db.keyValueDao.set('flag', 'b');

    expect(await db.keyValueDao.get('flag'), 'b');
  });

  test('watch liefert den aktuellen Wert reaktiv nach Änderungen', () async {
    expect(await db.keyValueDao.watch('counter').first, isNull);

    await db.keyValueDao.set('counter', '1');
    expect(await db.keyValueDao.watch('counter').first, '1');

    await db.keyValueDao.set('counter', '2');
    expect(await db.keyValueDao.watch('counter').first, '2');
  });

  test('remove löscht den Eintrag', () async {
    await db.keyValueDao.set('temp', 'x');
    await db.keyValueDao.remove('temp');

    expect(await db.keyValueDao.get('temp'), isNull);
  });
}
