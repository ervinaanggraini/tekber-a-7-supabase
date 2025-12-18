import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/budget/domain/entities/budget.dart';
import 'package:flutter_application/features/budget/domain/use_cases/create_budget_use_case.dart';
import 'package:flutter_application/features/budget/domain/use_cases/delete_budget_use_case.dart';
import 'package:flutter_application/features/budget/domain/use_cases/get_budgets_use_case.dart';
import 'package:flutter_application/features/budget/domain/use_cases/update_budget_use_case.dart';
import 'package:flutter_application/features/budget/presentation/cubit/budget_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgetsUseCase getBudgetsUseCase;
  final CreateBudgetUseCase createBudgetUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;

  BudgetCubit(
    this.getBudgetsUseCase,
    this.createBudgetUseCase,
    this.updateBudgetUseCase,
    this.deleteBudgetUseCase,
  ) : super(BudgetInitial());

  Future<void> loadBudgets(String userId) async {
    emit(BudgetLoading());
    final result = await getBudgetsUseCase(userId);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) => emit(BudgetLoaded(budgets)),
    );
  }

  Future<void> createBudget(Budget budget) async {
    emit(BudgetLoading());
    final result = await createBudgetUseCase(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget berhasil dibuat'));
        loadBudgets(budget.userId);
      },
    );
  }

  Future<void> updateBudget(Budget budget) async {
    emit(BudgetLoading());
    final result = await updateBudgetUseCase(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget berhasil diperbarui'));
        loadBudgets(budget.userId);
      },
    );
  }

  Future<void> deleteBudget(String budgetId, String userId) async {
    emit(BudgetLoading());
    final result = await deleteBudgetUseCase(budgetId);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget berhasil dihapus'));
        loadBudgets(userId);
      },
    );
  }
}
