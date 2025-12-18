import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/dependency_injection.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/savings_goal/presentation/cubit/savings_goal_cubit.dart';
import 'package:flutter_application/features/savings_goal/presentation/cubit/savings_goal_state.dart';
import 'package:flutter_application/features/savings_goal/presentation/widgets/savings_goal_card.dart';
import 'package:google_fonts/google_fonts.dart';

class SavingsGoalPage extends StatelessWidget {
  const SavingsGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<SavingsGoalCubit>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthUserAuthenticated) {
          cubit.loadSavingsGoals(authState.user.id);
        }
        return cubit;
      },
      child: const _SavingsGoalPageView(),
    );
  }
}

class _SavingsGoalPageView extends StatelessWidget {
  const _SavingsGoalPageView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tujuan Tabungan',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Tambah Tujuan Tabungan akan segera hadir')),
          );
        },
        backgroundColor: AppColors.b93160,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<SavingsGoalCubit, SavingsGoalState>(
        builder: (context, state) {
          if (state is SavingsGoalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SavingsGoalError) {
            return Center(child: Text(state.message));
          } else if (state is SavingsGoalLoaded) {
            if (state.goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.track_changes_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tujuan tabungan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat tujuan untuk mewujudkan impianmu',
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
              itemCount: state.goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final goal = state.goals[index];
                return SavingsGoalCard(
                  goal: goal,
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
