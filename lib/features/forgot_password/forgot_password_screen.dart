import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart'; // <-- IMPORT AppColors
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
                // Catatan: GlobalTextField mungkin memerlukan pembaruan internal
                // untuk menyesuaikan dengan tema gelap jika belum diatur
              ),
              SizedBox(height: 30.h),
              GlobalButton(
                text: 'Send Reset Link',
                backgroundColor:
                    AppColors
                        .primaryAccent, // Tombol utama menggunakan aksen primer
                textColor: AppColors.textLight,
                onPressed: () {
                  // Tambahkan logika untuk mengirim email reset password
                  // Misalnya, panggil fungsi dari controller/service Anda
                  // Get.snackbar('Info', 'Password reset link sent to ${emailController.text}');
                },
                width: 1.sw, // Lebar penuh
                fontSize: 14.sp,
              ),
              // Anda bisa menambahkan tombol "Kembali ke Login" jika dirasa perlu
              // SizedBox(height: 20.h),
              // TextButton(
              //   onPressed: () {
              //     Get.back(); // Kembali ke halaman sebelumnya (LoginScreen)
              //   },
              //   child: GlobalText.regular(
              //     'Back to Sign In',
              //     fontSize: 12.sp,
              //     color: AppColors.primaryAccent,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
