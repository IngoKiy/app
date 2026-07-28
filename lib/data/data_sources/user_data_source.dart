import 'dart:async';

import 'package:vikunja_app/core/network/remote_data_source.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

class UserDataSource extends RemoteDataSource {
  UserDataSource(super.client);

  Future<Response<UserDto>> getCurrentUser() {
    return client.get(
      url: '/user',
      mapper: (body) {
        return UserDto.fromJson(body);
      },
    );
  }

  /// Avatar-Bild hochladen (Vikunja: PUT /user/settings/avatar/upload,
  /// Multipart-Feld `avatar`). Setzt serverseitig zugleich den Provider auf
  /// „upload", damit Web und alle Geräte dasselbe Bild zeigen.
  Future<Response<Object>> uploadAvatar(String filePath) {
    return client.uploadFiles(
      url: '/user/settings/avatar/upload',
      filePaths: [filePath],
      fieldName: 'avatar',
    );
  }

  /// Avatar-Quelle setzen: `initials`, `gravatar`, `marble`, `upload`, `default`.
  Future<Response<Object>> setAvatarProvider(String provider) {
    return client.post(
      url: '/user/settings/avatar',
      body: {'avatar_provider': provider},
    );
  }

  Future<Response<UserSettingsDto>> setCurrentUserSettings(
    UserSettingsDto userSettings,
  ) async {
    return client.post(
      url: '/user/settings/general',
      mapper: (body) {
        return userSettings;
      },
      body: userSettings.toJson(),
    );
  }
}
