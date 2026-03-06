import 'package:daisy_brew/core/api/api_client.dart';
import 'package:daisy_brew/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/admin_dashboard_metrics.dart';
import '../../domain/usecases/get_admin_dashboard_metrics.dart';
import '../../data/datasources/remote/admin_dashboard_api.dart';
import '../../data/repositories/admin_dashboard_repository_impl.dart';

final adminDashboardProvider =
    StateNotifierProvider<
      AdminDashboardNotifier,
      AsyncValue<AdminDashboardMetrics>
    >((ref) {
      final apiClient = ref.read(apiClientProvider);
      final remoteApi = AdminDashboardRemoteDataSource(
        client: ref.read(apiClientProvider),
      );
      final repo = AdminDashboardRepositoryImpl(remoteDataSource: remoteApi);
      final useCase = GetAdminDashboardMetrics(repo);
      return AdminDashboardNotifier(useCase);
    });

class AdminDashboardNotifier
    extends StateNotifier<AsyncValue<AdminDashboardMetrics>> {
  final GetAdminDashboardMetrics useCase;

  AdminDashboardNotifier(this.useCase) : super(const AsyncValue.loading()) {
    fetchMetrics();
  }

  Future<void> fetchMetrics() async {
    state = const AsyncValue.loading();

    try {
      final Either<Failure, AdminDashboardMetrics> result = await useCase();

      result.fold(
        // Pass the Failure object and stack trace to AsyncValue.error
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (metrics) => state = AsyncValue.data(metrics),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
