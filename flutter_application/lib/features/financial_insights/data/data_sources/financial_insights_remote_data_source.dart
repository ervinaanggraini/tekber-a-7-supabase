import 'package:flutter_application/features/financial_insights/data/models/financial_insight_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FinancialInsightsRemoteDataSource {
  Future<List<FinancialInsightModel>> getFinancialInsights(String userId);
  Future<void> markAsRead(String insightId);
}

@LazySingleton(as: FinancialInsightsRemoteDataSource)
class FinancialInsightsRemoteDataSourceImpl implements FinancialInsightsRemoteDataSource {
  final SupabaseClient supabaseClient;

  FinancialInsightsRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<FinancialInsightModel>> getFinancialInsights(String userId) async {
    final response = await supabaseClient
        .from('financial_insights')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => FinancialInsightModel.fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(String insightId) async {
    await supabaseClient
        .from('financial_insights')
        .update({'is_read': true})
        .eq('id', insightId);
  }
}
