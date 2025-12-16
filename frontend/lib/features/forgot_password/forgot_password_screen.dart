import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // Import GetX jika akan menggunakan Get.back() atau Get.snackbar()
import 'package:moneyvesto/core/constants/color.dart';
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
      backgroundColor:
          AppColors
              .background, // Menggunakan warna latar belakang dari AppColors
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                color:
                    AppColors
                        .textLight, // Menggunakan warna teks terang dari AppColors
              ),
              SizedBox(height: 8.h),
              GlobalText.regular(
                'Enter your email to reset your password',
                fontSize: 14.sp,
                color:
                    AppColors
                        .textLight, // Menggunakan warna teks terang dari AppColors
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
                backgroundColor:
                    AppColors
                        .primaryAccent,
                textColor: AppColors.textLight,
                onPressed: () {
                  Get.snackbar(
                    'Fitur Dalam Pengembangan',
                    'Logika untuk kirim email reset belum diimplementasikan.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                },
                width: 1.sw, // Lebar penuh
                fontSize: 14.sp,
                height: 48.h,
              ),
              const Spacer(), // Mendorong tombol kembali ke bawah
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya (LoginScreen)
                  },
                  child: GlobalText.regular(
                    'Back to Sign In',
                    fontSize: 12.sp,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
