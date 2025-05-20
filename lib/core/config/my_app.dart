import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Widget utama
          home: child,
        );
      },
    );
  }
}
