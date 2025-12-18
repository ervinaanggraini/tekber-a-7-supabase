import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/savings_goal/domain/repositories/savings_goal_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  DeleteSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> call(String goalId) {
    return repository.deleteSavingsGoal(goalId);
  }
}
