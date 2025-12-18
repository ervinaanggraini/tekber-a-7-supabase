import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import '../../data/savings_goals_service.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsGoalsPage extends StatefulWidget {
  const SavingsGoalsPage({super.key});

  @override
  State<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends State<SavingsGoalsPage> {
  final _service = SavingsGoalsService();
  List<SavingsGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _service.fetchGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? const Center(child: Text('Belum ada target tabungan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(Spacing.s16),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];

                    // ⛳ dummy progress (akan diganti step 4)
                    const double progress = 0.3;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.s16),
                      child: SavingsGoalCard(
                        targetAmount: goal.targetAmount,
                        progress: progress,
                        deadline:
                            '${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                      ),
                    );
                  },
                ),
    );
  }
}

class SavingsGoalCard extends StatelessWidget {
  final double targetAmount;
  final double progress;
  final String deadline;

  const SavingsGoalCard({
    super.key,
    required this.targetAmount,
    required this.progress,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(Spacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Tabungan',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            'Rp ${targetAmount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.s12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              isCompleted ? Colors.green : AppColors.b93160,
            ),
          ),
          const SizedBox(height: Spacing.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% tercapai'),
              Text(isCompleted ? 'Completed' : 'Deadline: $deadline'),
            ],
          )
        ],
      ),
    );
  }
}