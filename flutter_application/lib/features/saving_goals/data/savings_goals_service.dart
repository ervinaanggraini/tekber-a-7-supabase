import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/savings_goal.dart';

class SavingsGoalsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SavingsGoal>> fetchGoals() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('savings_goals')
        .select()
        .eq('user_id', user.id)
        .order('deadline');

    return (response as List)
        .map((e) => SavingsGoal.fromJson(e))
        .toList();
  }
}