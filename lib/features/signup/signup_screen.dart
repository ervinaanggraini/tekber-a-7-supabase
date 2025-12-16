// file: lib/screens/signup_screen.dart (sesuaikan dengan path Anda)

import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';
import 'package:moneyvesto/core/global_components/legal_bottom_sheets.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/features/signup/controller/signup_controller.dart';

// 2. Ubah menjadi StatelessWidget
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Inisialisasi controller menggunakan Get.put()
    final controller = Get.put(SignUpController());

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                GlobalText.semiBold(
                  'Create Account',
                  fontSize: 24.sp,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 8.h),
                GlobalText.regular(
                  'Sign up to get started',
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 30.h),
                // 4. Hubungkan semua text field ke controller
                GlobalTextField(
                  controller: controller.nameController,
                  hintText: 'Username',
                ),
                SizedBox(height: 18.h),
                GlobalTextField(
                  controller: controller.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 18.h),
                GlobalTextField(
                  controller: controller.passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                SizedBox(height: 18.h),
                GlobalTextField(
                  controller: controller.confirmPasswordController,
                  hintText: 'Confirm Password',
                  isPassword: true,
                ),
                SizedBox(height: 25.h),
                // 5. Bungkus Tombol dengan Obx dan hubungkan ke controller
                Obx(
                  () => GlobalButton(
                    isLoading: controller.isLoading.value,
                    text: 'Sign Up',
                    backgroundColor: AppColors.primaryAccent,
                    textColor: AppColors.textLight,
                    onPressed: () {
                      // 6. Panggil fungsi register dari controller
                      controller.register();
                    },
                    width: 1.sw,
                    fontSize: 14.sp,
                    height: 48.h,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
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
                        // Kembali ke halaman login
                        Get.toNamed(NavigationRoutes.login);
                      },
                      child: GlobalText.semiBold(
                        'Sign In',
                        fontSize: 12.sp,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Center(
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
                          ),
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
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
