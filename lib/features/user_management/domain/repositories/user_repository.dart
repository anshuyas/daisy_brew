import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  });
  Future<void> deleteUser({required String userId});

  Future<void> updateUserDetails({
    required String userId,
    required String name,
    required String email,
  });

  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}
