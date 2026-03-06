import '../../domain/entities/auth_entity.dart';

class AuthApiModel {
  final String id;
  final String fullName;
  final String email;
  final String? token;
  final String role;

  AuthApiModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.token,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson({String? password, String? confirmPassword}) {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      if (password != null) 'password': password,
      if (confirmPassword != null) 'confirmPassword': confirmPassword,
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      token: token,
      role: role,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId ?? '',
      fullName: entity.fullName,
      email: entity.email,
      token: entity.token,
      role: entity.role,
    );
  }
}
