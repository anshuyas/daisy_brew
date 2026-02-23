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
}
