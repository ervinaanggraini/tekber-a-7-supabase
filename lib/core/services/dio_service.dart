// lib/core/services/DioService.dart

import 'package:dio/dio.dart';
// --- GANTI IMPORT INI ---
// import 'package:shared_preferences/shared_preferences.dart';
// --- DENGAN IMPORT UTILS ANDA ---
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart'; // Sesuaikan path jika perlu
import 'package:moneyvesto/core/services/endpoints.dart';

class DioService {
  // Singleton pattern
  DioService._();
  static final DioService _instance = DioService._();
  factory DioService() => _instance;

  // Instance SharedPreferencesUtils
  final SharedPreferencesUtils _prefsUtils = SharedPreferencesUtils();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  Dio get dio {
    // Hindari menambahkan interceptor berulang kali
    if (_dio.interceptors.whereType<InterceptorsWrapper>().isEmpty) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          // FUNGSI INI AKAN DIJALANKAN SEBELUM SETIAP REQUEST DIKIRIM
          onRequest: (options, handler) async {
            print('--> ${options.method} ${options.path}');

            // Ambil token menggunakan SharedPreferencesUtils
            final String? token = _prefsUtils.token;

            // ---- DI SINI KITA PRINT TOKENNYA ----
            if (token != null && token.isNotEmpty) {
              // Print token secara eksplisit untuk debugging
              print('✅ Token ditemukan. Menempelkan ke header...');
              print(
                '   Authorization: Bearer $token',
              ); // <-- INI AKAN PRINT TOKEN LENGKAP

              // Tempelkan token ke header Authorization
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              // Print pesan jika token tidak ditemukan
              print(
                '❌ Token tidak ditemukan di SharedPreferences. Request dikirim tanpa token.',
              );
            }

            // Lanjutkan request
            return handler.next(options);
          },

          // Fungsi ini dijalankan saat response diterima
          onResponse: (response, handler) {
            print('<-- ${response.statusCode} ${response.requestOptions.path}');
            print('Response data: ${response.data}');
            return handler.next(response);
          },

          // Fungsi ini dijalankan saat terjadi error
          onError: (DioException e, handler) async {
            print(
              '!!! ERROR ${e.response?.statusCode} ${e.requestOptions.path}',
            );

            // Jika error 401 (Unauthorized), mungkin token expired
            if (e.response?.statusCode == 401) {
              print(
                "🚨 Token tidak valid atau sudah expired. Memaksa logout...",
              );
              // Gunakan utils untuk membersihkan data sesi
              await _prefsUtils.clearToken();
              await _prefsUtils.setLoggedIn(false);
              await _prefsUtils.clearData('currentUser');

              // TODO: Navigasi ke halaman Login menggunakan GetX
              // Get.offAllNamed(NavigationRoutes.login);
            }
            return handler.next(e);
          },
        ),
      );
    }
    return _dio;
  }
}
