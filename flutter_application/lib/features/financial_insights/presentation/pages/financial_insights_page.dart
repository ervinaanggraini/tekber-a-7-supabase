import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/financial_insights/presentation/cubit/financial_insights_cubit.dart';
import 'package:flutter_application/features/financial_insights/presentation/cubit/financial_insights_state.dart';
import 'package:flutter_application/features/financial_insights/presentation/widgets/insight_card.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinancialInsightsPage extends StatelessWidget {
  const FinancialInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view insights')),
      );
    }

    return BlocProvider(
      create: (context) => GetIt.I<FinancialInsightsCubit>()..loadInsights(userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Financial Insights'),
        ),
        body: BlocBuilder<FinancialInsightsCubit, FinancialInsightsState>(
          builder: (context, state) {
            if (state is FinancialInsightsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FinancialInsightsLoaded) {
              if (state.insights.isEmpty) {
                return const Center(child: Text('No insights available yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.insights.length,
                itemBuilder: (context, index) {
                  return InsightCard(insight: state.insights[index]);
                },
              );
            } else if (state is FinancialInsightsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
