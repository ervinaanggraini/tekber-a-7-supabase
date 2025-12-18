import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/financial_insights/data/data_sources/financial_insights_remote_data_source.dart';
import 'package:flutter_application/features/financial_insights/domain/entities/financial_insight.dart';
import 'package:flutter_application/features/financial_insights/domain/repositories/financial_insights_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FinancialInsightsRepository)
class FinancialInsightsRepositoryImpl implements FinancialInsightsRepository {
  final FinancialInsightsRemoteDataSource remoteDataSource;

  FinancialInsightsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<FinancialInsight>>> getFinancialInsights(String userId) async {
    try {
      final result = await remoteDataSource.getFinancialInsights(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String insightId) async {
    try {
      await remoteDataSource.markAsRead(insightId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
