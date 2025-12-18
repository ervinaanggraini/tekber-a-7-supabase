import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/budget/domain/entities/budget.dart';
import 'package:flutter_application/features/budget/domain/repositories/budget_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  Future<Either<Failure, List<Budget>>> call(String userId) {
    return repository.getBudgets(userId);
  }
}
