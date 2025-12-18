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
// import 'package:flutter_application/features/invest/presentation/pages/invest_page.dart';
import 'package:flutter_application/features/transaction/presentation/pages/transaction_history_page.dart';
import 'package:flutter_application/dependency_injection.dart';

// Import Screen Misi
// Pastikan path ini sesuai dengan struktur foldermu (screen vs screens)
import 'package:flutter_application/features/gamification/screen/mission_screen.dart';

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
                      const Icon(Icons.cloud_off_outlined, size: 60, color: Colors.red),
                      const SizedBox(height: 24),
                      Text(
                        'Gagal Memuat Data',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<HomeCubit>().refreshHomeData(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
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
                    // --- HEADER (Halo User + Misi + Profile) ---
                    Padding(
                      padding: const EdgeInsets.all(Spacing.s16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Kiri: Halo + Email
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
                                  return const Text("User");
                                },
                              ),
                            ],
                          ),
                          
                          // Kanan: Tombol Misi & Profil
                          Row(
                            children: [
                              // 1. TOMBOL MISI (Kecil, Icon Saja)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MissionScreen()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.15), // Background kuning transparan
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.stars_rounded, // Icon Bintang
                                    color: Colors.amber, 
                                    size: 26,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 12), // Jarak antara Misi dan Profil

                              // 2. TOMBOL PROFIL
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                                  );
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.b93160,
                                  child: Icon(Icons.person, color: Colors.white, size: 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // --- CASHFLOW CARD ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.s16),
                        decoration: BoxDecoration(
                          gradient: isDark ? null : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF8BBD0), Color(0xFFFFCCBC), Color(0xFFFFF9C4)],
                          ),
                          color: isDark ? Colors.grey[850] : null,
                          borderRadius: BorderRadius.circular(20),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.pink[300] : AppColors.b93160,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Cashflow",
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        final current = state.selectedMonth;
                                        context.read<HomeCubit>().changeMonth(DateTime(current.year, current.month - 1));
                                      },
                                      icon: const Icon(Icons.chevron_left),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    Text(
                                      _getMonthYearText(state.selectedMonth),
                                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final current = state.selectedMonth;
                                        final now = DateTime.now();
                                        if (current.year < now.year || (current.year == now.year && current.month < now.month)) {
                                          context.read<HomeCubit>().changeMonth(DateTime(current.year, current.month + 1));
                                        }
                                      },
                                      icon: const Icon(Icons.chevron_right),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.s16),
                            Text(
                              cashflow != null ? formatCurrency(cashflow.balance) : "Rp0,-",
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.pink[200] : AppColors.b93160,
                              ),
                            ),
                            const SizedBox(height: Spacing.s16),
                            Row(
                              children: [
                                _buildSummaryItem(context, "Pengeluaran", cashflow?.totalExpense ?? 0, cashflow?.expensePercentage ?? 0, Icons.arrow_upward, Colors.red),
                                const SizedBox(width: 8),
                                _buildSummaryItem(context, "Pemasukan", cashflow?.totalIncome ?? 0, cashflow?.incomePercentage ?? 0, Icons.arrow_downward, Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),
                    
                    // --- MENU ICONS (BALIK JADI 4 ITEM) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MenuIcon(icon: Icons.chat_bubble_outline, label: "AI Chat", onTap: () => context.pushNamed(Routes.chat.name)),
                          _MenuIcon(icon: Icons.description_outlined, label: "Report", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage()))),
                          _MenuIcon(icon: Icons.analytics_outlined, label: "Analytics", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsPage()))),
                        //  _MenuIcon(icon: Icons.savings_outlined, label: "Invest", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestPage()))),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),
                    
                    // --- TRANSAKSI TERAKHIR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transaksi Terakhir", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.pink[200] : AppColors.b93160)),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryPage())),
                            child: Text('Lihat Semua', style: GoogleFonts.poppins(color: isDark ? Colors.pink[200] : AppColors.b93160)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.s16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: transactions.isEmpty
                            ? Padding(padding: const EdgeInsets.all(Spacing.s24), child: Center(child: Text("Belum ada transaksi", style: GoogleFonts.poppins(color: Colors.grey))))
                            : Column(children: transactions.take(3).map((transaction) { 
                                  final isIncome = transaction.type == 'income';
                                  return ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                                      child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red, size: 20),
                                    ),
                                    title: Text(transaction.category.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    subtitle: Text(transaction.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                                    trailing: Text(formatCurrency(transaction.amount), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red)),
                                  );
                                }).toList()),
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.s24),

                    // --- BERITA TERBARU (GAMBAR ADARO) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: Row(
                        children: [
                          Text(
                            "Berita terbaru",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.pink[200] : AppColors.b93160,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.s16),
                    
                    // CARD BERITA BESAR (Bawah)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
                      child: GestureDetector(
                        onTap: () {
                          // Klik berita --> Masuk ke InvestPage
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestPage()));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[800],
                            image: const DecorationImage(
                              // Gambar Tambang (Adaro vibes)
                              image: NetworkImage("https://img.IDXChannel.com/images/idx/2024/10/25/adaro_energy.jpg"), 
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Gradient Overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                                  ),
                                ),
                              ),
                              // Teks Berita
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 70,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "AADI vs ADRO",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Batu Bara atau Energi Terbarukan, Mana Lebih Menarik?",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol Plus Pink
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: AppColors.b93160,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount, double percentage, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.15) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: isDark ? color.withOpacity(0.7) : color, size: 16), const SizedBox(width: 4), Text(label, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? color.withOpacity(0.7) : color))]),
            const SizedBox(height: 4),
            Text("• ${formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)", style: GoogleFonts.poppins(fontSize: 11, color: isDark ? color.withOpacity(0.7) : color)),
          ],
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isDark ? null : AppColors.linier,
                color: isDark ? Colors.grey[800] : null,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}