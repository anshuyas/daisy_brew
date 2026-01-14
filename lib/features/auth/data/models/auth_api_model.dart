import '../../domain/entities/auth_entity.dart';

class AuthApiModel {
  final String id;
  final String fullName;
  final String email;
  final String? token;

  AuthApiModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.token,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'], // JWT token from login/register
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'email': email, 'password': null};
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      password: null,
      profilePicture: null,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity, {String? token}) {
    return AuthApiModel(
      id: entity.authId ?? '',
      fullName: entity.fullName,
      email: entity.email,
      token: token,
    );
  }
}
