import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  });
  Future<void> deleteUser({required String userId});
}
