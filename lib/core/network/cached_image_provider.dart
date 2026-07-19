import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:vikunja_app/core/network/image_disk_cache.dart';

/// [ImageProvider], das Bilder mit Auth-Headern über den [ImageDiskCache] lädt
/// und dabei transparent den Platten-Cache nutzt (online schreibt, offline
/// liest). Bei einem Cache-Miss wirft der Completer und der `errorBuilder` des
/// umgebenden `Image`-Widgets greift.
///
/// Gleichheit hängt bewusst nur an [url] (nicht an den Headern), damit Flutters
/// interner Image-Cache greift und wechselnde Header-Map-Instanzen kein
/// Neuladen auslösen.
@immutable
class AuthCachedImageProvider extends ImageProvider<AuthCachedImageProvider> {
  const AuthCachedImageProvider(
    this.url, {
    required this.headers,
    required this.cache,
    this.scale = 1.0,
  });

  final String url;
  final Map<String, String> headers;
  final ImageDiskCache cache;
  final double scale;

  @override
  Future<AuthCachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AuthCachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    AuthCachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    // Chunk-Events aus dem Download durchreichen, damit Image.loadingBuilder
    // echten Fortschritt anzeigen kann.
    final chunkEvents = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _loadAsync(
    AuthCachedImageProvider key,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    try {
      final bytes = await cache.loadWithProgress(
        url,
        headers,
        onProgress: (cumulative, total) {
          if (!chunkEvents.isClosed) {
            chunkEvents.add(
              ImageChunkEvent(
                cumulativeBytesLoaded: cumulative,
                expectedTotalBytes: total,
              ),
            );
          }
        },
      );
      if (bytes.isEmpty) throw ImageCacheMiss(url);
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await decode(buffer);
    } finally {
      unawaited(chunkEvents.close());
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AuthCachedImageProvider &&
      other.url == url &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => 'AuthCachedImageProvider("$url", scale: $scale)';
}
