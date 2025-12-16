import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/use_cases/get_analytics_summary_use_case.dart';
import '../../domain/use_cases/update_savings_goal_use_case.dart';

part 'analytics_state.dart';

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetAnalyticsSummaryUseCase getAnalyticsSummaryUseCase;
  final UpdateSavingsGoalUseCase updateSavingsGoalUseCase;

  AnalyticsCubit(
    this.getAnalyticsSummaryUseCase,
    this.updateSavingsGoalUseCase,
  ) : super(AnalyticsInitial());

  Future<void> loadAnalytics(String userId) async {
    emit(AnalyticsLoading());

    try {
      final summary = await getAnalyticsSummaryUseCase.execute(userId);
      emit(AnalyticsLoaded(summary: summary));
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }

  Future<void> updateSavingsGoal(String userId, double targetAmount, DateTime deadline) async {
    try {
      await updateSavingsGoalUseCase.execute(userId, targetAmount, deadline);
      await loadAnalytics(userId); // Reload to show updated data
    } catch (e) {
      emit(AnalyticsError(message: e.toString()));
    }
  }
}
