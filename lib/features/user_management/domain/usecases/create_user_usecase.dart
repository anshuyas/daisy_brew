import '../repositories/user_repository.dart';
import '../entities/user_entity.dart';

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return await repository.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
