// file: lib/data/auth_datasource.dart

import 'package:dio/dio.dart';
import 'package:moneyvesto/core/services/DioService.dart';
import 'package:moneyvesto/core/services/Endpoints.dart';
// Import utility class Anda
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart';

abstract class AuthDataSource {
  Future<Response> register(String name, String email, String password);
  Future<Response> login(String email, String password);
  Future<Response> getCurrentUser();
  Future<Map<String, dynamic>?> getSavedUser();
  Future<Response> logout();
  Future<bool> isLoggedIn();
  Future<bool> hasSeenOnboarding();
  Future<void> setOnboardingAsSeen();
}

class AuthDataSourceImpl implements AuthDataSource {
  final Dio _dio = DioService().dio;
  // Buat satu instance dari SharedPreferencesUtils
  final SharedPreferencesUtils _prefsUtils = SharedPreferencesUtils();

  @override
  Future<Response> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        Endpoints.register,
        data: {'username': name, 'email': email, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Failed to register: ${e.message}');
    }
  }

  @override
  Future<Response> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        Endpoints.login,
        data: {'identifier': identifier, 'password': password},
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        // Gunakan utils untuk menyimpan token dan status login
        await _prefsUtils.setToken(response.data['access_token']);
        await _prefsUtils.setLoggedIn(true);

        final savedToken = await _prefsUtils.token;
        print('Token saved successfully: $savedToken');
      }

      try {
        print('Login successful, fetching and saving user data...');
        await getCurrentUser(); // Ini akan menyimpan data user
        print('User data fetched and saved successfully.');
      } catch (e) {
        print('Error fetching user data immediately after login: $e');
      }

      return response;
    } on DioException catch (e) {
      throw Exception('Failed to login: ${e.message}');
    }
  }

  @override
  Future<Response> logout() async {
    try {
      final response = await _dio.post(Endpoints.logout);
      // Gunakan utils untuk menghapus token dan status login
      await _prefsUtils.clearToken();
      await _prefsUtils.setLoggedIn(false);
      await _prefsUtils.clearData('currentUser'); // Hapus juga data user
      return response;
    } on DioException catch (e) {
      // Tetap lakukan logout lokal meskipun API gagal
      await _prefsUtils.clearToken();
      await _prefsUtils.setLoggedIn(false);
      await _prefsUtils.clearData('currentUser');
      throw Exception('Failed to logout: ${e.message}');
    }
  }

  @override
  Future<Response> getCurrentUser() async {
    try {
      final response = await _dio.get(Endpoints.currentUser);
      if (response.statusCode == 200 && response.data != null) {
        // Gunakan utils untuk menyimpan data user (sudah dalam bentuk Map)
        await _prefsUtils.saveData(
          'currentUser',
          response.data as Map<String, dynamic>,
        );
      }
      return response;
    } on DioException catch (e) {
      await _prefsUtils.clearData('currentUser');
      throw Exception('Failed to get current user: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getSavedUser() async {
    // Gunakan utils untuk mengambil data user
    return _prefsUtils.getData('currentUser');
  }

  @override
  Future<bool> isLoggedIn() async {
    // Gunakan getter dari utils
    return _prefsUtils.isLoggedIn;
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    // Gunakan getter dari utils
    return _prefsUtils.hasSeenOnboarding;
  }

  @override
  Future<void> setOnboardingAsSeen() async {
    // Gunakan setter dari utils
    await _prefsUtils.setOnboardingAsSeen();
  }
}
