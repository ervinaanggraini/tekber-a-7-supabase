import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/financial_insights/domain/entities/financial_insight.dart';

abstract class FinancialInsightsRepository {
  Future<Either<Failure, List<FinancialInsight>>> getFinancialInsights(String userId);
  Future<Either<Failure, void>> markAsRead(String insightId);
}
