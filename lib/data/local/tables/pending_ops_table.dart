import 'package:drift/drift.dart';

/// Outbox für den Push-Sync (wird ab M2 befüllt). FIFO nach [opId];
/// Abhängigkeitssortierung/Temp-ID-Mapping übernimmt der Outbox-Layer.
@DataClassName('PendingOpRow')
class PendingOps extends Table {
  IntColumn get opId => integer().autoIncrement()();
  TextColumn get entityType => text()();
  IntColumn get localId => integer()();
  TextColumn get opType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get localFilePathsJson => text().nullable()();
  TextColumn get createdAt => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}
