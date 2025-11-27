import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_application/features/transactions/data/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10});
  Future<Map<String, double>> getCashflowData();
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
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
  Future<Map<String, double>> getCashflowData() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get all transactions for current month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final response = await supabaseClient
          .from('transactions')
          .select('type, amount')
          .eq('user_id', userId)
          .gte('transaction_date', firstDayOfMonth.toIso8601String().split('T')[0])
          .lte('transaction_date', lastDayOfMonth.toIso8601String().split('T')[0]);

      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in response as List) {
        final amount = (transaction['amount'] as num).toDouble();
        if (transaction['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': totalIncome - totalExpense,
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

      return TransactionModel.fromJson(response as Map<String, dynamic>);
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
}
