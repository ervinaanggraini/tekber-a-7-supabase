import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/dependency_injection.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:flutter_application/features/budget/presentation/cubit/budget_state.dart';
import 'package:flutter_application/features/budget/presentation/widgets/budget_card.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<BudgetCubit>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthUserAuthenticated) {
          cubit.loadBudgets(authState.user.id);
        }
        return cubit;
      },
      child: const _BudgetPageView(),
    );
  }
}

class _BudgetPageView extends StatelessWidget {
  const _BudgetPageView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Anggaran',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show Add Budget Dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Tambah Budget akan segera hadir')),
          );
        },
        backgroundColor: AppColors.b93160,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BudgetError) {
            return Center(child: Text(state.message));
          } else if (state is BudgetLoaded) {
            if (state.budgets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada anggaran',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat anggaran untuk mengontrol pengeluaranmu',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.budgets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final budget = state.budgets[index];
                return BudgetCard(
                  budget: budget,
                  onEdit: () {
                     // Edit
                  },
                  onDelete: () {
                    // Delete confirmation
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
