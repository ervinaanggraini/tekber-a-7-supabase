import '../entities/analytics_summary.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummary> getAnalyticsSummary(String userId);
  Future<void> updateSavingsGoal(String userId, double targetAmount, DateTime deadline);
}
