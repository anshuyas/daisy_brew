import 'package:daisy_brew/core/api/api_client.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/admin_dashboard_metrics.dart';
import 'package:http/http.dart';

abstract class IAdminDashboardRemoteDataSource {
  Future<AdminDashboardMetrics> fetchDashboardMetrics();
}

class AdminDashboardRemoteDataSource
    implements IAdminDashboardRemoteDataSource {
  final ApiClient client;

  AdminDashboardRemoteDataSource({required this.client});

  @override
  Future<AdminDashboardMetrics> fetchDashboardMetrics() async {
    try {
      // Call the backend API
      final data = await client.get('/admin/dashboard');

      if (data == null) {
        throw Exception('No data returned from backend');
      }

      // Map backend response to AdminDashboardMetrics
      return AdminDashboardMetrics(
        totalOrdersToday: data['totalOrdersToday'] ?? 0,
        totalOrdersWeek: data['totalOrdersWeek'] ?? 0,
        totalOrdersMonth: data['totalOrdersMonth'] ?? 0,
        totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        activeUsers: data['activeUsers'] ?? 0,
        lowStockCount: data['lowStockCount'] ?? 0,
        weeklyRevenue: (data['weeklyRevenue'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
      );
    } catch (e) {
      // Wrap and rethrow exceptions
      throw Exception('Failed to fetch dashboard metrics: $e');
    }
  }
}
