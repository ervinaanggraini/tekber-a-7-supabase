import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/savings_goal/data/data_sources/savings_goal_remote_data_source.dart';
import 'package:flutter_application/features/savings_goal/data/models/savings_goal_model.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';
import 'package:flutter_application/features/savings_goal/domain/repositories/savings_goal_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SavingsGoalRepository)
class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  final SavingsGoalRemoteDataSource remoteDataSource;

  SavingsGoalRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals(String userId) async {
    try {
      final result = await remoteDataSource.getSavingsGoals(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSavingsGoal(SavingsGoal goal) async {
    try {
      final model = SavingsGoalModel(
        id: goal.id,
        userId: goal.userId,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        targetDate: goal.targetDate,
        icon: goal.icon,
        color: goal.color,
        isCompleted: goal.isCompleted,
      );
      await remoteDataSource.createSavingsGoal(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSavingsGoal(SavingsGoal goal) async {
    try {
      final model = SavingsGoalModel(
        id: goal.id,
        userId: goal.userId,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        targetDate: goal.targetDate,
        icon: goal.icon,
        color: goal.color,
        isCompleted: goal.isCompleted,
      );
      await remoteDataSource.updateSavingsGoal(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavingsGoal(String goalId) async {
    try {
      await remoteDataSource.deleteSavingsGoal(goalId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
