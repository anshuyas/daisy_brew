import 'package:daisy_brew/features/user_management/data/models/user_model.dart';
import 'package:dio/dio.dart';

class UserRemoteDatasource {
  final Dio dio;

  UserRemoteDatasource(this.dio);

  Future<List<UserModel>> getUsers() async {
    try {
      print('GET USERS URL: ${dio.options.baseUrl}/admin/users');
      final response = await dio.get('/admin/users');
      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('GET USERS ERROR: $e');
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      await dio.put('/admin/users/$userId/role', data: {'role': newRole});
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  Future<void> deleteUser({required String userId}) async {
    try {
      await dio.delete('/admin/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await dio.post(
        '/admin/users',
        data: {
          'fullName': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUserDetails({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await dio.put(
        '/admin/users/$userId',
        data: {'fullName': name, 'email': email},
      );
    } catch (e) {
      throw Exception('Failed to update user details: $e');
    }
  }
}
