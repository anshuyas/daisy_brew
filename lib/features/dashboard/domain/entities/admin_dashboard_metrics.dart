class AdminDashboardMetrics {
  final int totalOrdersToday;
  final int totalOrdersWeek;
  final int totalOrdersMonth;
  final double totalRevenue;
  final int activeUsers;
  final int lowStockCount;

  final List<double> weeklyRevenue;

  AdminDashboardMetrics({
    required this.totalOrdersToday,
    required this.totalOrdersWeek,
    required this.totalOrdersMonth,
    required this.totalRevenue,
    required this.activeUsers,
    required this.lowStockCount,
    required this.weeklyRevenue,
  });
}

class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}
