import 'package:vikunja_app/core/network/remote_data_source.dart';
import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/data/models/project_user_dto.dart';
import 'package:vikunja_app/data/models/user_dto.dart';

/// Zugriff auf die Mitgliederverwaltung eines Projekts.
///
/// Online-only: es gibt keine lokale Members-Tabelle. Aufrufer prüfen die
/// Verbindung und rufen diese Methoden nur, wenn der Server erreichbar ist.
///
/// API-Mapping (Vikunja-Server, Modelle UserWithPermission/ProjectUser):
/// - Liste:   GET    /projects/{id}/users
/// - Hinzu:   PUT    /projects/{id}/users        Body {username, permission}
/// - Rolle:   POST   /projects/{id}/users/{user} Body {permission}
/// - Entf.:   DELETE /projects/{id}/users/{user}
/// - Suche:   GET    /users?s=...                (globale Nutzersuche)
class ProjectMemberDataSource extends RemoteDataSource {
  ProjectMemberDataSource(super.client);

  /// Mitglieder eines Projekts inkl. Rolle.
  Future<Response<List<ProjectUserDto>>> getMembers(int projectId) {
    return client.get(
      url: '/projects/$projectId/users',
      mapper: (body) =>
          convertList(body, (json) => ProjectUserDto.fromJson(json)),
    );
  }

  /// Fügt einen Nutzer (per Benutzername) mit der Rolle [right] hinzu.
  Future<Response<Object>> addMember(
    int projectId,
    String username,
    int right,
  ) {
    return client.put(
      url: '/projects/$projectId/users',
      body: {'username': username, 'permission': right},
    );
  }

  /// Ändert die Rolle eines vorhandenen Mitglieds.
  Future<Response<Object>> updateMemberRight(
    int projectId,
    int userId,
    int right,
  ) {
    return client.post(
      url: '/projects/$projectId/users/$userId',
      body: {'permission': right},
    );
  }

  /// Entfernt ein Mitglied aus dem Projekt.
  Future<Response<Object>> removeMember(int projectId, int userId) {
    return client.delete(url: '/projects/$projectId/users/$userId');
  }

  /// Globale Nutzersuche (für das Hinzufügen neuer Mitglieder). Ein leerer
  /// [query] liefert ohne `s`-Parameter die vom Server voreingestellte Liste.
  Future<Response<List<UserDto>>> searchUsers(String query) {
    return client.get(
      url: '/users',
      queryParameters: query.isNotEmpty
          ? {
              's': [query],
            }
          : null,
      mapper: (body) => convertList(body, (json) => UserDto.fromJson(json)),
    );
  }
}
