import 'package:dio/dio.dart';
import 'package:moneyvesto/core/services/endpoints.dart';
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart';

class InvestDataSource {
  final Dio _dio = Dio();
  final SharedPreferencesUtils _prefs = SharedPreferencesUtils();

  Future<Response> getPortfolio() async {
    try {
      final token = _prefs.token;
      final response = await _dio.get(
        '${Endpoints.baseUrl}/invest/portfolio',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> buyAsset({
    required String assetCode,
    required String assetName,
    required double quantity,
    required double price,
  }) async {
    try {
      final token = _prefs.token;
      final response = await _dio.post(
        '${Endpoints.baseUrl}/invest/buy',
        data: {
          'asset_code': assetCode,
          'asset_name': assetName,
          'quantity': quantity,
          'price': price,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sellAsset({
    required String assetCode,
    required double quantity,
    required double price,
  }) async {
    try {
      final token = _prefs.token;
      final response = await _dio.post(
        '${Endpoints.baseUrl}/invest/sell',
        data: {
          'asset_code': assetCode,
          'quantity': quantity,
          'price': price,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
