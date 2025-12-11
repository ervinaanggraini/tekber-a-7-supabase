import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacings.dart';
import '../../../../dependency_injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/reports_cubit.dart';
import '../utils/report_pdf_generator.dart';
import '../utils/report_export_generator.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<ReportsCubit>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthUserAuthenticated) {
          cubit.loadReport(authState.user.id, ReportPeriod.month);
        }
        return cubit;
      },
      child: const _ReportsPageView(),
    );
  }
}

class _ReportsPageView extends StatelessWidget {
  const _ReportsPageView();

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted,-';
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
          'Laporan Keuangan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.pink[200] : AppColors.b93160,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.pink[200] : AppColors.b93160),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReportsError) {
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

            if (state is! ReportsLoaded) {
              return const SizedBox();
            }

            final summary = state.summary;
            final sortedCategories = summary.categoryBreakdown.values.toList()
              ..sort((a, b) => b.amount.compareTo(a.amount));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.s16),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.s16),
                decoration: BoxDecoration(
                  gradient: AppColors.linier,
                  borderRadius: BorderRadius.circular(16),
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
                      'Periode Laporan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthUserAuthenticated) {
                              context.read<ReportsCubit>().loadReport(authState.user.id, ReportPeriod.week);
                            }
                          },
                          child: _PeriodButton(label: 'Minggu', isSelected: state.selectedPeriod == ReportPeriod.week, isDark: isDark),
                        ),
                        GestureDetector(
                          onTap: () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthUserAuthenticated) {
                              context.read<ReportsCubit>().loadReport(authState.user.id, ReportPeriod.month);
                            }
                          },
                          child: _PeriodButton(label: 'Bulan', isSelected: state.selectedPeriod == ReportPeriod.month, isDark: isDark),
                        ),
                        GestureDetector(
                          onTap: () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthUserAuthenticated) {
                              context.read<ReportsCubit>().loadReport(authState.user.id, ReportPeriod.year);
                            }
                          },
                          child: _PeriodButton(label: 'Tahun', isSelected: state.selectedPeriod == ReportPeriod.year, isDark: isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: Spacing.s24),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Pemasukan',
                      amount: _formatCurrency(summary.totalIncome),
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Pengeluaran',
                      amount: _formatCurrency(summary.totalExpense),
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.s16),
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
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: isDark ? Colors.pink[200] : AppColors.b93160,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                      Text(
                        'Saldo Akhir',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(summary.balance),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.pink[200] : AppColors.b93160,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: Spacing.s24),
              
              // Category Breakdown
              Text(
                'Pengeluaran per Kategori',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.pink[200] : AppColors.b93160,
                ),
              ),
              
              const SizedBox(height: Spacing.s16),
              
              Container(
                padding: const EdgeInsets.all(Spacing.s16),
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
                  children: [
                    if (sortedCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(Spacing.s24),
                        child: Text(
                          'Belum ada data pengeluaran',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      ...sortedCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final categoryReport = entry.value;
                        final colors = [Colors.orange, Colors.blue, Colors.purple, Colors.pink, Colors.teal];
                        
                        return Column(
                          children: [
                            if (index > 0) const SizedBox(height: 12),
                            _CategoryItem(
                              name: categoryReport.categoryName,
                              amount: _formatCurrency(categoryReport.amount),
                              percentage: categoryReport.percentage.toInt(),
                              color: colors[index % colors.length],
                            ),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: Spacing.s24),
              
              // Export Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    String periodLabel;
                    switch (state.selectedPeriod) {
                      case ReportPeriod.week:
                        periodLabel = 'Minggu Ini';
                        break;
                      case ReportPeriod.month:
                        periodLabel = 'Bulan Ini';
                        break;
                      case ReportPeriod.year:
                        periodLabel = 'Tahun Ini';
                        break;
                    }

                    // Show chooser for PDF or Excel
                    final choice = await showModalBottomSheet<String?>(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: const Text('PDF'),
                              onTap: () => Navigator.of(ctx).pop('pdf'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.table_chart),
                              title: const Text('Excel'),
                              onTap: () => Navigator.of(ctx).pop('excel'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.close),
                              title: const Text('Batal'),
                              onTap: () => Navigator.of(ctx).pop(null),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (choice == 'pdf') {
                      await ReportPdfGenerator.generateAndSharePdf(summary, periodLabel);
                    } else if (choice == 'excel') {
                      await ReportExportGenerator.generateAndShareExcel(summary, periodLabel);
                    }
                  },
                  icon: const Icon(Icons.file_upload, color: Colors.white),
                  label: Text(
                    'Export Laporan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.pink[300] : AppColors.b93160,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: (isDark ? Colors.pink[300]! : AppColors.b93160).withOpacity(0.4),
                  ),
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

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? (isDark ? Colors.pink[300] : AppColors.b93160) : Colors.white,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String amount;
  final int percentage;
  final Color color;

  const _CategoryItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.pink[200] : AppColors.b93160,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
