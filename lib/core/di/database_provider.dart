import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
import 'package:vikunja_app/data/local/database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ProjectsDao projectsDao(Ref ref) => ref.watch(appDatabaseProvider).projectsDao;

@Riverpod(keepAlive: true)
TasksDao tasksDao(Ref ref) => ref.watch(appDatabaseProvider).tasksDao;

@Riverpod(keepAlive: true)
LabelsDao labelsDao(Ref ref) => ref.watch(appDatabaseProvider).labelsDao;

@Riverpod(keepAlive: true)
UsersDao usersDao(Ref ref) => ref.watch(appDatabaseProvider).usersDao;

@Riverpod(keepAlive: true)
BucketsDao bucketsDao(Ref ref) => ref.watch(appDatabaseProvider).bucketsDao;

@Riverpod(keepAlive: true)
TaskLabelsDao taskLabelsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).taskLabelsDao;

@Riverpod(keepAlive: true)
TaskAssigneesDao taskAssigneesDao(Ref ref) =>
    ref.watch(appDatabaseProvider).taskAssigneesDao;

@Riverpod(keepAlive: true)
TaskCommentsDao taskCommentsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).taskCommentsDao;

@Riverpod(keepAlive: true)
TaskAttachmentsDao taskAttachmentsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).taskAttachmentsDao;

@Riverpod(keepAlive: true)
KeyValueDao keyValueDao(Ref ref) => ref.watch(appDatabaseProvider).keyValueDao;

@Riverpod(keepAlive: true)
PendingOpsDao pendingOpsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).pendingOpsDao;

@Riverpod(keepAlive: true)
ImageCacheDao imageCacheDao(Ref ref) =>
    ref.watch(appDatabaseProvider).imageCacheDao;
