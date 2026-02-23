import 'package:daisy_brew/features/dashboard/presentation/pages/admin_menu_screen.dart';
import 'package:daisy_brew/features/user_management/presentation/pages/user_management_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.brown,
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (metrics) {
          // Ensure weeklyRevenue always has 7 items (Mon-Sun)
          final weeklyRevenue = metrics.weeklyRevenue.length == 7
              ? metrics.weeklyRevenue
              : List.filled(7, 0);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Orders & Revenue Cards
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _AdminInfoCard(
                          title: "Orders Today",
                          value: metrics.totalOrdersToday.toString(),
                          color: Colors.orange,
                          height: 80,
                        ),
                        _AdminInfoCard(
                          title: "Orders This Week",
                          value: metrics.totalOrdersWeek.toString(),
                          color: Colors.blue,
                          height: 80,
                        ),
                        _AdminInfoCard(
                          title: "Orders This Month",
                          value: metrics.totalOrdersMonth.toString(),
                          color: Colors.purple,
                          height: 80,
                        ),
                        _AdminInfoCard(
                          title: "Total Revenue",
                          value:
                              "Rs. ${metrics.totalRevenue.toStringAsFixed(2)}",
                          color: Colors.green,
                          height: 80,
                        ),
                        _AdminInfoCard(
                          title: "Active Users",
                          value: metrics.activeUsers.toString(),
                          color: Colors.teal,
                          height: 80,
                        ),
                        _AdminInfoCard(
                          title: "Low Stock Items",
                          value: metrics.lowStockCount.toString(),
                          color: Colors.red,
                          height: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sales Trend Graph
                    Container(
                      height: 230,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ];
                                  int index = value.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                                interval: 1,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                7,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  weeklyRevenue[index].toDouble(),
                                ),
                              ),
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [Colors.teal, Colors.greenAccent],
                              ),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Quick Links
                    Text(
                      "Quick Links",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _AdminQuickLinkCard(
                          title: "Menu",
                          icon: Icons.menu_book,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminMenuPage(),
                              ),
                            );
                          },
                        ),
                        _AdminQuickLinkCard(
                          title: "Orders",
                          icon: Icons.receipt_long,
                          onTap: () {
                            // TODO: Navigate to Orders page
                          },
                        ),
                        _AdminQuickLinkCard(
                          title: "Users",
                          icon: Icons.people,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserManagementPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double height;

  const _AdminInfoCard({
    required this.title,
    required this.value,
    required this.color,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24, // responsive width
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminQuickLinkCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminQuickLinkCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.teal),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
