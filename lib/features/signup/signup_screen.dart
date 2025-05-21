import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return BaseWidgetContainer(
      backgroundColor: const Color(0xFF002366),
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
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                GlobalText.regular(
                  'Sign up to get started',
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 40.h),
                GlobalTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                ),
                SizedBox(height: 20.h),
                GlobalTextField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.h),
                GlobalTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                SizedBox(height: 20.h),
                GlobalTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  isPassword: true,
                ),

                SizedBox(height: 30.h),
                GlobalButton(
                  text: 'Sign Up',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    // Sign Up action
                  },
                  width: 1.sw,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlobalText.regular(
                      'Already have an account?',
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(NavigationRoutes.login);
                      },
                      child: GlobalText.semiBold(
                        'Sign In',
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
