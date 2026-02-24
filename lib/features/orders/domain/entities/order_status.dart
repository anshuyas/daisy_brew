enum OrderStatus { pending, preparing, ready, delivered, canceled }

extension OrderStatusX on OrderStatus {
  String get value => name;

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
}
