import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    required int totalOrders,
  }) : super(
         id: id,
         name: name,
         email: email,
         role: role,
         totalOrders: totalOrders,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['fullName'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
      role: json['role'] ?? 'user',
      totalOrders: json['totalOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': name,
      'email': email,
      'role': role,
      'totalOrders': totalOrders,
    };
  }
}
