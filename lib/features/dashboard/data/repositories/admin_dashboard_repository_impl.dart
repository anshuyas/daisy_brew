import 'package:daisy_brew/core/error/failures.dart';
import 'package:daisy_brew/features/dashboard/data/datasources/remote/admin_dashboard_api.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/admin_dashboard_metrics.dart';
import 'package:daisy_brew/features/dashboard/domain/repositories/admin_dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class AdminDashboardRepositoryImpl implements IAdminDashboardRepository {
  final IAdminDashboardRemoteDataSource remoteDataSource;

  AdminDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminDashboardMetrics>> getDashboardMetrics() async {
    try {
      final metrics = await remoteDataSource.fetchDashboardMetrics();
      return Right(metrics);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
