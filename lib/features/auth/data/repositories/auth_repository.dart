import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/core/services/connectivity/network_info.dart';
import 'package:daisy_brew/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:daisy_brew/features/auth/data/models/auth_api_model.dart';
import 'package:daisy_brew/features/auth/domain/entities/auth_entity.dart';
import 'package:daisy_brew/features/auth/domain/repositories/auth_repository.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;
  final INetworkInfo _networkInfo;

  AuthRepository({
    required AuthRemoteDatasource authRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(
    RegisterParams params, {
    required AuthEntity user,
    required String confirmPassword,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final password = user.password ?? '';
        final model = AuthApiModel.fromEntity(user);

        await _authRemoteDatasource.registerUser(
          model: model,
          password: password,
          confirmPassword: confirmPassword,
        );

        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _authRemoteDatasource.loginUser(
          email: email,
          password: password,
        );
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authRemoteDatasource.getCurrentUser();
      if (model != null) return Right(model.toEntity());
      return const Left(ApiFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _authRemoteDatasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Forgot Password method
  @override
  Future<Either<Failure, bool>> sendPasswordResetEmail(String email) async {
    final connected = await _networkInfo.isConnected;
    if (!connected)
      return const Left(ApiFailure(message: 'No internet connection'));

    try {
      await _authRemoteDatasource.sendPasswordResetEmail(email);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to send reset email',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Reset Password method
  @override
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final connected = await _networkInfo.isConnected;
    if (connected) {
      try {
        await _authRemoteDatasource.resetPassword(token, newPassword);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to reset password',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}

// extension remains the same
extension AuthApiModelExtension on AuthApiModel {
  Map<String, dynamic> toJson({String? password, String? confirmPassword}) {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
