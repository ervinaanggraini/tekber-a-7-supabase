import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return BaseWidgetContainer(
      backgroundColor: const Color(0xFF3B48DC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              GlobalText.semiBold(
                'Forgot Password',
                fontSize: 24.sp,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              GlobalText.regular(
                'Enter your email to reset your password',
                fontSize: 14.sp,
                color: Colors.white,
              ),
              SizedBox(height: 40.h),
              GlobalTextField(
                controller: emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 30.h),
              GlobalButton(
                text: 'Send Reset Link',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  // Add logic to send password reset email
                },
                width: 1.sw,
                fontSize: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
