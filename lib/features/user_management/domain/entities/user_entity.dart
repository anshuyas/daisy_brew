class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final int totalOrders;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.totalOrders,
  });

  UserEntity copyWith({
    String? name,
    String? email,
    String? role,
    int? totalOrders,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}
