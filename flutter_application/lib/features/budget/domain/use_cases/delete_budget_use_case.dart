import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/budget/domain/repositories/budget_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  Future<Either<Failure, void>> call(String budgetId) {
    return repository.deleteBudget(budgetId);
  }
}
