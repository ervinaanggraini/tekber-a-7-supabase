import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';
import 'package:flutter_application/features/savings_goal/domain/repositories/savings_goal_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetSavingsGoalsUseCase {
  final SavingsGoalRepository repository;

  GetSavingsGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingsGoal>>> call(String userId) {
    return repository.getSavingsGoals(userId);
  }
}
