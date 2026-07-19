import 'package:drift/drift.dart';

/// Lokaler Cache für heruntergeladene Bilder (z.B. Avatare, Anhänge).
@DataClassName('ImageCacheRow')
class ImageCaches extends Table {
  TextColumn get urlHash => text()();
  TextColumn get filePath => text()();
  TextColumn get fetchedAt => text()();

  @override
  Set<Column> get primaryKey => {urlHash};
}
