import 'dart:io';

import 'package:background_downloader/background_downloader.dart' hide Task;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/domain/entities/task.dart';
import 'package:vikunja_app/domain/entities/task_attachment.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/repositories/task_repository.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/task_attachments_section.dart';

import '../../core/offline/offline_test_fakes.dart';

/// Fake-Repository, das Netz-Downloads mitzählt und Auth-Header liefert.
class _FakeTaskRepository implements TaskRepository {
  int downloadCalls = 0;

  @override
  Future<Map<String, String>> attachmentHeaders() async => const {};

  @override
  String attachmentUrl(int taskId, int attachmentId, {String? previewSize}) =>
      'https://x/tasks/$taskId/attachments/$attachmentId';

  @override
  Future<TaskStatusUpdate> downloadAttachment(
    int taskId,
    TaskAttachment attachment, {
    void Function(double)? onProgress,
  }) async {
    downloadCalls++;
    throw StateError('darf offline nicht aufgerufen werden');
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;
  late _FakeTaskRepository repo;

  // background_downloader-Kanal stubben, damit openFile im Test nicht wirft.
  const channel = MethodChannel('com.bbflight.background_downloader');
  final openedFiles = <String?>[];

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('section_test');
    repo = _FakeTaskRepository();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'openFile') {
            openedFiles.add((call.arguments as Map)['filePath'] as String?);
            return true;
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
    openedFiles.clear();
  });

  testWidgets('localFilePath vorhanden → Öffnen ohne Netzaufruf', (
    tester,
  ) async {
    // Lokale Datei + DB-Zeile (remoteId 99) mit localFilePath.
    // Echtes Datei-I/O braucht runAsync (FakeAsync lässt IO-Futures sonst hängen).
    final localFile = File('${tempDir.path}/doc.pdf');
    await tester.runAsync(() => localFile.writeAsBytes([1, 2, 3]));
    await db.into(db.taskAttachments).insert(
      TaskAttachmentsCompanion.insert(
        id: const Value(99),
        taskId: 7,
        fileJson: '{}',
        rawJson: '{}',
        remoteId: const Value(99),
        localFilePath: Value(localFile.path),
      ),
    );

    final writer = buildWriter(db, buildExecutor(db));
    final task = Task(
      id: 7,
      projectId: 1,
      createdBy: User(username: 'u'),
      attachments: [
        TaskAttachment(
          id: 99,
          taskId: 7,
          createdBy: User(username: 'u'),
          file: TaskAttachmentFile(
            id: 99,
            created: DateTime(2026),
            mime: 'application/pdf',
            name: 'doc.pdf',
            size: 3,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => repo),
          offlineWriterProvider.overrideWith((ref) => writer),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskAttachmentsSection(
              task: task,
              editable: false,
              openLocalFile: (path) async => openedFiles.add(path),
            ),
          ),
        ),
      ),
    );
    // Auth-Header + lokale Pfade laden lassen (kein pumpAndSettle: der
    // background_downloader hält Timer, die nie „settlen").
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.download));
    // Der Tap-Handler prüft File.exists() (echtes IO) → reales Async-Fenster.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump();

    expect(repo.downloadCalls, 0); // kein Netzaufruf
    expect(openedFiles, [localFile.path]); // lokale Datei geöffnet
  });
}
