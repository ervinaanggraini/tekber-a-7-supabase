import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/financial_insights/domain/entities/financial_insight.dart';
import 'package:flutter_application/features/financial_insights/domain/repositories/financial_insights_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetFinancialInsightsUseCase {
  final FinancialInsightsRepository repository;

  GetFinancialInsightsUseCase(this.repository);

  Future<Either<Failure, List<FinancialInsight>>> call(String userId) {
    return repository.getFinancialInsights(userId);
  }
}
