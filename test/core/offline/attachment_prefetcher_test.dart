import 'dart:convert';
import 'dart:io';


import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vikunja_app/core/offline/attachment_prefetcher.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/data/data_sources/task_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';

/// Minimaler TaskDataSource-Fake: liefert Auth-Header + Anhang-URL. Downloads
/// laufen über den in den Prefetcher injizierten http.Client (MockClient).
class _FakeTaskDataSource implements TaskDataSource {
  @override
  Future<Map<String, String>> authHeaders() async => {'Authorization': 't'};

  @override
  String attachmentUrl(int taskId, int attachmentId, {String? previewSize}) =>
      'https://x/tasks/$taskId/attachments/$attachmentId';

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

final _t = DateTime.utc(2026, 1, 1);

Map<String, dynamic> _attachmentJson(int id, String name, int size) => {
  'id': id,
  'task_id': 7,
  'created': _t.toIso8601String(),
  'created_by': {
    'id': 1,
    'username': 'u1',
    'created': _t.toIso8601String(),
    'updated': _t.toIso8601String(),
  },
  'file': {
    'id': id,
    'created': _t.toIso8601String(),
    'mime': 'image/png',
    'name': name,
    'size': size,
  },
};

void main() {
  late AppDatabase db;
  late Directory supportDir;
  late LocalFileStorage storage;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    supportDir = await Directory.systemTemp.createTemp('prefetch_test');
    storage = LocalFileStorage(supportDirectory: () async => supportDir);
  });

  tearDown(() async {
    await db.close();
    if (await supportDir.exists()) await supportDir.delete(recursive: true);
  });

  /// Fügt einen synchronisierten Task (remoteId gesetzt) mit den Anhängen im
  /// rawJson ein.
  Future<void> insertSyncedTask(int id, List<Map<String, dynamic>> attachments) {
    return db.into(db.tasks).insert(
      TasksCompanion.insert(
        id: Value(id),
        projectId: 1,
        title: 'T$id',
        createdAt: _t.toIso8601String(),
        updatedAt: _t.toIso8601String(),
        rawJson: jsonEncode({'id': id, 'attachments': attachments}),
        remoteId: Value(id),
      ),
    );
  }

  final bytes = Uint8List.fromList(List<int>.generate(16, (i) => i));

  AttachmentPrefetcher prefetcher(
    http.Client client, {
    int maxFileBytes = 15 * 1024 * 1024,
  }) => AttachmentPrefetcher(
    db: db,
    taskDataSource: _FakeTaskDataSource(),
    storage: storage,
    client: client,
    maxFileBytes: maxFileBytes,
  );

  Future<TaskAttachmentRow?> attachmentRow(int remoteId) => (db.select(
    db.taskAttachments,
  )..where((a) => a.remoteId.equals(remoteId))).getSingleOrNull();

  test('lädt fehlende Datei ≤ Limit, setzt localFilePath', () async {
    await insertSyncedTask(7, [_attachmentJson(99, 'pic.png', 3)]);
    var hits = 0;
    final client = MockClient((_) async {
      hits++;
      return http.Response.bytes(bytes, 200);
    });

    await prefetcher(client).run();

    final row = await attachmentRow(99);
    expect(row, isNotNull);
    expect(row!.localFilePath, isNotNull);
    expect(await File(row.localFilePath!).exists(), isTrue);
    expect(await File(row.localFilePath!).readAsBytes(), bytes);
    expect(hits, 1);
  });

  test('läuft nicht erneut, wenn Datei bereits vorliegt', () async {
    await insertSyncedTask(7, [_attachmentJson(99, 'pic.png', 3)]);
    var hits = 0;
    final client = MockClient((_) async {
      hits++;
      return http.Response.bytes(bytes, 200);
    });

    await prefetcher(client).run();
    await prefetcher(client).run();

    expect(hits, 1); // zweiter Lauf lädt nicht neu
  });

  test('überspringt zu große Dateien (> Limit)', () async {
    await insertSyncedTask(7, [_attachmentJson(99, 'big.bin', 20 * 1024 * 1024)]);
    var hits = 0;
    final client = MockClient((_) async {
      hits++;
      return http.Response.bytes(bytes, 200);
    });

    await prefetcher(client).run();

    expect(hits, 0);
    final row = await attachmentRow(99);
    expect(row, isNotNull); // Zeile gespiegelt
    expect(row!.localFilePath, isNull); // aber nicht geladen
  });

  test('still bei Netzfehler: kein Throw, localFilePath bleibt null', () async {
    await insertSyncedTask(7, [_attachmentJson(99, 'pic.png', 3)]);
    final client = MockClient((_) async => throw http.ClientException('offline'));

    await prefetcher(client).run(); // wirft nicht

    final row = await attachmentRow(99);
    expect(row!.localFilePath, isNull);
  });

  test('räumt verwaiste Dateien ohne DB-Zeile auf', () async {
    final dir = await storage.attachmentsDir();
    await dir.create(recursive: true);
    final orphan = File('${dir.path}/999_orphan.png');
    await orphan.writeAsBytes(bytes);
    // Keine Tasks/Anhänge → die Datei ist verwaist.

    final client = MockClient((_) async => http.Response.bytes(bytes, 200));
    await prefetcher(client).run();

    expect(await orphan.exists(), isFalse);
  });

  test('verschwundener Anhang: Zeile + Datei werden entfernt', () async {
    await insertSyncedTask(7, [_attachmentJson(99, 'pic.png', 3)]);
    final client = MockClient((_) async => http.Response.bytes(bytes, 200));
    await prefetcher(client).run();
    final downloaded = (await attachmentRow(99))!.localFilePath!;
    expect(await File(downloaded).exists(), isTrue);

    // Anhang serverseitig verschwunden → rawJson ohne Anhänge.
    await (db.update(db.tasks)..where((t) => t.id.equals(7))).write(
      TasksCompanion(rawJson: Value(jsonEncode({'id': 7, 'attachments': []}))),
    );
    await prefetcher(client).run();

    expect(await attachmentRow(99), isNull);
    expect(await File(downloaded).exists(), isFalse);
  });
}
