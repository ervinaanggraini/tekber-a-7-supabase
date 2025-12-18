import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Import Core
import 'package:flutter_application/core/router/routes.dart';
import 'package:flutter_application/core/constants/app_colors.dart';

// Import Features
import 'package:flutter_application/features/invest/data/data_source/invest_remote_data_source.dart';
import 'package:flutter_application/features/invest/data/repositories/invest_repository_impl.dart';
import 'package:flutter_application/features/invest/presentation/cubit/invest_cubit.dart';
import 'package:flutter_application/features/invest/presentation/cubit/invest_state.dart';
import 'package:flutter_application/features/invest/presentation/widgets/stock_card.dart';

// Jika EducationPage sudah ada, bisa di-uncomment
// import 'package:flutter_application/features/invest/presentation/pages/education_page.dart'; 

class InvestPage extends StatelessWidget {
  const InvestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      // Inisialisasi Cubit dengan Repository & Data Source
      create: (_) => InvestCubit(
        InvestRepositoryImpl(
          InvestRemoteDataSourceImpl(),
        ),
      )..loadStocks(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],

          // ================= APP BAR =================
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.b93160),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              'Investasi',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.b93160,
              ),
            ),

            // TOMBOL PORTOFOLIO
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () {
                    context.pushNamed(Routes.portfolio.name);
                  },
                  icon: const Icon(
                    Icons.pie_chart_outline,
                    size: 18,
                    color: AppColors.b93160,
                  ),
                  label: Text(
                    'Portofolio',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.b93160,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],

            // TAB BAR (Simulasi & Edukasi)
            bottom: TabBar(
              labelColor: AppColors.b93160,
              unselectedLabelColor: Colors.grey[400],
              indicatorColor: AppColors.b93160,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Simulasi Pasar'),
                Tab(text: 'Materi Edukasi'),
              ],
            ),
          ),

          // ================= BODY =================
          body: const TabBarView(
            children: [
              // TAB 1: Simulasi Pasar
              _MarketSimulationTab(),

              // TAB 2: Materi Edukasi (Placeholder)
              // Kalau EducationPage sudah siap, ganti widget di bawah ini dengan EducationPage()
              Center(
                child: Text(
                  'Materi Edukasi akan muncul di sini',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= WIDGET: TAB SIMULASI PASAR =================

class _MarketSimulationTab extends StatelessWidget {
  const _MarketSimulationTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestCubit, InvestState>(
      builder: (context, state) {
        if (state is InvestLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is InvestLoaded) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Pasar Simulasi',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.b93160,
                ),
              ),
              const SizedBox(height: 16),

              // Breaking News Card
              const _BreakingNewsCard(),
              const SizedBox(height: 20),

              // List Saham
              ...state.stocks.map(
                (stock) => StockCard(stock: stock),
              ),
            ],
          );
        }

        if (state is InvestError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }
}

// ================= WIDGET: BREAKING NEWS CARD =================

class _BreakingNewsCard extends StatelessWidget {
  const _BreakingNewsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            'BREAKING NEWS :',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.b93160,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saham Teknologi Melonjak Setelah Raksasa Teknologi Umumkan Kuartal yang Kuat',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keuntungan yang lebih tinggi dari perkiraan dan prospek yang kuat '
            'mendorong investor untuk memborong saham teknologi',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}