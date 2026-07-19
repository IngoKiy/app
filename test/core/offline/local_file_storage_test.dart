import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/offline/local_file_storage.dart';

void main() {
  late Directory support;
  late LocalFileStorage storage;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('lfs_test');
    storage = LocalFileStorage(supportDirectory: () async => support);
  });

  tearDown(() async {
    if (await support.exists()) await support.delete(recursive: true);
  });

  test('wipeAll löscht image_cache + pending_uploads physisch', () async {
    final img = await storage.imageCacheDir();
    await img.create(recursive: true);
    await File('${img.path}/a').writeAsBytes([1]);
    final up = await storage.pendingUploadDir('42');
    await up.create(recursive: true);
    await File('${up.path}/f').writeAsBytes([2]);

    await storage.wipeAll();

    expect(await img.exists(), isFalse);
    expect(
      await Directory('${support.path}/pending_uploads').exists(),
      isFalse,
    );
  });

  test('wipeAll ist idempotent (keine Ausnahme ohne Verzeichnisse)', () async {
    await storage.wipeAll();
    await storage.wipeAll();
  });
}
