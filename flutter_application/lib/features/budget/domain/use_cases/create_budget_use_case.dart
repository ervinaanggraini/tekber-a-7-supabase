import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/budget/domain/entities/budget.dart';
import 'package:flutter_application/features/budget/domain/repositories/budget_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateBudgetUseCase {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  Future<Either<Failure, void>> call(Budget budget) {
    return repository.createBudget(budget);
  }
}
