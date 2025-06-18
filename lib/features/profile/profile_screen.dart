import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userName = 'John Doe';
  final String avatarUrl = 'https://i.pravatar.cc/150?img=3';

  late TextEditingController emailController;
  late TextEditingController phoneController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(
      text: 'john.doe@example.com',
    );
    phoneController = TextEditingController(
      text: '081234567890',
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void onEditPressed() {
    setState(() {
      if (isEditing) {
        print('Saving data: ${emailController.text}, ${phoneController.text}');
      }
      isEditing = !isEditing;
    });
  }

  void onLogoutPressed() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                AppColors.secondaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: GlobalText.semiBold(
              'Logout',
              color: AppColors.textLight,
              fontSize: 18.sp,
            ),
            content: GlobalText.regular(
              'Are you sure you want to logout?',
              color: AppColors.textLight.withOpacity(0.85),
              fontSize: 14.sp,
            ),
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: GlobalText.medium(
                  'Cancel',
                  color: AppColors.textLight.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Tutup dialog
                  // TODO: Tambahkan aksi logout di sini (misal clear session, navigasi ke login)
                  // Get.offAllNamed(NavigationRoutes.login); // Contoh navigasi setelah logout
                  print('Logout button pressed');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                child: GlobalText.medium(
                  // Menggunakan GlobalText
                  'Logout',
                  color:
                      AppColors
                          .danger, // Menggunakan warna bahaya dari AppColors (jika ada)
                  // atau Colors.redAccent.shade200
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Untuk GlobalTextField, pastikan internal stylingnya mendukung dark theme:
    // - hintStyle: color: AppColors.textLight.withOpacity(0.5)
    // - style (input text): color: AppColors.textLight
    // - border color (enabled): AppColors.secondaryAccent.withOpacity(0.7) atau AppColors.textLight.withOpacity(0.3)
    // - border color (focused): AppColors.primaryAccent
    // - background color (jika ada): transparan atau AppColors.secondaryAccent.withOpacity(0.3)
    // - cursorColor: AppColors.primaryAccent
    // - disabled state: warna lebih redup (misal background AppColors.secondaryAccent.withOpacity(0.2))

    return Scaffold(
      backgroundColor: AppColors.background, // Latar utama disesuaikan
      appBar: AppBar(
        backgroundColor: AppColors.background, // Latar AppBar disesuaikan
        elevation: 0,
        title: GlobalText.semiBold(
          // Menggunakan semiBold untuk konsistensi
          'Profile',
          color: AppColors.textLight,
          fontSize: 18.sp, // Ukuran font disesuaikan
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Get.back(), // Menggunakan Get.back()
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: TextButton(
              onPressed: onEditPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: GlobalText.medium(
                // Menggunakan GlobalText
                isEditing ? 'Save' : 'Edit',
                color:
                    AppColors
                        .primaryAccent, // Menggunakan primaryAccent untuk tombol aksi
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            CircleAvatar(
              radius: 55.r, // Sedikit lebih besar
              backgroundColor:
                  AppColors.secondaryAccent, // Warna placeholder avatar
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: AppColors.secondaryAccent.withOpacity(0.5),
                onBackgroundImageError: (exception, stackTrace) {
                  // Penanganan error gambar
                  print('Error loading avatar: $exception');
                },
                child:
                    avatarUrl.isEmpty
                        ? Icon(
                          Icons.person,
                          size: 50.r,
                          color: AppColors.textLight.withOpacity(0.7),
                        )
                        : null,
              ),
            ),
            SizedBox(height: 16.h),
            GlobalText.semiBold(
              userName,
              color: AppColors.textLight,
              fontSize: 22.sp,
            ),
            SizedBox(height: 30.h),
            GlobalTextField(
              controller: emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              enabled: isEditing,
            ),
            SizedBox(height: 18.h),
            GlobalTextField(
              controller: phoneController,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              enabled: isEditing,
            ),
            const Spacer(), // Mendorong tombol Logout ke bawah
            GlobalButton(
              onPressed: onLogoutPressed, // Menambahkan onPressed
              backgroundColor: AppColors.danger.withOpacity(
                0.85,
              ), // Menggunakan warna bahaya dari AppColors
              // atau Colors.redAccent.shade400
              text: 'Logout',
              textColor:
                  AppColors.textLight, // Pastikan GlobalButton mengatur ini
              width: 1.sw - 40.w, // Lebar disesuaikan dengan padding
              height: 48.h,
            ),
            SizedBox(height: 20.h), // Padding di bawah tombol logout
          ],
        ),
      ),
    );
  }
}

// Pastikan AppColors memiliki definisi untuk AppColors.danger, contoh:
// static const Color danger = Color(0xFFD32F2F); // Merah tua
// Jika belum ada, Anda bisa gunakan Colors.redAccent.shade400 atau sejenisnya.
