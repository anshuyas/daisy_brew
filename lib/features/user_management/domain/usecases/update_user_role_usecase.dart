import '../repositories/user_repository.dart';

class UpdateUserRoleUseCase {
  final UserRepository repository;
  UpdateUserRoleUseCase(this.repository);
  Future<void> call({required String userId, required String newRole}) =>
      repository.updateUserRole(userId: userId, newRole: newRole);
}
