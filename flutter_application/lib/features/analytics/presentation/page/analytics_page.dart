import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacings.dart';
import '../../../../dependency_injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/analytics_summary.dart';
import '../cubit/analytics_cubit.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<AnalyticsCubit>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthUserAuthenticated) {
          cubit.loadAnalytics(authState.user.id);
        }
        return cubit;
      },
      child: const _AnalyticsPageView(),
    );
  }
}

class _AnalyticsPageView extends StatelessWidget {
  const _AnalyticsPageView();

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted,-';
  }

  void _showEditGoalDialog(BuildContext context, SavingsGoal currentGoal) {
    final targetController = TextEditingController(
      text: currentGoal.target.toStringAsFixed(0),
    );
    DateTime selectedDate = DateTime.now().add(const Duration(days: 365));
    
    // Get cubit and auth before dialog
    final cubit = context.read<AnalyticsCubit>();
    final authState = context.read<AuthBloc>().state;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Edit Target Tabungan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Deadline: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(targetController.text) ?? 0;
                if (amount > 0 && authState is AuthUserAuthenticated) {
                  cubit.updateSavingsGoal(
                    authState.user.id,
                    amount,
                    selectedDate,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.b93160,
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analisis Keuangan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.b93160,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.b93160),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AnalyticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            if (state is! AnalyticsLoaded) {
              return const SizedBox();
            }

            final summary = state.summary;

            return SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Financial Score
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.s24),
                decoration: BoxDecoration(
                  gradient: AppColors.linier,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ffb4c2.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Skor Kesehatan Keuangan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: summary.financialHealthScore / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${summary.financialHealthScore}',
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Baik',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Keuanganmu dalam kondisi baik!\nPertahankan kebiasaan menabung.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: Spacing.s24),
              
              // Spending Trend
              Text(
                'Tren Pengeluaran',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.b93160,
                ),
              ),
              
              const SizedBox(height: Spacing.s16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: summary.monthlyTrends.asMap().entries.map((entry) {
                    final index = entry.key;
                    final trend = entry.value;
                    final previousTrend = index > 0 ? summary.monthlyTrends[index - 1] : null;
                    
                    // Calculate percentage change
                    int change = 0;
                    bool isIncrease = true;
                    if (previousTrend != null && previousTrend.expense > 0) {
                      final diff = trend.expense - previousTrend.expense;
                      change = ((diff / previousTrend.expense) * 100).abs().toInt();
                      isIncrease = diff < 0; // Less expense is increase in savings
                    }
                    
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 24),
                        _TrendItem(
                          month: trend.month,
                          amount: _formatCurrency(trend.expense),
                          change: change,
                          isIncrease: isIncrease,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: Spacing.s24),
              
              // Insights
              Text(
                'Wawasan Keuangan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.b93160,
                ),
              ),
              
              const SizedBox(height: Spacing.s16),
              
              ...summary.insights.map((insight) {
                Color color;
                IconData icon;
                switch (insight.type) {
                  case InsightType.success:
                    color = Colors.green;
                    icon = Icons.trending_up;
                    break;
                  case InsightType.warning:
                    color = Colors.orange;
                    icon = Icons.warning_amber_rounded;
                    break;
                  case InsightType.info:
                    color = Colors.blue;
                    icon = Icons.lightbulb_outline;
                    break;
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InsightCard(
                    icon: icon,
                    color: color,
                    title: insight.title,
                    description: insight.description,
                    isDark: isDark,
                  ),
                );
              }).toList(),
              
              const SizedBox(height: Spacing.s24),
              
              // Savings Goal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target Tabungan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.b93160,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.b93160, size: 20),
                    onPressed: () => _showEditGoalDialog(context, summary.savingsGoal),
                  ),
                ],
              ),
              
              const SizedBox(height: Spacing.s16),
              
              Container(
                padding: const EdgeInsets.all(Spacing.s16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Tabungan',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Target: ${_formatCurrency(summary.savingsGoal.target)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.b93160.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(summary.savingsGoal.progress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.b93160,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: summary.savingsGoal.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.b93160),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terkumpul: ${_formatCurrency(summary.savingsGoal.current)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Sisa: ${_formatCurrency(summary.savingsGoal.target - summary.savingsGoal.current)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.b93160,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
          },
        ),
      ),
    );
  }
}

class _TrendItem extends StatelessWidget {
  final String month;
  final String amount;
  final int change;
  final bool isIncrease;

  const _TrendItem({
    required this.month,
    required this.amount,
    required this.change,
    required this.isIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              month,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.b93160,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isIncrease 
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isIncrease ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '${change.abs()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isIncrease ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool isDark;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.s16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
