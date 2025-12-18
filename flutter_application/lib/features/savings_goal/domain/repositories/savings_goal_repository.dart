import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';

abstract class SavingsGoalRepository {
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals(String userId);
  Future<Either<Failure, void>> createSavingsGoal(SavingsGoal goal);
  Future<Either<Failure, void>> updateSavingsGoal(SavingsGoal goal);
  Future<Either<Failure, void>> deleteSavingsGoal(String goalId);
}
