import 'package:injectable/injectable.dart';
import '../repositories/analytics_repository.dart';

@injectable
class UpdateSavingsGoalUseCase {
  final AnalyticsRepository repository;

  UpdateSavingsGoalUseCase(this.repository);

  Future<void> execute(String userId, double targetAmount, DateTime deadline) async {
    return await repository.updateSavingsGoal(userId, targetAmount, deadline);
  }
}
