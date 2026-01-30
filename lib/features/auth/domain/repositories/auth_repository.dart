import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(
    RegisterParams any, {
    required AuthEntity user,
    required String confirmPassword,
  });
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
}
