import 'package:drift/drift.dart';

/// Generischer Key-Value-Speicher für Sync-Metadaten (z.B. Zeitpunkt des
/// letzten Full-Sync, Cursor, Flags).
@DataClassName('KeyValueRow')
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
