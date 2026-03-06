import '../repositories/user_repository.dart';

class UpdateUserDetailsUseCase {
  final UserRepository repository;

  UpdateUserDetailsUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String name,
    required String email,
  }) async {
    await repository.updateUserDetails(
      userId: userId,
      name: name,
      email: email,
    );
  }
}
