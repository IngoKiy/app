import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/offline_provider.dart';
import 'package:vikunja_app/core/network/cached_image_provider.dart';
import 'package:vikunja_app/domain/entities/user.dart';

/// Rundes Nutzer-Avatar-Bild vom Vikunja-Server mit Initialen-Fallback.
class UserAvatar extends ConsumerWidget {
  final User user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 14});

  String get _initials {
    final source = user.name.isNotEmpty ? user.name : user.username;
    final parts = source
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.read(clientProviderProvider);
    final cache = ref.watch(imageDiskCacheProvider);

    return FutureBuilder<Map<String, String>>(
      future: client.getHeaders(),
      builder: (context, snapshot) {
        return CircleAvatar(
          radius: radius,
          foregroundImage: snapshot.hasData && user.username.isNotEmpty
              ? AuthCachedImageProvider(
                  user.avatarUrl(client.apiBase),
                  headers: snapshot.data!,
                  cache: cache,
                )
              : null,
          child: Text(_initials, style: TextStyle(fontSize: radius * 0.8)),
        );
      },
    );
  }
}
