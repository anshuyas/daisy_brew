import 'package:daisy_brew/features/auth/presentation/providers/auth_provider.dart';
import 'package:daisy_brew/features/user_management/data/datasources/remote/user_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';

final dioProvider = Provider<Dio>((ref) {
  const baseUrl = 'http://192.168.254.50:3000/api/v1';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // Attach JWT token to all requests
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = FlutterSecureStorage();
        final token = await storage.read(key: 'auth_token');
        print("FULL URL: ${options.baseUrl}${options.path}");

        print("TOKEN USED: $token");

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
      onError: (err, handler) {
        print('ERROR: ${err.message}');
        return handler.next(err);
      },
    ),
  );
  return dio;
});

/// Remote Datasource Provider
final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDatasource(dio);
});

/// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userRemoteDatasourceProvider);
  return UserRepositoryImpl(datasource);
});

/// Use Case Providers
final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return GetUsersUseCase(repo);
});

final updateUserRoleUseCaseProvider = Provider<UpdateUserRoleUseCase>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UpdateUserRoleUseCase(repo);
});

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return DeleteUserUseCase(repo);
});
