import 'package:get/get.dart';
import 'package:flutter/gestures.dart'; // Import untuk TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';
import 'package:moneyvesto/core/global_components/legal_bottom_sheets.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';

class SignUpScreen extends StatefulWidget {
  // Diubah menjadi StatefulWidget
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  // Ditambahkan Mixin
  late AnimationController _controller;

  // Helper fungsi animasi (sama seperti di LoginScreen)
  Animation<double> createFadeAnimation(
    double beginInterval,
    double endInterval,
  ) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(beginInterval, endInterval, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> createSlideAnimation(
    double beginInterval,
    double endInterval,
  ) {
    return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(beginInterval, endInterval, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _buildAnimatedWidget({
    required Widget child,
    required double beginInterval,
    required double endInterval,
    bool useSlide = true,
  }) {
    if (!useSlide) {
      return FadeTransition(
        opacity: createFadeAnimation(beginInterval, endInterval),
        child: child,
      );
    }
    return FadeTransition(
      opacity: createFadeAnimation(beginInterval, endInterval),
      child: SlideTransition(
        position: createSlideAnimation(beginInterval, endInterval),
        child: child,
      ),
    );
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 2200,
      ), // Durasi total disesuaikan untuk lebih banyak field
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultTextStyle = TextStyle(
      fontSize: 11.sp,
      color: AppColors.textLight.withOpacity(0.7),
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    );
    TextStyle linkTextStyle = TextStyle(
      fontSize: 11.sp,
      color: AppColors.primaryAccent,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primaryAccent,
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    );

    return BaseWidgetContainer(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                _buildAnimatedWidget(
                  beginInterval: 0.0,
                  endInterval: 0.2,
                  child: GlobalText.semiBold(
                    'Create Account',
                    fontSize: 24.sp,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildAnimatedWidget(
                  beginInterval: 0.05,
                  endInterval: 0.25,
                  child: GlobalText.regular(
                    'Sign up to get started',
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 30.h),
                _buildAnimatedWidget(
                  beginInterval: 0.15,
                  endInterval: 0.4,
                  child: GlobalTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                  ),
                ),
                SizedBox(height: 18.h),
                _buildAnimatedWidget(
                  beginInterval: 0.25,
                  endInterval: 0.5,
                  child: GlobalTextField(
                    controller: emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 18.h),
                _buildAnimatedWidget(
                  beginInterval: 0.35,
                  endInterval: 0.6,
                  child: GlobalTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    isPassword: true,
                  ),
                ),
                SizedBox(height: 18.h),
                _buildAnimatedWidget(
                  beginInterval: 0.45,
                  endInterval: 0.7,
                  child: GlobalTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    isPassword: true,
                  ),
                ),
                SizedBox(height: 25.h), // Jarak sebelum tombol Sign Up
                _buildAnimatedWidget(
                  beginInterval: 0.65,
                  endInterval: 0.9,
                  child: GlobalButton(
                    text: 'Sign Up',
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.textLight,
                    onPressed: () {
                      // Logika sign up
                    },
                    width: 1.sw,
                    fontSize: 14.sp,
                    height: 48.h, // Menambahkan tinggi tombol
                  ),
                ),
                SizedBox(height: 20.h),
                _buildAnimatedWidget(
                  beginInterval: 0.75,
                  endInterval: 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlobalText.regular(
                        'Already have an account?',
                        fontSize: 12.sp,
                        color: AppColors.textLight,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(left: 4.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Get.offNamed(NavigationRoutes.login);
                        },
                        child: GlobalText.semiBold(
                          'Sign In',
                          fontSize: 12.sp,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h), // Jarak sebelum teks persetujuan
                _buildAnimatedWidget(
                  beginInterval: 0.55,
                  endInterval: 0.8, // Interval untuk teks persetujuan
                  useSlide:
                      false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: defaultTextStyle,
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'By creating an account, you agree to our\n',
                            ), // Diubah untuk sign up
                            TextSpan(
                              text: 'Terms of Service',
                              style: linkTextStyle,
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      showTermsOfServiceBottomSheet();
                                    },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: linkTextStyle,
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      showPrivacyPolicyBottomSheet();
                                    },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
