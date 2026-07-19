import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
import 'package:vikunja_app/data/local/database.dart';

/// KeyValue-Schlüssel des fortlaufenden Temp-ID-Zählers.
const String kvTempIdCounter = 'temp_id_counter';

/// Vergibt persistente, negative IDs für offline erzeugte Entitäten.
///
/// Der Zähler lebt im KeyValue-Store (`temp_id_counter`), startet bei -1 und
/// dekrementiert. Die Vergabe läuft in einer DB-Transaktion, damit parallele
/// Aufrufe keine ID doppelt vergeben (Read-Modify-Write ist atomar).
class TempIdAllocator {
  TempIdAllocator({required AppDatabase db, required KeyValueDao keyValueDao})
    : _db = db,
      _keyValueDao = keyValueDao;

  final AppDatabase _db;
  final KeyValueDao _keyValueDao;

  /// Nächste freie Temp-ID (-1, -2, -3, …).
  Future<int> next() {
    return _db.transaction(() async {
      final raw = await _keyValueDao.get(kvTempIdCounter);
      final current = raw == null ? 0 : int.parse(raw);
      final next = current - 1;
      await _keyValueDao.set(kvTempIdCounter, '$next');
      return next;
    });
  }
}
