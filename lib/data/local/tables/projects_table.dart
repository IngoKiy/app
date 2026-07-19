import 'package:drift/drift.dart';
import 'package:vikunja_app/data/local/tables/sync_columns.dart';

/// Lokale Projekte. `id` ist bewusst KEIN autoIncrement, damit offline
/// erzeugte Projekte negative IDs bekommen können (Vergabe: Outbox-Layer, M2).
@DataClassName('ProjectRow')
class Projects extends Table with SyncColumns {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get parentProjectId => integer().nullable()();
  RealColumn get position => real().withDefault(const Constant(0))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  TextColumn get hexColor => text().nullable()();

  /// JSON-Array der ProjectView-DTOs.
  TextColumn get viewsJson => text().withDefault(const Constant('[]'))();
  TextColumn get ownerJson => text().nullable()();

  /// Komplettes ProjectDto-JSON als Fallback für Felder ohne eigene Spalte.
  TextColumn get rawJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
