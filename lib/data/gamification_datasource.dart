import 'package:dio/dio.dart';
import 'package:moneyvesto/core/services/dio_service.dart';

abstract class GamificationDataSource {
  Future<Response> getProfile();
  Future<Response> getBadges();
  Future<Response> getMissions();
}

class GamificationDataSourceImpl implements GamificationDataSource {
  final Dio _dio = DioService().dio;

  @override
  Future<Response> getProfile() async {
    return await _dio.get('/gamification/profile');
  }

  @override
  Future<Response> getBadges() async {
    return await _dio.get('/gamification/badges');
  }

  @override
  Future<Response> getMissions() async {
    return await _dio.get('/gamification/missions');
  }
}
