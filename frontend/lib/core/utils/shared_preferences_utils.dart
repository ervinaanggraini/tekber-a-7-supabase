// file: lib/core/utils/shared_preferences_utils.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static SharedPreferencesUtils? _instance;
  late SharedPreferences _prefs;

  factory SharedPreferencesUtils() {
    _instance ??= SharedPreferencesUtils._();
    return _instance!;
  }

  SharedPreferencesUtils._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Metode untuk Onboarding
  bool get hasSeenOnboarding => _prefs.getBool('hasSeenOnboarding') ?? false;
  Future<void> setOnboardingAsSeen() async {
    await _prefs.setBool('hasSeenOnboarding', true);
  }

  // Metode untuk status login
  bool get isLoggedIn => _prefs.getBool('isLogin') ?? false;
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('isLogin', value);
  }

  // Metode untuk Token
  String? get token => _prefs.getString('token');
  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    await _prefs.remove('token');
  }

  // Metode generik untuk menyimpan data Map (JSON)
  Future<void> saveData(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  // Metode generik untuk mengambil data Map (JSON)
  Map<String, dynamic>? getData(String key) {
    String? jsonString = _prefs.getString(key);
    return jsonString != null
        ? jsonDecode(jsonString) as Map<String, dynamic>
        : null;
  }

   String? getUserId() {
    final userData = getData('currentUser');
    return userData != null ? userData['id'] as String? : null;
  }

  // Metode untuk menghapus data spesifik
  Future<void> clearData(String key) async {
    await _prefs.remove(key);
  }

  // Metode untuk membersihkan semua data (hati-hati menggunakan ini)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
