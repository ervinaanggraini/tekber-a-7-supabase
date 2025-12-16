import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart'; // Ensure this path is correct
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/utils/route_utils.dart'; // Ensure this path is correct

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _signUpButtonFadeAnimation;
  late Animation<Offset> _signUpButtonSlideAnimation;
  late Animation<double> _loginButtonFadeAnimation;
  late Animation<Offset> _loginButtonSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Total durasi animasi
      vsync: this,
    );

    // Animasi Logo (0ms - 600ms)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // Animasi Judul (300ms - 900ms)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.15, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Animasi SubJudul (500ms - 1100ms)
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );
    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // Animasi Tombol Sign Up (700ms - 1500ms)
    _signUpButtonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );
    _signUpButtonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Animasi Tombol Login (900ms - 1700ms)
    _loginButtonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );
    _loginButtonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidgetContainer(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Image.asset(
                          'assets/icons/app_icon.png', // Pastikan path ini benar
                          height: 100.h,
                          width: 100.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: SlideTransition(
                        position: _titleSlideAnimation,
                        child: GlobalText.semiBold(
                          'Welcome to Moneyvesto!',
                          fontSize: 26.sp,
                          color: AppColors.textLight,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FadeTransition(
                      opacity: _subtitleFadeAnimation,
                      child: SlideTransition(
                        position: _subtitleSlideAnimation,
                        child: GlobalText.regular(
                          'Take control of your finances and achieve your goals with us.',
                          fontSize: 15.sp,
                          color: AppColors.textLight.withOpacity(0.85),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: _signUpButtonFadeAnimation,
                      child: SlideTransition(
                        position: _signUpButtonSlideAnimation,
                        child: GlobalButton(
                          text: 'Sign Up',
                          backgroundColor: AppColors.primaryAccent,
                          textColor: AppColors.textLight,
                          onPressed: () {
                            Get.toNamed(NavigationRoutes.signUp);
                          },
                          fontSize: 16.sp,
                          height:
                              35.h, // Menggunakan tinggi tombol dari kode Anda
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    FadeTransition(
                      opacity: _loginButtonFadeAnimation,
                      child: SlideTransition(
                        position: _loginButtonSlideAnimation,
                        child: GlobalButton(
                          text: 'Login',
                          backgroundColor: AppColors.secondaryAccent,
                          textColor: AppColors.textLight,
                          onPressed: () {
                            Get.toNamed(NavigationRoutes.login);
                          },
                          fontSize: 16.sp,
                          height:
                              35.h, // Menggunakan tinggi tombol dari kode Anda
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
