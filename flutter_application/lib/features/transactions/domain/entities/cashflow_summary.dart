import 'package:equatable/equatable.dart';

class CashflowSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double incomePercentage;
  final double expensePercentage;

  const CashflowSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.incomePercentage,
    required this.expensePercentage,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        incomePercentage,
        expensePercentage,
      ];
}
