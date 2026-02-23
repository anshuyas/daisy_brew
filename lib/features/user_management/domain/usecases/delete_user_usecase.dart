import '../repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> call({required String userId}) =>
      repository.deleteUser(userId: userId);
}
