import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vikunja_app/core/network/cached_image_provider.dart';
import 'package:vikunja_app/core/network/image_disk_cache.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/data/local/database.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late LocalFileStorage storage;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('img_cache_test');
    storage = LocalFileStorage(supportDirectory: () async => tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));

  ImageDiskCache cacheWith(http.Client client, {int maxTotalBytes = 1 << 30}) =>
      ImageDiskCache(
        dao: db.imageCacheDao,
        storage: storage,
        client: client,
        maxTotalBytes: maxTotalBytes,
      );

  test('online: schreibt Datei + Registry-Eintrag und liefert Bytes', () async {
    final client = MockClient((_) async => http.Response.bytes(bytes, 200));
    final cache = cacheWith(client);

    final result = await cache.load('https://x/img', const {});

    expect(result, bytes);
    final hash = ImageDiskCache.hashUrl('https://x/img');
    final row = await db.imageCacheDao.getByHash(hash);
    expect(row, isNotNull);
    expect(await File(row!.filePath).exists(), isTrue);
  });

  test('offline: liest zuvor gecachte Datei bei Netzwerkfehler', () async {
    final online = MockClient((_) async => http.Response.bytes(bytes, 200));
    await cacheWith(online).load('https://x/img', const {});

    final offline = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    final result = await cacheWith(offline).load('https://x/img', const {});

    expect(result, bytes);
  });

  test('offline ohne Cache-Treffer: wirft ImageCacheMiss', () async {
    final offline = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    expect(
      () => cacheWith(offline).load('https://x/none', const {}),
      throwsA(isA<ImageCacheMiss>()),
    );
  });

  test('Nicht-2xx ohne Cache: wirft ImageCacheMiss', () async {
    final client = MockClient((_) async => http.Response('nope', 404));
    expect(
      () => cacheWith(client).load('https://x/404', const {}),
      throwsA(isA<ImageCacheMiss>()),
    );
  });

  test('Eviction: löscht Einträge älter als maxAge', () async {
    final dir = await storage.imageCacheDir();
    await dir.create(recursive: true);
    final oldFile = File('${dir.path}/old');
    await oldFile.writeAsBytes(bytes);
    await db.imageCacheDao.put(
      ImageCachesCompanion.insert(
        urlHash: 'old',
        filePath: oldFile.path,
        fetchedAt: DateTime.utc(2020).toIso8601String(),
      ),
    );

    final cache = ImageDiskCache(
      dao: db.imageCacheDao,
      storage: storage,
      client: MockClient((_) async => http.Response('', 200)),
      maxAge: const Duration(days: 60),
    );
    await cache.evict();

    expect(await db.imageCacheDao.getByHash('old'), isNull);
    expect(await oldFile.exists(), isFalse);
  });

  test('Eviction: löscht älteste zuerst bis unter maxTotalBytes', () async {
    final dir = await storage.imageCacheDir();
    await dir.create(recursive: true);
    final now = DateTime.now().toUtc();
    // 3 Dateien à 64 Bytes; Limit 128 → ältester (a) muss fallen.
    for (final entry in [('a', 0), ('b', 1), ('c', 2)]) {
      final f = File('${dir.path}/${entry.$1}');
      await f.writeAsBytes(bytes);
      await db.imageCacheDao.put(
        ImageCachesCompanion.insert(
          urlHash: entry.$1,
          filePath: f.path,
          fetchedAt: now
              .add(Duration(minutes: entry.$2))
              .toIso8601String(),
        ),
      );
    }

    final cache = cacheWith(
      MockClient((_) async => http.Response('', 200)),
      maxTotalBytes: 128,
    );
    await cache.evict();

    expect(await db.imageCacheDao.getByHash('a'), isNull);
    expect(await db.imageCacheDao.getByHash('b'), isNotNull);
    expect(await db.imageCacheDao.getByHash('c'), isNotNull);
  });

  test('loadWithProgress: meldet Fortschritt + schreibt Cache', () async {
    final client = MockClient((_) async => http.Response.bytes(bytes, 200));
    final cache = cacheWith(client);
    final events = <(int, int?)>[];

    final result = await cache.loadWithProgress(
      'https://x/img',
      const {},
      onProgress: (cumulative, total) => events.add((cumulative, total)),
    );

    expect(result, bytes);
    // Mindestens ein Fortschritts-Event; letzter Stand = volle Größe.
    expect(events, isNotEmpty);
    expect(events.last.$1, bytes.length);
    // Cache wurde geschrieben.
    final hash = ImageDiskCache.hashUrl('https://x/img');
    expect(await db.imageCacheDao.getByHash(hash), isNotNull);
  });

  test('loadWithProgress: fällt offline auf gecachte Datei zurück', () async {
    final online = MockClient((_) async => http.Response.bytes(bytes, 200));
    await cacheWith(online).loadWithProgress(
      'https://x/img',
      const {},
      onProgress: (_, _) {},
    );

    final offline = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    final events = <(int, int?)>[];
    final result = await cacheWith(offline).loadWithProgress(
      'https://x/img',
      const {},
      onProgress: (c, t) => events.add((c, t)),
    );

    expect(result, bytes);
    expect(events, isEmpty); // kein Netz → keine Fortschritts-Events
  });

  test('AuthCachedImageProvider: Gleichheit hängt nur an url + scale', () {
    final cache = cacheWith(MockClient((_) async => http.Response('', 200)));
    final a = AuthCachedImageProvider('u', headers: const {}, cache: cache);
    final b = AuthCachedImageProvider(
      'u',
      headers: const {'Authorization': 'x'},
      cache: cache,
    );
    final c = AuthCachedImageProvider('other', headers: const {}, cache: cache);

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });
}
