import 'package:daisy_brew/core/api/api_client.dart';

class OrderRemoteDatasource {
  final ApiClient _apiClient;

  OrderRemoteDatasource(this._apiClient);

  Future<void> createOrder({
    required List<Map<String, dynamic>> products,
    required double totalPrice,
  }) async {
    final body = {'products': products, 'totalPrice': totalPrice};

    try {
      print("Sending order: $body");
      final response = await _apiClient.post('/orders', data: body);
      print("Response from backend: $response");
    } catch (e) {
      print("Error sending order: $e");
    }
  }
}
