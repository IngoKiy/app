import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:vikunja_app/core/offline/local_file_storage.dart';
import 'package:vikunja_app/data/local/dao/image_cache_dao.dart';
import 'package:vikunja_app/data/local/database.dart';

/// Wird geworfen, wenn ein Bild weder geladen noch aus dem Cache bedient werden
/// kann (offline und kein Cache-Treffer). Der `errorBuilder` der jeweiligen
/// `Image`-Widgets greift dann wie bisher.
class ImageCacheMiss implements Exception {
  ImageCacheMiss(this.url);
  final String url;
  @override
  String toString() => 'ImageCacheMiss($url)';
}

/// Platten-Cache für authentifizierte Bilder (Avatare, Anhang-Vorschauen).
///
/// [load] versucht zuerst das Netzwerk (mit den übergebenen Auth-Headern),
/// schreibt Erfolge unter `<ApplicationSupport>/image_cache/<sha1(url)>` und
/// pflegt einen Registry-Eintrag. Bei Netzwerkfehler oder Nicht-2xx-Antwort
/// wird die zuvor gecachte Datei zurückgegeben; fehlt sie, wird
/// [ImageCacheMiss] geworfen.
class ImageDiskCache {
  ImageDiskCache({
    required ImageCacheDao dao,
    required LocalFileStorage storage,
    http.Client? client,
    this.maxAge = const Duration(days: 60),
    this.maxTotalBytes = 200 * 1024 * 1024,
  }) : _dao = dao,
       _storage = storage,
       _client = client ?? http.Client();

  final ImageCacheDao _dao;
  final LocalFileStorage _storage;
  final http.Client _client;
  final Duration maxAge;
  final int maxTotalBytes;

  static String hashUrl(String url) =>
      sha1.convert(utf8.encode(url)).toString();

  Future<Uint8List> load(String url, Map<String, String> headers) async {
    final hash = hashUrl(url);
    final dir = await _storage.imageCacheDir();
    final file = File('${dir.path}/$hash');

    try {
      final resp = await _client.get(Uri.parse(url), headers: headers);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await _write(dir, file, hash, resp.bodyBytes);
        return resp.bodyBytes;
      }
      // Nicht-2xx (z. B. 404): unten auf den Cache zurückfallen.
    } catch (_) {
      // Netzwerkfehler (offline): unten auf den Cache zurückfallen.
    }
    return _fromCache(url, file, hash);
  }

  /// Wie [load], meldet aber zusätzlich den Download-Fortschritt (für
  /// `ImageChunkEvent`): [onProgress] erhält die kumulativ geladenen sowie die
  /// erwarteten Bytes (`null`, wenn der Server keine content-length liefert).
  /// Bei Netzfehler/Nicht-2xx fällt sie still auf den Platten-Cache zurück.
  Future<Uint8List> loadWithProgress(
    String url,
    Map<String, String> headers, {
    required void Function(int cumulative, int? total) onProgress,
  }) async {
    final hash = hashUrl(url);
    final dir = await _storage.imageCacheDir();
    final file = File('${dir.path}/$hash');

    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers.addAll(headers);
      final resp = await _client.send(request);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final total = resp.contentLength;
        final builder = BytesBuilder(copy: false);
        var received = 0;
        await for (final chunk in resp.stream) {
          builder.add(chunk);
          received += chunk.length;
          onProgress(received, total);
        }
        final bytes = builder.toBytes();
        await _write(dir, file, hash, bytes);
        return bytes;
      }
    } catch (_) {
      // Netzwerkfehler (offline): unten auf den Cache zurückfallen.
    }
    return _fromCache(url, file, hash);
  }

  Future<void> _write(
    Directory dir,
    File file,
    String hash,
    Uint8List bytes,
  ) async {
    await dir.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    await _dao.put(
      ImageCachesCompanion.insert(
        urlHash: hash,
        filePath: file.path,
        fetchedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<Uint8List> _fromCache(String url, File file, String hash) async {
    if (await file.exists()) return file.readAsBytes();
    final row = await _dao.getByHash(hash);
    if (row != null) {
      final cached = File(row.filePath);
      if (await cached.exists()) return cached.readAsBytes();
    }
    throw ImageCacheMiss(url);
  }

  /// Räumt den Cache auf: Einträge älter als [maxAge] werden gelöscht, danach
  /// die ältesten, bis die Gesamtgröße wieder ≤ [maxTotalBytes] liegt.
  Future<void> evict() async {
    final rows = await _dao.getAllOldestFirst();
    final now = DateTime.now().toUtc();

    final survivors = <_Entry>[];
    for (final row in rows) {
      final file = File(row.filePath);
      final fetched = DateTime.tryParse(row.fetchedAt);
      if (fetched != null && now.difference(fetched) > maxAge) {
        await _remove(row.urlHash, file);
        continue;
      }
      final size = await file.exists() ? await file.length() : 0;
      survivors.add(_Entry(row.urlHash, file, size));
    }

    var total = survivors.fold<int>(0, (sum, e) => sum + e.size);
    // survivors ist bereits älteste-zuerst (getAllOldestFirst).
    for (final entry in survivors) {
      if (total <= maxTotalBytes) break;
      await _remove(entry.hash, entry.file);
      total -= entry.size;
    }
  }

  Future<void> _remove(String hash, File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    await _dao.remove(hash);
  }
}

class _Entry {
  _Entry(this.hash, this.file, this.size);
  final String hash;
  final File file;
  final int size;
}
