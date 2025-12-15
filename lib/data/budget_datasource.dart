import 'package:dio/dio.dart';
import 'package:moneyvesto/core/services/dio_service.dart';

abstract class BudgetDataSource {
  Future<Response> createBudget(Map<String, dynamic> data);
  Future<Response> getBudgets();
  Future<Response> updateBudget(String id, Map<String, dynamic> data);
  Future<Response> deleteBudget(String id);
}

class BudgetDataSourceImpl implements BudgetDataSource {
  final Dio _dio = DioService().dio;

  @override
  Future<Response> createBudget(Map<String, dynamic> data) async {
    return await _dio.post('/budgets/', data: data);
  }

  @override
  Future<Response> getBudgets() async {
    return await _dio.get('/budgets/');
  }

  @override
  Future<Response> updateBudget(String id, Map<String, dynamic> data) async {
    return await _dio.put('/budgets/$id', data: data);
  }

  @override
  Future<Response> deleteBudget(String id) async {
    return await _dio.delete('/budgets/$id');
  }
}
