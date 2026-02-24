import 'package:daisy_brew/core/api/api_client.dart';
import '../models/order_model.dart';

class OrderRemoteDatasource {
  final ApiClient apiClient;

  OrderRemoteDatasource(this.apiClient);

  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> products,
    required double totalPrice,
  }) async {
    final body = {'products': products, 'totalPrice': totalPrice};

    final response = await apiClient.post('/orders', data: body);

    return OrderModel.fromJson(response['order']);
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await apiClient.get('/orders');

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await apiClient.get('/orders/$id');
    return OrderModel.fromJson(response);
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await apiClient.put('/orders/$id/status', data: {'status': status});
  }

  Future<List<OrderModel>> searchOrders(String query) async {
    final response = await apiClient.get('/orders?search=$query');

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> filterOrders({
    String? status,
    String? orderType,
    DateTime? date,
  }) async {
    String query = '/orders?';

    if (status != null) query += 'status=$status&';
    if (orderType != null) query += 'orderType=$orderType&';
    if (date != null) query += 'date=${date.toIso8601String()}&';

    final response = await apiClient.get(query);

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await apiClient.get('/orders/my-orders');

      print("MY ORDERS RESPONSE: $response");

      return (response as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      print("GET MY ORDERS ERROR: $e");
      rethrow;
    }
  }
}
