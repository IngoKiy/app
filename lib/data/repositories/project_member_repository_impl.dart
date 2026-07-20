import 'package:vikunja_app/core/network/response.dart';
import 'package:vikunja_app/core/utils/mapping_extensions.dart';
import 'package:vikunja_app/data/data_sources/project_member_data_source.dart';
import 'package:vikunja_app/domain/entities/project_member.dart';
import 'package:vikunja_app/domain/entities/user.dart';
import 'package:vikunja_app/domain/repositories/project_member_repository.dart';

class ProjectMemberRepositoryImpl extends ProjectMemberRepository {
  final ProjectMemberDataSource _dataSource;

  ProjectMemberRepositoryImpl(this._dataSource);

  @override
  Future<Response<List<ProjectMember>>> getMembers(int projectId) async {
    return (await _dataSource.getMembers(projectId)).toDomain();
  }

  @override
  Future<Response<Object>> addMember(
    int projectId,
    String username,
    int right,
  ) {
    return _dataSource.addMember(projectId, username, right);
  }

  @override
  Future<Response<Object>> updateMemberRight(
    int projectId,
    int userId,
    int right,
  ) {
    return _dataSource.updateMemberRight(projectId, userId, right);
  }

  @override
  Future<Response<Object>> removeMember(int projectId, int userId) {
    return _dataSource.removeMember(projectId, userId);
  }

  @override
  Future<Response<List<User>>> searchUsers(String query) async {
    return (await _dataSource.searchUsers(query)).toDomain();
  }
}
