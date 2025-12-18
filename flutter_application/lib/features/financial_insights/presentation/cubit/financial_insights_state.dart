import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/financial_insights/domain/entities/financial_insight.dart';

abstract class FinancialInsightsState extends Equatable {
  const FinancialInsightsState();

  @override
  List<Object> get props => [];
}

class FinancialInsightsInitial extends FinancialInsightsState {}

class FinancialInsightsLoading extends FinancialInsightsState {}

class FinancialInsightsLoaded extends FinancialInsightsState {
  final List<FinancialInsight> insights;

  const FinancialInsightsLoaded(this.insights);

  @override
  List<Object> get props => [insights];
}

class FinancialInsightsError extends FinancialInsightsState {
  final String message;

  const FinancialInsightsError(this.message);

  @override
  List<Object> get props => [message];
}
