import 'package:injectable/injectable.dart';
import '../repositories/analytics_repository.dart';
import '../entities/analytics_summary.dart';

@injectable
class GetAnalyticsSummaryUseCase {
  final AnalyticsRepository repository;

  GetAnalyticsSummaryUseCase(this.repository);

  Future<AnalyticsSummary> execute(String userId) async {
    return await repository.getAnalyticsSummary(userId);
  }
}
