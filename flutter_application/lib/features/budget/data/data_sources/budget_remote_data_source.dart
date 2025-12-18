import 'package:flutter_application/features/budget/data/models/budget_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets(String userId);
  Future<void> createBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String budgetId);
}

@LazySingleton(as: BudgetRemoteDataSource)
class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final SupabaseClient supabaseClient;

  BudgetRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<BudgetModel>> getBudgets(String userId) async {
    final response = await supabaseClient
        .from('budgets')
        .select('*, categories(*)')
        .eq('user_id', userId);

    final List<dynamic> data = response as List<dynamic>;
    final List<BudgetModel> budgets = [];

    for (var item in data) {
      final budget = BudgetModel.fromJson(item);
      
      // Calculate spent amount
      var query = supabaseClient
          .from('transactions')
          .select('amount')
          .eq('user_id', userId)
          .eq('type', 'expense')
          .gte('date', budget.startDate.toIso8601String())
          .lte('date', budget.endDate.toIso8601String());
      
      if (budget.categoryId != null) {
        query = query.eq('category_id', budget.categoryId!);
      }

      final transactionsResponse = await query;
      final transactions = transactionsResponse as List<dynamic>;
      
      double spent = 0;
      for (var t in transactions) {
        spent += (t['amount'] as num).toDouble();
      }

      budgets.add(BudgetModel(
        id: budget.id,
        userId: budget.userId,
        categoryId: budget.categoryId,
        category: budget.category,
        name: budget.name,
        amount: budget.amount,
        spentAmount: spent,
        period: budget.period,
        startDate: budget.startDate,
        endDate: budget.endDate,
        alertThreshold: budget.alertThreshold,
        isActive: budget.isActive,
      ));
    }

    return budgets;
  }

  @override
  Future<void> createBudget(BudgetModel budget) async {
    await supabaseClient.from('budgets').insert(budget.toJson());
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    await supabaseClient
        .from('budgets')
        .update(budget.toJson())
        .eq('id', budget.id);
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    await supabaseClient.from('budgets').delete().eq('id', budgetId);
  }
}
