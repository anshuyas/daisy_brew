import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordParams {
  final String token;
  final String newPassword;

  ResetPasswordParams({required this.token, required this.newPassword});
}

class ResetPasswordUsecase {
  final IAuthRepository _repository;

  ResetPasswordUsecase(this._repository);

  Future<Either<Failure, bool>> call(ResetPasswordParams params) async {
    return await _repository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}
