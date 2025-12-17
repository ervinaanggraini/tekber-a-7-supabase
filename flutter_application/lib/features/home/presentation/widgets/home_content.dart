import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import 'package:flutter_application/core/router/routes.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/home/presentation/bloc/home/home_cubit.dart';
import 'package:flutter_application/features/profile/presentation/page/profile_page.dart';
import 'package:flutter_application/features/home/presentation/widgets/home_skeleton_loading.dart';
import 'package:flutter_application/features/transactions/presentation/cubit/add_transaction_cubit.dart';
import 'package:flutter_application/features/transactions/presentation/widgets/add_transaction_dialog.dart';
import 'package:flutter_application/features/reports/presentation/page/reports_page.dart';
import 'package:flutter_application/features/analytics/presentation/page/analytics_page.dart';
import 'package:flutter_application/features/invest/presentation/pages/invest_page.dart';
import 'package:flutter_application/features/transaction/presentation/pages/transaction_history_page.dart';
import 'package:flutter_application/dependency_injection.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadHomeData(),
      child: const _HomeContentView(),
    );
  }
}

class _HomeContentView extends StatelessWidget {
  const _HomeContentView();

  Future<void> _showAddTransactionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => getIt<AddTransactionCubit>(),
        child: const AddTransactionDialog(),
      ),
    );

    // Refresh home data if transaction was added successfully
    if (result == true && context.mounted) {
      context.read<HomeCubit>().loadHomeData();
    }
  }

  String formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted,-';
  }

  String _getMonthYearText(DateTime date) {
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: AppColors.b93160,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading && state.cashflowSummary == null) {
              return const HomeSkeletonLoading();
            }

            if (state.status == HomeStatus.error && state.cashflowSummary == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_off_outlined,
                          size: 60,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Gagal Memuat Data',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terjadi kesalahan saat memuat data.\nPastikan koneksi internet Anda stabil.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<HomeCubit>().refreshHomeData(),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.b93160,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cashflow = state.cashflowSummary;
            final transactions = state.recentTransactions;

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(Spacing.s16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo!",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.pink[200] : AppColors.b93160,
                                ),
                              ),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, authState) {
                                  if (authState is AuthUserAuthenticated) {
                                    return Text(
                                      authState.user.email,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    );
                                  }
                                  return Text(
                                    "User",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.b93160,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Cashflow Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.s16),
                        decoration: BoxDecoration(
                          gradient: isDark ? null : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF8BBD0),
                              Color(0xFFFFCCBC),
                              Color(0xFFFFF9C4),
                            ],
                          ),
                          color: isDark ? Colors.grey[850] : null,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.pink[300] : AppColors.b93160,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Cashflow",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Month selector
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        final currentMonth = state.selectedMonth;
                                        final previousMonth = DateTime(
                                          currentMonth.year,
                                          currentMonth.month - 1,
                                        );
                                        context.read<HomeCubit>().changeMonth(previousMonth);
                                      },
                                      icon: Icon(Icons.chevron_left, color: isDark ? Colors.pink[200] : AppColors.b93160),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    Text(
                                      _getMonthYearText(state.selectedMonth),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.pink[200] : AppColors.b93160,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final currentMonth = state.selectedMonth;
                                        final now = DateTime.now();
                                        // Prevent going to future months
                                        if (currentMonth.year < now.year || 
                                            (currentMonth.year == now.year && currentMonth.month < now.month)) {
                                          final nextMonth = DateTime(
                                            currentMonth.year,
                                            currentMonth.month + 1,
                                          );
                                          context.read<HomeCubit>().changeMonth(nextMonth);
                                        }
                                      },
                                      icon: Icon(Icons.chevron_right, color: isDark ? Colors.pink[200] : AppColors.b93160),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.s16),
                            Text(
                              cashflow != null 
                                  ? formatCurrency(cashflow.balance) 
                                  : "Rp0,-",
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.pink[200] : AppColors.b93160,
                              ),
                            ),
                            const SizedBox(height: Spacing.s16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.red.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_upward,
                                              color: isDark ? Colors.red[300] : Colors.red,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Pengeluaran",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: isDark ? Colors.red[300] : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cashflow != null
                                              ? "• ${formatCurrency(cashflow.totalExpense)} (${cashflow.expensePercentage.toStringAsFixed(1)}%)"
                                              : "• Rp0 (0.0%)",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: isDark ? Colors.red[200] : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.green.withOpacity(0.15) : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_downward,
                                              color: isDark ? Colors.green[300] : Colors.green,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Pemasukan",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: isDark ? Colors.green[300] : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cashflow != null
                                              ? "• ${formatCurrency(cashflow.totalIncome)} (${cashflow.incomePercentage.toStringAsFixed(1)}%)"
                                              : "• Rp0 (0.0%)",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: isDark ? Colors.green[200] : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),
                    
                    // Menu Icons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MenuIcon(
                            icon: Icons.chat_bubble_outline,
                            label: "AI Chat",
                            onTap: () {
                              context.pushNamed(Routes.chat.name);
                            },
                          ),
                          _MenuIcon(
                            icon: Icons.description_outlined,
                            label: "Report",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportsPage(),
                                ),
                              );
                            },
                          ),
                          _MenuIcon(
                            icon: Icons.analytics_outlined,
                            label: "Analytics",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AnalyticsPage(),
                                ),
                              );
                            },
                          ),
                          _MenuIcon(
                            icon: Icons.savings_outlined,
                            label: "Invest",
                            onTap: () {
                              Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (_) => const InvestPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),
                    
                    // Transaksi Terakhir
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transaksi Terakhir",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.pink[200] : AppColors.b93160,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TransactionHistoryPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Lihat Semua',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.pink[200] : AppColors.b93160,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.s16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: transactions.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(Spacing.s24),
                                child: Center(
                                  child: Text(
                                    "Belum ada transaksi",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: transactions.take(5).map((transaction) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: transaction.type == 'income'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          transaction.type == 'income'
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: transaction.type == 'income'
                                              ? Colors.green
                                              : Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        transaction.category.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      subtitle: transaction.description != null && transaction.description!.isNotEmpty
                                          ? Text(
                                              transaction.description!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: isDark ? Colors.white70 : Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : null,
                                      trailing: Text(
                                        formatCurrency(transaction.amount),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: transaction.type == 'income'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),
                    
                    // Berita Terbaru
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Text(
                        "Berita terbaru",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.pink[200] : AppColors.b93160,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF8BBD0),
                              Color(0xFFFFCCBC),
                              Color(0xFFFFF9C4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: isDark ? null : AppColors.linier,
              color: isDark ? Colors.grey[800] : null,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
