import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? password;
  final String? profilePicture;
  final String? token;
  final String role;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.role,
    this.password,
    this.profilePicture,
    this.token,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    password,
    profilePicture,
    token,
  ];
}
