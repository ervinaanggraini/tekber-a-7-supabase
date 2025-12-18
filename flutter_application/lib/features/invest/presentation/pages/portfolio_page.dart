import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../widgets/portfolio_card.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PortfolioCubit()..loadPortfolio(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFE91E63)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Portofolio',
            style: GoogleFonts.poppins(
              color: const Color(0xFFE91E63),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: BlocBuilder<PortfolioCubit, PortfolioState>(
          builder: (context, state) {
            if (state is PortfolioLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PortfolioLoaded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TotalCard(
                    totalValue: state.totalValue,
                    percentage: state.totalPercentage ?? 0,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Portofolio',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                  ),
                  ...state.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PortfolioCard(item: item),
                    ),
                  ),
                ],
              );
            }

            if (state is PortfolioError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double totalValue;
  final double percentage;

  const _TotalCard({
    required this.totalValue,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nilai Portofolio',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFFE91E63),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalValue.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]}.',
                    ),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              Text(
                '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: percentage >= 0 ? const Color(0xFF4CAF50) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
