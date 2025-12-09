import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  final int financialHealthScore;
  final List<MonthlyTrend> monthlyTrends;
  final List<FinancialInsight> insights;
  final SavingsGoal savingsGoal;

  const AnalyticsSummary({
    required this.financialHealthScore,
    required this.monthlyTrends,
    required this.insights,
    required this.savingsGoal,
  });

  @override
  List<Object?> get props => [financialHealthScore, monthlyTrends, insights, savingsGoal];
}

class MonthlyTrend extends Equatable {
  final String month;
  final double income;
  final double expense;

  const MonthlyTrend({
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [month, income, expense];
}

class FinancialInsight extends Equatable {
  final String title;
  final String description;
  final InsightType type;

  const FinancialInsight({
    required this.title,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [title, description, type];
}

enum InsightType { success, warning, info }

class SavingsGoal extends Equatable {
  final double target;
  final double current;
  final String deadline;

  const SavingsGoal({
    required this.target,
    required this.current,
    required this.deadline,
  });

  double get progress => current / target;

  @override
  List<Object?> get props => [target, current, deadline];
}
