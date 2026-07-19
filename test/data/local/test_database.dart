import 'package:drift/native.dart';
import 'package:vikunja_app/data/local/database.dart';

/// Erzeugt eine frische In-Memory-Datenbank für Tests (keine Datei, kein
/// Test-übergreifender Zustand).
AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());
