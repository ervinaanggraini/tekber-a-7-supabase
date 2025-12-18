import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';
import 'package:flutter_application/features/savings_goal/domain/repositories/savings_goal_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateSavingsGoalUseCase {
  final SavingsGoalRepository repository;

  CreateSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> call(SavingsGoal goal) {
    return repository.createSavingsGoal(goal);
  }
}
