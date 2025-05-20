import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return BaseWidgetContainer(
      backgroundColor: const Color(0xFF3B48DC),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                GlobalText.semiBold(
                  'Welcome Back!',
                  fontSize: 24.sp, 
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                GlobalText.regular(
                  'Sign in to your account to continue',
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 40.h),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(NavigationRoutes.forgotPassword);
                    },
                    child: GlobalText.regular(
                      'Forgot Password?',
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                GlobalButton(
                  text: 'Sign In',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    // Sign In action
                  },
                  width: 1.sw,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlobalText.regular(
                      "Don't have an account?",
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(NavigationRoutes.signUp);
                      },
                      child: GlobalText.semiBold(
                        'Sign Up',
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
