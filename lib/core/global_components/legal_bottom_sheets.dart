import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Ditambahkan untuk konsistensi ukuran jika diperlukan
import 'package:moneyvesto/core/constants/color.dart'; // Pastikan path ini benar

// Anda mungkin juga memerlukan GlobalText jika ingin menggunakan gaya teks global,
// tapi untuk saat ini saya akan menggunakan TextStyle langsung dengan warna dari AppColors.

/// Show Terms of Service Bottom Sheet
void showTermsOfServiceBottomSheet() {
  Get.bottomSheet(
    ConstrainedBox(
      // 3. Batasi tinggi maksimal
      constraints: BoxConstraints(maxHeight: Get.height * 0.8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ), // Menggunakan ScreenUtil untuk padding
        decoration: BoxDecoration(
          color:
              AppColors.secondaryAccent, // 1. Warna latar belakang disesuaikan
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ), // Menggunakan ScreenUtil untuk radius
        ),
        child: SafeArea(
          // SafeArea tetap ada di dalam container utama
          child: Column(
            // Column untuk handle dan konten
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opsional: Drag Handle Indicator
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                // Expanded agar SingleChildScrollView mengisi sisa ruang di Column
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms of Service – MoneyVesto',
                        style: TextStyle(
                          fontSize: 20.sp, // Menggunakan ScreenUtil
                          fontWeight: FontWeight.bold,
                          color:
                              AppColors.textLight, // 1. Warna teks disesuaikan
                          fontFamily:
                              Theme.of(Get.context!)
                                  .textTheme
                                  .titleLarge
                                  ?.fontFamily, // Konsistensi font
                        ),
                      ),
                      SizedBox(height: 12.h), // Menggunakan ScreenUtil
                      Text(
                        'Last updated: June 4, 2025\n\n'
                        'Please read these Terms of Service ("Terms") carefully before using the MoneyVesto application ("App") operated by Vesto Corp ("we", "us", or "our").\n\n'
                        '1. Acceptance of Terms\n'
                        'By accessing or using the App, you agree to be bound by these Terms. If you do not agree with any part of the Terms, you may not access or use the App.\n\n'
                        '2. Description of Service\n'
                        'MoneyVesto is an AI-powered financial management application designed to help users track expenses, manage budgets, and make informed financial decisions.\n\n'
                        '3. Eligibility\n'
                        'You must be at least 18 years old or have permission from a legal guardian to use the App.\n\n'
                        '4. Prohibited Uses\n'
                        'You agree not to: use the App for any unlawful purpose; attempt unauthorized access; or transmit harmful content.\n\n'
                        '5. Intellectual Property\n'
                        'All content, features, and technologies are the property of Vesto Corp.\n\n'
                        '6. Termination\n'
                        'We may suspend or terminate your access if you violate these Terms.\n\n'
                        '7. Limitation of Liability\n'
                        'Vesto Corp is not liable for losses resulting from use of the App or AI-generated advice.\n\n'
                        '8. Modifications\n'
                        'We may update these Terms anytime. Continued use means you accept the changes.\n\n'
                        '9. Governing Law\n'
                        'These Terms are governed by the laws of the Republic of Indonesia.\n',
                        style: TextStyle(
                          fontSize: 14.sp, // Menggunakan ScreenUtil
                          color: AppColors.textLight.withOpacity(
                            0.85,
                          ), // 1. Warna teks disesuaikan
                          height: 1.5, // Line height untuk keterbacaan
                          fontFamily:
                              Theme.of(Get.context!)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontFamily, // Konsistensi font
                        ),
                      ),
                      SizedBox(
                        height: 16.h,
                      ), // Padding bawah sebelum akhir scroll
                      // 2. Tombol Close dihilangkan
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    backgroundColor:
        Colors.transparent, // Latar belakang Get.bottomSheet dibuat transparan
    elevation: 0, // Hilangkan shadow default jika ada
    isScrollControlled: true, // Penting untuk custom height dan scrolling
    enterBottomSheetDuration: const Duration(milliseconds: 250),
    exitBottomSheetDuration: const Duration(milliseconds: 200),
  );
}

/// Show Privacy Policy Bottom Sheet
void showPrivacyPolicyBottomSheet() {
  Get.bottomSheet(
    ConstrainedBox(
      // 3. Batasi tinggi maksimal
      constraints: BoxConstraints(maxHeight: Get.height * 0.8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 16.h,
        ), // Menggunakan ScreenUtil untuk padding
        decoration: BoxDecoration(
          color:
              AppColors.secondaryAccent, // 1. Warna latar belakang disesuaikan
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ), // Menggunakan ScreenUtil untuk radius
        ),
        child: SafeArea(
          child: Column(
            // Column untuk handle dan konten
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opsional: Drag Handle Indicator
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                // Expanded agar SingleChildScrollView mengisi sisa ruang di Column
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy – MoneyVesto',
                        style: TextStyle(
                          fontSize: 20.sp, // Menggunakan ScreenUtil
                          fontWeight: FontWeight.bold,
                          color:
                              AppColors.textLight, // 1. Warna teks disesuaikan
                          fontFamily:
                              Theme.of(
                                Get.context!,
                              ).textTheme.titleLarge?.fontFamily,
                        ),
                      ),
                      SizedBox(height: 12.h), // Menggunakan ScreenUtil
                      Text(
                        'Last updated: June 4, 2025\n\n'
                        'Vesto Corp respects your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use the MoneyVesto app.\n\n'
                        '1. Information We Collect\n'
                        '- Personal Info: Name, email, contact info\n'
                        '- Financial Data: Transactions, budgets, goals\n'
                        '- Technical Data: IP address, device, logs\n\n'
                        '2. How We Use Data\n'
                        'To personalize AI recommendations, manage accounts, and improve service quality.\n\n'
                        '3. Data Sharing\n'
                        'We do NOT sell your data. We only share it with trusted third parties or if legally required.\n\n'
                        '4. Security\n'
                        'We use industry-standard encryption and security.\n\n'
                        '5. Your Rights\n'
                        'You can access, edit, or delete your personal data at any time.\n\n'
                        '6. Cookies\n'
                        'We may use cookies or tracking tools to improve experience. You can disable this in settings.\n\n'
                        '7. Data Retention\n'
                        'We retain data as long as necessary for service delivery or legal compliance.\n\n'
                        '8. Updates\n'
                        'We may update this policy and notify you through the app.\n',
                        style: TextStyle(
                          fontSize: 14.sp, // Menggunakan ScreenUtil
                          color: AppColors.textLight.withOpacity(
                            0.85,
                          ), // 1. Warna teks disesuaikan
                          height: 1.5, // Line height
                          fontFamily:
                              Theme.of(
                                Get.context!,
                              ).textTheme.bodyMedium?.fontFamily,
                        ),
                      ),
                      SizedBox(
                        height: 16.h,
                      ), // Padding bawah sebelum akhir scroll
                      // 2. Tombol Close dihilangkan
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    backgroundColor:
        Colors.transparent, // Latar belakang Get.bottomSheet dibuat transparan
    elevation: 0,
    isScrollControlled: true,
    enterBottomSheetDuration: const Duration(milliseconds: 250),
    exitBottomSheetDuration: const Duration(milliseconds: 200),
  );
}
