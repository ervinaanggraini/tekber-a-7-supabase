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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000), // Durasi total animasi
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                  endInterval: 0.2, // Penyesuaian interval
                  child: GlobalText.semiBold(
                    'Welcome Back!',
                    fontSize: 24.sp,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildAnimatedWidget(
                  beginInterval: 0.05,
                  endInterval: 0.25, // Penyesuaian interval
                  child: GlobalText.regular(
                    'Sign in to your account to continue',
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 30.h),
                _buildAnimatedWidget(
                  beginInterval: 0.15,
                  endInterval: 0.4, // Penyesuaian interval
                  child: GlobalTextField(
                    controller: emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 18.h),
                _buildAnimatedWidget(
                  beginInterval: 0.25,
                  endInterval: 0.5, // Penyesuaian interval
                  child: GlobalTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    isPassword: true,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildAnimatedWidget(
                  beginInterval: 0.35,
                  endInterval: 0.6, // Penyesuaian interval
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Get.toNamed(NavigationRoutes.forgotPassword);
                      },
                      child: GlobalText.regular(
                        'Forgot Password?',
                        fontSize: 12.sp,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25.h), // Jarak sebelum tombol Sign In
                _buildAnimatedWidget(
                  beginInterval: 0.45,
                  endInterval: 0.75, // Penyesuaian interval
                  child: GlobalButton(
                    text: 'Sign In',
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.textLight,
                    onPressed: () {
                      Get.offAllNamed(NavigationRoutes.home);
                    },
                    width: 1.sw,
                    fontSize: 14.sp,
                    height: 48.h,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildAnimatedWidget(
                  beginInterval: 0.55,
                  endInterval: 0.85, // Penyesuaian interval
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlobalText.regular(
                        "Don't have an account?",
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
                          Get.toNamed(NavigationRoutes.signUp);
                        },
                        child: GlobalText.semiBold(
                          'Sign Up',
                          fontSize: 12.sp,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ), 
                _buildAnimatedWidget(
                  beginInterval: 0.65,
                  endInterval: 1.0, // Interval untuk TOS & Privacy Policy
                  useSlide: false, // Hanya fade untuk teks di bawah
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: defaultTextStyle,
                          children: <TextSpan>[
                            // Pertimbangkan untuk mengubah teks ini jika posisinya di paling bawah
                            // Misalnya: "Dengan melanjutkan, Anda menyetujui..."
                            // atau "Lihat Ketentuan Layanan dan Kebijakan Privasi kami."
                            const TextSpan(
                              text: 'By signing in, you agree to our\n',
                            ), // \n untuk baris baru
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
