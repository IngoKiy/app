import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/domain/entities/project_member.dart';
import 'package:vikunja_app/domain/entities/user.dart';

/// Mitgliederverwaltung eines Projekts (online-only, keine lokale Persistenz).
abstract class ProjectMemberRepository {
  Future<Response<List<ProjectMember>>> getMembers(int projectId);

  Future<Response<Object>> addMember(int projectId, String username, int right);

  Future<Response<Object>> updateMemberRight(
    int projectId,
    int userId,
    int right,
  );

  Future<Response<Object>> removeMember(int projectId, int userId);

  /// Globale Nutzersuche für neue Mitglieder.
  Future<Response<List<User>>> searchUsers(String query);
}
