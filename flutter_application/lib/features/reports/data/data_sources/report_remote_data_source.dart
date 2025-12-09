import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/report_summary.dart';

abstract class ReportRemoteDataSource {
  Future<ReportSummary> getReportSummary(String userId, DateTime startDate, DateTime endDate);
}

@LazySingleton(as: ReportRemoteDataSource)
class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient supabase;

  ReportRemoteDataSourceImpl(this.supabase);

  @override
  Future<ReportSummary> getReportSummary(String userId, DateTime startDate, DateTime endDate) async {
    // Get all transactions in period
    final response = await supabase
        .from('transactions')
        .select('*, categories(*)')
        .eq('user_id', userId)
        .gte('transaction_date', startDate.toIso8601String())
        .lte('transaction_date', endDate.toIso8601String());

    final transactions = response as List;

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      final amount = (transaction['amount'] as num).toDouble();
      final type = transaction['type'] as String;
      final categoryName = transaction['categories']['name'] as String;

      if (type == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
        categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + amount;
      }
    }

    // Calculate percentages and create category breakdown
    final categoryBreakdown = <String, CategoryReport>{};
    if (totalExpense > 0) {
      categoryTotals.forEach((name, amount) {
        final percentage = ((amount / totalExpense) * 100).round();
        categoryBreakdown[name] = CategoryReport(
          categoryName: name,
          amount: amount,
          percentage: percentage,
        );
      });
    }

    return ReportSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      categoryBreakdown: categoryBreakdown,
    );
  }
}
