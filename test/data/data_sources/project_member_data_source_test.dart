import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:vikunja_app/core/network/client.dart';
import 'package:vikunja_app/data/data_sources/project_member_data_source.dart';
import 'package:vikunja_app/data/data_sources/settings_data_source.dart';

const _baseUrl = 'https://vikunja.example.com';

class _StubSettings implements SettingsDatasource {
  @override
  Future<String?> getUserToken() async => 'token';
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Client-Subklasse, die den http-Layer durch einen MockClient ersetzt.
class _TestableClient extends Client {
  final http.Client mockHttpClient;
  _TestableClient({required super.base, required this.mockHttpClient});
  @override
  http.Client createClient() => mockHttpClient;
}

ProjectMemberDataSource _dataSource(
  http.Client mockHttp,
) {
  final client = _TestableClient(base: _baseUrl, mockHttpClient: mockHttp)
    ..settingsDatasource = _StubSettings();
  return ProjectMemberDataSource(client);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getMembers parst UserWithPermission-Liste inkl. permission', () async {
    late http.Request captured;
    final ds = _dataSource(
      http_testing.MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode([
            {
              'id': 3,
              'username': 'alice',
              'name': 'Alice A',
              'permission': 2,
              'created': '2026-01-01T00:00:00Z',
              'updated': '2026-01-01T00:00:00Z',
            },
            {
              'id': 4,
              'username': 'bob',
              'name': '',
              'permission': 0,
              'created': '2026-01-01T00:00:00Z',
              'updated': '2026-01-01T00:00:00Z',
            },
          ]),
          200,
        );
      }),
    );

    final response = await ds.getMembers(7);

    expect(captured.method, 'GET');
    expect(captured.url.path, '/api/v1/projects/7/users');
    expect(response.isSuccessful, isTrue);
    final members = response.toSuccess().body;
    expect(members.length, 2);
    expect(members[0].username, 'alice');
    expect(members[0].permission, 2);
    expect(members[1].username, 'bob');
    expect(members[1].permission, 0);
  });

  test('addMember → PUT /projects/{id}/users mit username+permission', () async {
    late http.Request captured;
    final ds = _dataSource(
      http_testing.MockClient((request) async {
        captured = request;
        return http.Response('{}', 201);
      }),
    );

    final response = await ds.addMember(7, 'carol', 1);

    expect(captured.method, 'PUT');
    expect(captured.url.path, '/api/v1/projects/7/users');
    expect(jsonDecode(captured.body), {'username': 'carol', 'permission': 1});
    expect(response.isSuccessful, isTrue);
  });

  test('updateMemberRight → POST /projects/{id}/users/{user} mit permission', () async {
    late http.Request captured;
    final ds = _dataSource(
      http_testing.MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      }),
    );

    final response = await ds.updateMemberRight(7, 42, 2);

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/v1/projects/7/users/42');
    expect(jsonDecode(captured.body), {'permission': 2});
    expect(response.isSuccessful, isTrue);
  });

  test('removeMember → DELETE /projects/{id}/users/{user}', () async {
    late http.Request captured;
    final ds = _dataSource(
      http_testing.MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      }),
    );

    final response = await ds.removeMember(7, 42);

    expect(captured.method, 'DELETE');
    expect(captured.url.path, '/api/v1/projects/7/users/42');
    expect(response.isSuccessful, isTrue);
  });

  test('searchUsers → GET /users mit s-Query', () async {
    late http.Request captured;
    final ds = _dataSource(
      http_testing.MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode([
            {
              'id': 9,
              'username': 'dave',
              'name': 'Dave',
              'created': '2026-01-01T00:00:00Z',
              'updated': '2026-01-01T00:00:00Z',
            },
          ]),
          200,
        );
      }),
    );

    final response = await ds.searchUsers('dav');

    expect(captured.method, 'GET');
    expect(captured.url.path, '/api/v1/users');
    expect(captured.url.queryParameters['s'], 'dav');
    expect(response.isSuccessful, isTrue);
    expect(response.toSuccess().body.single.username, 'dave');
  });
}
