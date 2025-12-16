import 'package:equatable/equatable.dart';

class ReportSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, CategoryReport> categoryBreakdown;

  const ReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryBreakdown,
  });

  @override
  List<Object?> get props => [totalIncome, totalExpense, balance, categoryBreakdown];
}

class CategoryReport extends Equatable {
  final String categoryName;
  final double amount;
  final int percentage;

  const CategoryReport({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryName, amount, percentage];
}
