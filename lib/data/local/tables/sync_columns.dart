import 'package:drift/drift.dart';

/// Gemeinsame Spalten für alle Tabellen, deren Datensätze mit dem Vikunja-
/// Server synchronisiert werden (Pull/Push-Sync, siehe docs/offline.md).
///
/// - [remoteId]: Server-ID; `null` solange der Datensatz nur lokal existiert.
/// - [isDirty]: `true`, solange eine lokale Änderung noch nicht gepusht wurde.
///   Der Pull-Sync darf dirty Datensätze nicht überschreiben.
/// - [isDeleted]: Tombstone für lokal markierte Löschungen, die noch auf den
///   Push warten.
/// - [syncedAt]: Zeitpunkt des letzten erfolgreichen Abgleichs mit dem Server.
mixin SyncColumns on Table {
  IntColumn get remoteId => integer().nullable().unique()();
  TextColumn get updatedAtServer => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncedAt => text().nullable()();
}
