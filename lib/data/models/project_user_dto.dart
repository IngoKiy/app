import 'package:vikunja_app/data/models/dto.dart';
import 'package:vikunja_app/domain/entities/project_member.dart';
import 'package:vikunja_app/domain/entities/user.dart';

/// Antwort von `GET /projects/{id}/users` (Server-Modell UserWithPermission):
/// die Nutzerfelder plus [permission] (0 = Lesen, 1 = Schreiben, 2 = Admin).
class ProjectUserDto extends Dto<ProjectMember> {
  final int id;
  final String username;
  final String name;
  final int permission;

  ProjectUserDto({
    this.id = 0,
    this.username = '',
    this.name = '',
    this.permission = 0,
  });

  ProjectUserDto.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? 0,
      username = json['username'] ?? '',
      name = json['name'] ?? '',
      permission = (json['permission'] as num?)?.toInt() ?? 0;

  @override
  ProjectMember toDomain() => ProjectMember(
    user: User(id: id, name: name, username: username),
    right: permission,
  );
}
