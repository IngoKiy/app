import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/core/di/data_source_provider.dart';
import 'package:vikunja_app/core/di/network_provider.dart';
import 'package:vikunja_app/core/di/repository_provider.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/sync/connectivity_provider.dart';
import 'package:vikunja_app/core/sync/sync_service.dart';
import 'package:vikunja_app/data/data_sources/server_data_source.dart';
import 'package:vikunja_app/data/local/database.dart';
import 'package:vikunja_app/data/models/server_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';
import 'package:vikunja_app/domain/repositories/settings_repository.dart';
import 'package:vikunja_app/presentation/manager/init_controller.dart';

import 'controller_test_helpers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  String? server = 'https://example.test';
  String? token = 'token';

  @override
  Future<String?> getServer() async => server;

  @override
  Future<String?> getUserToken() async => token;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

/// Server-Info im Sync ist offline -> pullAll bricht sofort ab (kein Netz).
class _OfflineServerDataSource implements ServerDataSource {
  @override
  Future<Response<ServerDto>> getInfo() async =>
      ExceptionResponse(Exception('offline'), StackTrace.empty);

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

class _StubConnectivity extends ConnectivityStatus {
  @override
  bool build() => true;
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('offline mit gefüllter DB -> InitGoHome und currentUser gesetzt', () async {
    // Wie der Sync ablegt: current_user als UserDto-JSON.
    final user = UserDto(
      id: 1,
      username: 'offline-user',
      name: 'Offline',
      created: testTime,
      updated: testTime,
    );
    await db.keyValueDao.set(kvCurrentUser, jsonEncode(user.toJSON()));
    await db.keyValueDao.set(
      kvServerInfo,
      jsonEncode(
        ServerDto(
          null, null, null, null, null, null, null, null, null, null, null,
          '1.0',
        ).toJSON(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
        connectivityStatusProvider.overrideWith(() => _StubConnectivity()),
        serverDataSourceProvider.overrideWithValue(_OfflineServerDataSource()),
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container.read(initControllerProvider.future);

    expect(outcome, isA<InitGoHome>());
    expect(container.read(currentUserProvider)?.username, 'offline-user');
  });
}
