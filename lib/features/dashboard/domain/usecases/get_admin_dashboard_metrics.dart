import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/admin_dashboard_metrics.dart';
import 'package:daisy_brew/features/dashboard/domain/repositories/admin_dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class GetAdminDashboardMetrics {
  final IAdminDashboardRepository repository;

  GetAdminDashboardMetrics(this.repository);

  Future<Either<Failure, AdminDashboardMetrics>> call() async {
    final result = await repository.getDashboardMetrics();
    return result;
  }
}
