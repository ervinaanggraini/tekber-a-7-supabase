import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_application/features/transactions/data/models/transaction_model.dart';
import 'package:flutter_application/features/transactions/data/models/category_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10});
  Future<Map<String, double>> getCashflowData({DateTime? month});
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<List<CategoryModel>> getCategories({String? type});
}

@LazySingleton(as: TransactionRemoteDataSource)
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient supabaseClient;

  TransactionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabaseClient
          .from('transactions')
          .select('*, category:categories(*)')
          .eq('user_id', userId)
          .order('transaction_date', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<Map<String, double>> getCashflowData({DateTime? month}) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get selected month date range for monthly changes
      final targetMonth = month ?? DateTime.now();
      final firstDayOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
      final lastDayOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0);

      // Get this month's transactions only
      final monthlyTransactions = await supabaseClient
          .from('transactions')
          .select('type, amount')
          .eq('user_id', userId)
          .gte('transaction_date', firstDayOfMonth.toIso8601String().split('T')[0])
          .lte('transaction_date', lastDayOfMonth.toIso8601String().split('T')[0]);

      // Calculate monthly income, expense, and balance
      double monthlyIncome = 0;
      double monthlyExpense = 0;

      for (var transaction in monthlyTransactions as List) {
        final amount = (transaction['amount'] as num).toDouble();
        if (transaction['type'] == 'income') {
          monthlyIncome += amount;
        } else {
          monthlyExpense += amount;
        }
      }

      return {
        'totalIncome': monthlyIncome,
        'totalExpense': monthlyExpense,
        'balance': monthlyIncome - monthlyExpense, // Balance bulan ini saja
      };
    } catch (e) {
      throw Exception('Failed to fetch cashflow data: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = transaction.toJson();
      data['user_id'] = userId;

      final response = await supabaseClient
          .from('transactions')
          .insert(data)
          .select('*, category:categories(*)')
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await supabaseClient
          .from('transactions')
          .delete()
          .eq('id', transactionId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories({String? type}) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      var query = supabaseClient
          .from('categories')
          .select()
          .or('is_system.eq.true,user_id.eq.$userId');

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
