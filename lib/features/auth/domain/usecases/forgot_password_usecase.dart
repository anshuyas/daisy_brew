import 'package:daisy_brew/features/auth/data/repositories/auth_repository.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordParams {
  final String email;
  ForgotPasswordParams({required this.email});
}

class ForgotPasswordUsecase {
  final IAuthRepository _repository;
  ForgotPasswordUsecase(this._repository);

  Future<void> call(ForgotPasswordParams params) async {
    final result = await _repository.sendPasswordResetEmail(params.email);

    result.fold(
      (failure) => throw Exception(failure.message),
      (success) => null,
    );
  }
}

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return ForgotPasswordUsecase(repository);
});
