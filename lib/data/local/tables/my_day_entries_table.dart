import 'package:drift/drift.dart';

/// Manuell zu „Mein Tag" hinzugefügte Aufgaben (MS-To-Do-Hybrid): [day] ist
/// der lokale Kalendertag (yyyy-MM-dd), für den der Eintrag gilt — alte Tage
/// verfallen dadurch automatisch um Mitternacht. Rein lokal, kein Server-Sync
/// (Vikunja kennt kein Mein-Tag-Konzept).
@DataClassName('MyDayEntryRow')
class MyDayEntries extends Table {
  IntColumn get taskId => integer()();
  TextColumn get day => text()();

  @override
  Set<Column> get primaryKey => {taskId, day};
}
