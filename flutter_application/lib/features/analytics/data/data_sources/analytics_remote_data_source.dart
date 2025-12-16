import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/analytics_summary.dart';
import 'package:intl/intl.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsSummary> getAnalyticsSummary(String userId);
  Future<void> updateSavingsGoal(String userId, double targetAmount, DateTime deadline);
}

@LazySingleton(as: AnalyticsRemoteDataSource)
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final SupabaseClient supabase;

  AnalyticsRemoteDataSourceImpl(this.supabase);

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String userId) async {
    // Get last 6 months data
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    
    final response = await supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .gte('transaction_date', sixMonthsAgo.toIso8601String())
        .order('transaction_date', ascending: true);

    final transactions = response as List<dynamic>;

    print('📊 Analytics: Loaded ${transactions.length} transactions from ${sixMonthsAgo.toString().split(' ')[0]} to ${now.toString().split(' ')[0]}');

    // Calculate monthly trends
    final monthlyData = <String, Map<String, double>>{};
    for (var i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      final monthKey = DateFormat('MMM').format(month);
      monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
    }

    for (var transaction in transactions) {
      final date = DateTime.parse(transaction['transaction_date']);
      final monthKey = DateFormat('MMM').format(date);
      final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
      final type = transaction['type'] as String?;
      final isIncome = type == 'income';

      if (monthlyData.containsKey(monthKey)) {
        if (isIncome) {
          monthlyData[monthKey]!['income'] = monthlyData[monthKey]!['income']! + amount;
        } else {
          monthlyData[monthKey]!['expense'] = monthlyData[monthKey]!['expense']! + amount;
        }
      }
    }

    final monthlyTrends = monthlyData.entries.map((entry) {
      return MonthlyTrend(
        month: entry.key,
        income: entry.value['income']!,
        expense: entry.value['expense']!,
      );
    }).toList();

    print('📊 Monthly trends:');
    for (var trend in monthlyTrends) {
      print('   ${trend.month}: Income=${trend.income}, Expense=${trend.expense}');
    }

    // Calculate current month data
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthTransactions = transactions.where((t) {
      final date = DateTime.parse(t['transaction_date']);
      return date.isAfter(currentMonthStart) || date.isAtSameMomentAs(currentMonthStart);
    }).toList();

    double currentIncome = 0;
    double currentExpense = 0;
    for (var t in currentMonthTransactions) {
      final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
      final type = t['type'] as String?;
      if (type == 'income') {
        currentIncome += amount;
      } else {
        currentExpense += amount;
      }
    }

    // Calculate financial health score (0-100)
    final savingsRate = currentIncome > 0 ? ((currentIncome - currentExpense) / currentIncome * 100) : 0;
    final healthScore = (savingsRate.clamp(0, 100)).toInt();

    // Generate insights
    final insights = <FinancialInsight>[];
    
    if (savingsRate > 20) {
      insights.add(const FinancialInsight(
        title: 'Pengelolaan Bagus!',
        description: 'Tingkat tabungan Anda sangat baik. Pertahankan!',
        type: InsightType.success,
      ));
    } else if (savingsRate < 10) {
      insights.add(const FinancialInsight(
        title: 'Perhatian!',
        description: 'Pengeluaran Anda tinggi. Coba kurangi pengeluaran tidak penting.',
        type: InsightType.warning,
      ));
    }

    if (currentExpense > currentIncome) {
      insights.add(const FinancialInsight(
        title: 'Defisit Anggaran',
        description: 'Pengeluaran melebihi pemasukan bulan ini.',
        type: InsightType.warning,
      ));
    }

    insights.add(const FinancialInsight(
      title: 'Tips Hemat',
      description: 'Cobalah metode 50/30/20: 50% kebutuhan, 30% keinginan, 20% tabungan.',
      type: InsightType.info,
    ));

    // Savings goal based on actual data
    final totalIncome = transactions
        .where((t) => (t['type'] as String?) == 'income')
        .fold<double>(0, (sum, t) => sum + ((t['amount'] as num?)?.toDouble() ?? 0.0));
    
    final totalExpense = transactions
        .where((t) => (t['type'] as String?) != 'income')
        .fold<double>(0, (sum, t) => sum + ((t['amount'] as num?)?.toDouble() ?? 0.0));
    
    final actualSavings = totalIncome - totalExpense;
    
    // Get user's savings goal from database
    final goalResponse = await supabase
        .from('savings_goals')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    double targetSavings;
    String deadline;
    
    if (goalResponse != null) {
      targetSavings = (goalResponse['target_amount'] as num?)?.toDouble() ?? totalIncome * 0.2;
      deadline = goalResponse['deadline'] as String? ?? DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, 12, 31));
    } else {
      // Default: 20% dari total income
      targetSavings = totalIncome * 0.2;
      if (targetSavings < 1000000) targetSavings = 1000000; // Minimal 1 juta
      deadline = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, 12, 31));
    }
    
    final savingsGoal = SavingsGoal(
      target: targetSavings,
      current: actualSavings > 0 ? actualSavings : 0,
      deadline: DateFormat('dd MMM yyyy').format(DateTime.parse(deadline)),
    );

    return AnalyticsSummary(
      financialHealthScore: healthScore,
      monthlyTrends: monthlyTrends,
      insights: insights,
      savingsGoal: savingsGoal,
    );
  }

  @override
  Future<void> updateSavingsGoal(String userId, double targetAmount, DateTime deadline) async {
    await supabase.from('savings_goals').upsert({
      'user_id': userId,
      'target_amount': targetAmount,
      'deadline': DateFormat('yyyy-MM-dd').format(deadline),
    });
  }
}
