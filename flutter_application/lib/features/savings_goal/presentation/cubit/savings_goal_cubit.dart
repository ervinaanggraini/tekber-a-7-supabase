import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';
import 'package:flutter_application/features/savings_goal/domain/use_cases/create_savings_goal_use_case.dart';
import 'package:flutter_application/features/savings_goal/domain/use_cases/delete_savings_goal_use_case.dart';
import 'package:flutter_application/features/savings_goal/domain/use_cases/get_savings_goals_use_case.dart';
import 'package:flutter_application/features/savings_goal/domain/use_cases/update_savings_goal_use_case.dart';
import 'package:flutter_application/features/savings_goal/presentation/cubit/savings_goal_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class SavingsGoalCubit extends Cubit<SavingsGoalState> {
  final GetSavingsGoalsUseCase getSavingsGoalsUseCase;
  final CreateSavingsGoalUseCase createSavingsGoalUseCase;
  final UpdateSavingsGoalUseCase updateSavingsGoalUseCase;
  final DeleteSavingsGoalUseCase deleteSavingsGoalUseCase;

  SavingsGoalCubit(
    this.getSavingsGoalsUseCase,
    this.createSavingsGoalUseCase,
    this.updateSavingsGoalUseCase,
    this.deleteSavingsGoalUseCase,
  ) : super(SavingsGoalInitial());

  Future<void> loadSavingsGoals(String userId) async {
    emit(SavingsGoalLoading());
    final result = await getSavingsGoalsUseCase(userId);
    result.fold(
      (failure) => emit(SavingsGoalError(failure.message)),
      (goals) => emit(SavingsGoalLoaded(goals)),
    );
  }

  Future<void> createSavingsGoal(SavingsGoal goal) async {
    emit(SavingsGoalLoading());
    final result = await createSavingsGoalUseCase(goal);
    result.fold(
      (failure) => emit(SavingsGoalError(failure.message)),
      (_) {
        emit(const SavingsGoalOperationSuccess('Tujuan tabungan berhasil dibuat'));
        loadSavingsGoals(goal.userId);
      },
    );
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    emit(SavingsGoalLoading());
    final result = await updateSavingsGoalUseCase(goal);
    result.fold(
      (failure) => emit(SavingsGoalError(failure.message)),
      (_) {
        emit(const SavingsGoalOperationSuccess('Tujuan tabungan berhasil diperbarui'));
        loadSavingsGoals(goal.userId);
      },
    );
  }

  Future<void> deleteSavingsGoal(String goalId, String userId) async {
    emit(SavingsGoalLoading());
    final result = await deleteSavingsGoalUseCase(goalId);
    result.fold(
      (failure) => emit(SavingsGoalError(failure.message)),
      (_) {
        emit(const SavingsGoalOperationSuccess('Tujuan tabungan berhasil dihapus'));
        loadSavingsGoals(userId);
      },
    );
  }
}
