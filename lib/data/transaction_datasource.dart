// file: transaction_data_source.dart

import 'package:dio/dio.dart';
import 'package:moneyvesto/core/services/DioService.dart';

// Abstract class (Interface)
abstract class TransactionDataSource {
  Future<Response> createTransaction(Map<String, dynamic> data);
  Future<Response> getTransactions({int page, int size, String order});
  Future<Response> getTransactionById(String id);
  Future<Response> updateTransaction(String id, Map<String, dynamic> data);
  Future<Response> deleteTransaction(String id);
  Future<Map<String, double>> calculateExpensesAndDeposits();
}

class TransactionDataSourceImpl implements TransactionDataSource {
  final Dio _dio = DioService().dio;

  @override
  Future<Response> createTransaction(Map<String, dynamic> data) async {
    return await _dio.post('/transactions', data: data);
  }

  @override
  Future<Response> getTransactions({
    int page = 1,
    int size = 100,
    String order = 'asc',
  }) async {
    return await _dio.get(
      '/transactions',
      queryParameters: {'page': page, 'size': size, 'order': order},
    );
  }

  @override
  Future<Response> getTransactionById(String id) async {
    return await _dio.get('/transactions/$id');
  }

  @override
  Future<Response> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _dio.put('/transactions/$id', data: data);
  }

  @override
  Future<Response> deleteTransaction(String id) async {
    return await _dio.delete('/transactions/$id');
  }

  @override
  Future<Map<String, double>> calculateExpensesAndDeposits() async {
    try {
      final response = await getTransactions(size: 1000);

      double totalExpenses = 0.0;
      double totalDeposits = 0.0;

      if (response.statusCode == 200 && response.data['data'] != null) {
        List<dynamic> transactions = response.data['data'];

        for (var transaction in transactions) {
          final String type = transaction['transaction_type'];
          final double price = (transaction['total_price'] as num).toDouble();

          if (type == 'withdrawal') {
            totalExpenses += price;
          } else if (type == 'deposit') {
            totalDeposits += price;
          }
        }
      }

      return {'total_expenses': totalExpenses, 'total_deposits': totalDeposits};
    } catch (e) {
      print('Error calculating expenses and deposits: $e');
      return {'total_expenses': 0.0, 'total_deposits': 0.0};
    }
  }
}
