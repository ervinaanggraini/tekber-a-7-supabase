import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/budget/data/data_sources/budget_remote_data_source.dart';
import 'package:flutter_application/features/budget/data/models/budget_model.dart';
import 'package:flutter_application/features/budget/domain/entities/budget.dart';
import 'package:flutter_application/features/budget/domain/repositories/budget_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Budget>>> getBudgets(String userId) async {
    try {
      final result = await remoteDataSource.getBudgets(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createBudget(Budget budget) async {
    try {
      final budgetModel = BudgetModel(
        id: budget.id,
        userId: budget.userId,
        categoryId: budget.categoryId,
        name: budget.name,
        amount: budget.amount,
        period: budget.period,
        startDate: budget.startDate,
        endDate: budget.endDate,
        alertThreshold: budget.alertThreshold,
        isActive: budget.isActive,
      );
      await remoteDataSource.createBudget(budgetModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudget(Budget budget) async {
    try {
      final budgetModel = BudgetModel(
        id: budget.id,
        userId: budget.userId,
        categoryId: budget.categoryId,
        name: budget.name,
        amount: budget.amount,
        period: budget.period,
        startDate: budget.startDate,
        endDate: budget.endDate,
        alertThreshold: budget.alertThreshold,
        isActive: budget.isActive,
      );
      await remoteDataSource.updateBudget(budgetModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String budgetId) async {
    try {
      await remoteDataSource.deleteBudget(budgetId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
