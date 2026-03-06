import 'package:daisy_brew/features/user_management/data/models/user_model.dart';

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

  @override
  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final userJson = await remoteDatasource.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    // Assuming remoteDatasource returns JSON compatible with UserModel
    return UserModel.fromJson(userJson);
  }

  @override
  Future<void> updateUserDetails({
    required String userId,
    required String name,
    required String email,
  }) async {
    await remoteDatasource.updateUserDetails(
      userId: userId,
      name: name,
      email: email,
    );
  }
}
