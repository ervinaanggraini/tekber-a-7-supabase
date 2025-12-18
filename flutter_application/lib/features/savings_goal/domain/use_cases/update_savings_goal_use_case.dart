import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';
import 'package:flutter_application/features/savings_goal/domain/repositories/savings_goal_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  UpdateSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> call(SavingsGoal goal) {
    return repository.updateSavingsGoal(goal);
  }
}
