import 'package:flutter_application/features/savings_goal/data/models/savings_goal_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SavingsGoalRemoteDataSource {
  Future<List<SavingsGoalModel>> getSavingsGoals(String userId);
  Future<void> createSavingsGoal(SavingsGoalModel goal);
  Future<void> updateSavingsGoal(SavingsGoalModel goal);
  Future<void> deleteSavingsGoal(String goalId);
}

@LazySingleton(as: SavingsGoalRemoteDataSource)
class SavingsGoalRemoteDataSourceImpl implements SavingsGoalRemoteDataSource {
  final SupabaseClient supabaseClient;

  SavingsGoalRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<SavingsGoalModel>> getSavingsGoals(String userId) async {
    final response = await supabaseClient
        .from('savings_goals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => SavingsGoalModel.fromJson(json)).toList();
  }

  @override
  Future<void> createSavingsGoal(SavingsGoalModel goal) async {
    await supabaseClient.from('savings_goals').insert(goal.toJson());
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoalModel goal) async {
    await supabaseClient
        .from('savings_goals')
        .update(goal.toJson())
        .eq('id', goal.id);
  }

  @override
  Future<void> deleteSavingsGoal(String goalId) async {
    await supabaseClient.from('savings_goals').delete().eq('id', goalId);
  }
}
