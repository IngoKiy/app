import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Zentralisiert die auf der Platte liegenden Local-First-Verzeichnisse
/// (Bild-Cache, offline zwischengespeicherte Anhang-Uploads) unterhalb von
/// `ApplicationSupport`. Kapselt die Verzeichnisnamen, damit weder die UI
/// (Logout) noch Cache/Writer den Pfadaufbau kennen müssen.
class LocalFileStorage {
  LocalFileStorage({Future<Directory> Function()? supportDirectory})
    : _supportDirectory =
          supportDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDirectory;

  /// Unterverzeichnis für gecachte Bilder (Avatare, Anhang-Vorschauen).
  static const String imageCacheDirName = 'image_cache';

  /// Unterverzeichnis für offline kopierte Anhang-Uploads (pro Op ein Ordner).
  static const String pendingUploadsDirName = 'pending_uploads';

  Future<Directory> imageCacheDir() => _subdir(imageCacheDirName);

  /// Ordner eines einzelnen offline Uploads (Schlüssel = eindeutige Op-/Temp-ID).
  Future<Directory> pendingUploadDir(String key) =>
      _subdir('$pendingUploadsDirName/$key');

  Future<Directory> _subdir(String name) async {
    final base = await _supportDirectory();
    return Directory('${base.path}/$name');
  }

  /// Löscht Bild-Cache- und pending-uploads-Verzeichnisse physisch (Logout /
  /// Kontowechsel). Fehler werden geschluckt — Logout darf daran nicht scheitern.
  Future<void> wipeAll() async {
    await _deleteDirQuietly(imageCacheDirName);
    await _deleteDirQuietly(pendingUploadsDirName);
  }

  Future<void> _deleteDirQuietly(String name) async {
    try {
      final dir = await _subdir(name);
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  /// Löscht eine Datei (und den nun leeren Elternordner) ohne zu werfen.
  Future<void> deleteFileQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
      final parent = file.parent;
      if (await parent.exists() && await parent.list().isEmpty) {
        await parent.delete();
      }
    } catch (_) {}
  }
}
