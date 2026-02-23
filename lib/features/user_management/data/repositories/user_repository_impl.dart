import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<UserEntity>> getUsers() async {
    return await remoteDatasource.getUsers();
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    await remoteDatasource.updateUserRole(userId: userId, newRole: newRole);
  }

  @override
  Future<void> deleteUser({required String userId}) async {
    await remoteDatasource.deleteUser(userId: userId);
  }
}
