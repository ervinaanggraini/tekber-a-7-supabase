import 'dart:async';
import 'package:get/get.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart';

class SplashController extends GetxController {
  final SharedPreferencesUtils _prefs = SharedPreferencesUtils();

  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(seconds: 3), _decideRoute);
  }

  void _decideRoute() async {
    await _prefs.init(); // Pastikan shared prefs sudah siap

    final bool hasSeenOnboarding = _prefs.hasSeenOnboarding;

    if (!hasSeenOnboarding) {
      Get.offNamed(NavigationRoutes.onboarding);
      _prefs.setOnboardingAsSeen(); // Tandai onboarding sudah dilihat
    } else {
      _checkLoginStatus();
    }
  }

  void _checkLoginStatus() {
    final bool isLoggedIn = _prefs.isLoggedIn;
    final String? token = _prefs.token;

    if (isLoggedIn && token != null && token.isNotEmpty) {
      // Dianggap login jika status true dan token tersedia
      Get.offAllNamed(NavigationRoutes.home);
    } else {
      Get.offAllNamed(NavigationRoutes.login);
    }
  }
}
