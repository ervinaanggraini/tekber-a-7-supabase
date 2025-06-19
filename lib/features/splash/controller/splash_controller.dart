// file: lib/modules/splash/splash_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/data/auth_datasource.dart';

class SplashController extends GetxController {
  final AuthDataSource _authDataSource = AuthDataSourceImpl();

  @override
  void onInit() {
    super.onInit();
    // Durasi minimal splash screen ditampilkan, sesuai dengan kode Anda
    Timer(const Duration(seconds: 3), _decideRoute);
  }

  /// Memutuskan rute selanjutnya berdasarkan status onboarding dan login
  void _decideRoute() async {
    final bool hasSeenOnboarding = await _authDataSource.hasSeenOnboarding();

    if (!hasSeenOnboarding) {
      // Jika belum pernah lihat onboarding, arahkan ke sana
      Get.offNamed(NavigationRoutes.onboarding);
    } else {
      // Jika sudah, cek status login
      _checkLoginStatus();
    }
  }

  /// Memeriksa apakah token login masih valid
  Future<void> _checkLoginStatus() async {
    final bool userIsLoggedIn = await _authDataSource.isLoggedIn();

    if (userIsLoggedIn) {
      try {
        // Validasi token dengan memanggil data pengguna
        await _authDataSource.getCurrentUser();
        // Jika berhasil, token valid, arahkan ke home
        Get.offAllNamed(NavigationRoutes.home);
      } catch (e) {
        // Jika gagal (token expired), logout dan arahkan ke login
        await _authDataSource.logout();
        Get.offAllNamed(NavigationRoutes.login);
      }
    } else {
      // Jika belum login, arahkan ke login
      Get.offAllNamed(NavigationRoutes.login);
    }
  }
}
