import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/admin_dashboard_metrics.dart';
import 'package:dartz/dartz.dart';

abstract class IAdminDashboardRepository {
  Future<Either<Failure, AdminDashboardMetrics>> getDashboardMetrics();
}
