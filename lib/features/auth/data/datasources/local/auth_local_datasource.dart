import 'package:daisy_brew/core/services/hive/hive_service.dart';
import 'package:daisy_brew/features/auth/data/datasources/auth_datasource.dart';
import 'package:daisy_brew/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(HiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      await _hiveService.registerUser(user);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }
}
