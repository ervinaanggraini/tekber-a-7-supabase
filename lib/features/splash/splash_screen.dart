// file: lib/screens/splash_screen.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/features/splash/controller/splash_controller.dart';

// Ubah menjadi StatelessWidget
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Baris ini akan menginisialisasi controller dan secara otomatis
    // menjalankan logika di dalam onInit() untuk pengecekan rute.
    Get.put(SplashController());

    return BaseWidgetContainer(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/splash_logo.json',
              width: 0.5.sh,
              height: 0.5.sh,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
