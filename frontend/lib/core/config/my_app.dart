import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrapper untuk menjaga UI tetap proporsional di Web/Desktop.
    Widget buildApp() {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            title: 'MoneyVesto',
            debugShowCheckedModeBanner: true,
            initialRoute: NavigationRoutes.initial,
            getPages: NavigationRoutes.routes,
            defaultTransition: Transition.fadeIn,
            home: child,
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          // Simulasikan viewport mobile saat dibuka di browser/desktop.
          final double targetHeight = constraints.maxHeight > 850
              ? 850
              : constraints.maxHeight;
          return Container(
            color: Colors.black87,
            alignment: Alignment.center,
            child: SizedBox(
              width: 375,
              height: targetHeight,
              child: buildApp(),
            ),
          );
        }
        return buildApp();
      },
    );
  }
}
