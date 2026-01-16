import 'package:daisy_brew/core/api/api_client.dart';
import 'package:daisy_brew/core/api/api_endpoints.dart';
import 'package:daisy_brew/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDatasource(apiClient);
});

class AuthRemoteDatasource {
  final ApiClient _apiClient;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  AuthRemoteDatasource(this._apiClient);

  Future<AuthApiModel> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final body = {'fullName': fullName, 'email': email, 'password': password};

    final response = await _apiClient.dio.post(
      ApiEndpoints.userRegister,
      data: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final userData = data['data'] ?? {};
      final token = data['token'] as String?;

      if (token != null) await _storage.write(key: _tokenKey, value: token);

      return AuthApiModel.fromJson({...userData, 'token': token});
    } else {
      throw Exception('Registration failed: ${response.data}');
    }
  }

  Future<AuthApiModel> loginUser({
    required String email,
    required String password,
  }) async {
    final body = {'email': email, 'password': password};

    final response = await _apiClient.dio.post(
      ApiEndpoints.userLogin,
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final userData = data['data'] ?? {};
      final token = data['token'] as String?;

      if (token != null) await _storage.write(key: _tokenKey, value: token);

      return AuthApiModel.fromJson({...userData, 'token': token});
    } else {
      throw Exception('Login failed: ${response.data}');
    }
  }

  Future<AuthApiModel?> getCurrentUser() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    final response = await _apiClient.dio.get('${ApiEndpoints.users}/me');

    if (response.statusCode == 200) {
      final userData = response.data['data'] ?? {};
      return AuthApiModel.fromJson({...userData, 'token': token});
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}
