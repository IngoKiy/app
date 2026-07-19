import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:vikunja_app/data/local/dao/buckets_dao.dart';
import 'package:vikunja_app/data/local/dao/image_cache_dao.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';
import 'package:vikunja_app/data/local/dao/labels_dao.dart';
import 'package:vikunja_app/data/local/dao/pending_ops_dao.dart';
import 'package:vikunja_app/data/local/dao/projects_dao.dart';
import 'package:vikunja_app/data/local/dao/task_assignees_dao.dart';
import 'package:vikunja_app/data/local/dao/task_attachments_dao.dart';
import 'package:vikunja_app/data/local/dao/task_comments_dao.dart';
import 'package:vikunja_app/data/local/dao/task_labels_dao.dart';
import 'package:vikunja_app/data/local/dao/tasks_dao.dart';
import 'package:vikunja_app/data/local/dao/users_dao.dart';
import 'package:vikunja_app/data/local/tables/buckets_table.dart';
import 'package:vikunja_app/data/local/tables/image_cache_table.dart';
import 'package:vikunja_app/data/local/tables/key_value_table.dart';
import 'package:vikunja_app/data/local/tables/labels_table.dart';
import 'package:vikunja_app/data/local/tables/pending_ops_table.dart';
import 'package:vikunja_app/data/local/tables/projects_table.dart';
import 'package:vikunja_app/data/local/tables/task_assignees_table.dart';
import 'package:vikunja_app/data/local/tables/task_attachments_table.dart';
import 'package:vikunja_app/data/local/tables/task_comments_table.dart';
import 'package:vikunja_app/data/local/tables/task_labels_table.dart';
import 'package:vikunja_app/data/local/tables/tasks_table.dart';
import 'package:vikunja_app/data/local/tables/users_table.dart';

part 'database.g.dart';

/// Lokale SQLite-Datenbank (Drift) — Wahrheitsquelle der UI im Local-First-
/// Ansatz. Siehe docs/offline.md für die Gesamtarchitektur.
@DriftDatabase(
  tables: [
    Projects,
    Tasks,
    Labels,
    Users,
    Buckets,
    TaskLabels,
    TaskAssignees,
    TaskComments,
    TaskAttachments,
    KeyValues,
    PendingOps,
    ImageCaches,
  ],
  daos: [
    ProjectsDao,
    TasksDao,
    LabelsDao,
    UsersDao,
    BucketsDao,
    TaskLabelsDao,
    TaskAssigneesDao,
    TaskCommentsDao,
    TaskAttachmentsDao,
    KeyValueDao,
    PendingOpsDao,
    ImageCacheDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Konstruktor für Tests: beliebiger [QueryExecutor], z.B.
  /// `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// Löscht sämtliche lokalen Daten (Logout / Kontowechsel). Läuft in einer
  /// Transaktion, damit die DB nie halb geleert zurückbleibt.
  Future<void> wipeAll() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'boos_agenda');
  }
}
