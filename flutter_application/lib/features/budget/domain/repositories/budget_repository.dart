import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/budget/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets(String userId);
  Future<Either<Failure, void>> createBudget(Budget budget);
  Future<Either<Failure, void>> updateBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(String budgetId);
}
