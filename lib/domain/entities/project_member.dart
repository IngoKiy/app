import 'package:vikunja_app/domain/entities/user.dart';

/// Ein Projektmitglied: der Nutzer samt seiner Rolle im Projekt.
/// [right]: 0 = Lesen, 1 = Schreiben, 2 = Admin.
class ProjectMember {
  final User user;
  final int right;

  const ProjectMember({required this.user, required this.right});

  ProjectMember copyWith({int? right}) =>
      ProjectMember(user: user, right: right ?? this.right);
}
