import 'package:injectable/injectable.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../data_sources/analytics_remote_data_source.dart';

@LazySingleton(as: AnalyticsRepository)
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String userId) async {
    return await remoteDataSource.getAnalyticsSummary(userId);
  }

  @override
  Future<void> updateSavingsGoal(String userId, double targetAmount, DateTime deadline) async {
    return await remoteDataSource.updateSavingsGoal(userId, targetAmount, deadline);
  }
}
