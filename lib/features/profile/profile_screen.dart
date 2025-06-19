import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart';
import 'package:moneyvesto/data/auth_datasource.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Instance dari data source untuk interaksi data
  final AuthDataSource _authDataSource = AuthDataSourceImpl();
  final SharedPreferencesUtils _prefsUtils = SharedPreferencesUtils();

  // State untuk menyimpan data pengguna dan status UI
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool isEditing = false;

  // Controller untuk field teks
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    // Panggil fungsi untuk memuat data saat layar pertama kali dibangun
    _loadUserData();
  }

  /// Memuat data pengguna yang tersimpan secara lokal di SharedPreferences.
  Future<void> _loadUserData() async {
    // Pastikan widget masih ada di tree sebelum memanggil setState
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _authDataSource.getSavedUser();
      print('Data pengguna yang dimuat dari SharedPreferences: $data');

      if (mounted && data != null) {
        setState(() {
          _userData = data;
          // Isi controller dengan data yang ada, atau string kosong jika null
          emailController.text = _userData?['email'] ?? '';
          phoneController.text = _userData?['phone'] ?? '';
        });
      }
    } catch (e) {
      print('Gagal memuat data pengguna: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memuat data profil Anda.',
          backgroundColor: AppColors.danger,
          colorText: AppColors.textLight,
        );
      }
    } finally {
      // Hentikan loading setelah proses selesai
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menangani logika saat tombol 'Edit' atau 'Save' ditekan.
  void onEditPressed() {
    setState(() {
      if (isEditing) {
        // Jika sedang dalam mode 'Save'
        print('Saving data: ${emailController.text}, ${phoneController.text}');
        // TODO: Implementasikan logika untuk mengirim data yang diperbarui ke API/server Anda.
        // Contoh: await _authDataSource.updateUser(name: ..., email: emailController.text, ...);
      }
      // Toggle mode edit
      isEditing = !isEditing;
    });
  }

  /// Menampilkan dialog konfirmasi sebelum melakukan logout.
  void onLogoutPressed() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.secondaryAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: GlobalText.semiBold(
              'Logout',
              color: AppColors.textLight,
              fontSize: 18.sp,
            ),
            content: GlobalText.regular(
              'Apakah Anda yakin ingin keluar?',
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
                  'Batal',
                  color: AppColors.textLight.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
              TextButton(
                onPressed: _performLogout,
                child: GlobalText.medium(
                  'Logout',
                  color: AppColors.danger,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
    );
  }

  /// Melakukan proses logout dan navigasi.
  Future<void> _performLogout() async {
    // Tutup dialog konfirmasi
    Get.back();

    // Opsional: tampilkan loading overlay
    // Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      await _authDataSource.logout();
      _prefsUtils.clearAll(); 
      // Navigasi ke halaman login dan hapus semua halaman sebelumnya dari stack
      // Pastikan Anda punya definisi rute bernama 'login'
      Get.offAllNamed(NavigationRoutes.login);
      print("Logout berhasil, seharusnya navigasi ke halaman login.");
    } catch (e) {
      // Get.back(); // Tutup loading overlay jika ada
      print("Gagal melakukan logout: $e");
      Get.snackbar(
        'Logout Gagal',
        'Terjadi kesalahan. Silakan coba lagi.',
        backgroundColor: AppColors.danger,
        colorText: AppColors.textLight,
      );
    }
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk menghindari memory leaks
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: GlobalText.semiBold(
          'Profile',
          color: AppColors.textLight,
          fontSize: 18.sp,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: TextButton(
              onPressed: onEditPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: GlobalText.medium(
                isEditing ? 'Save' : 'Edit',
                color: AppColors.primaryAccent,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryAccent,
                ),
              )
              : _userData == null
              ? Center(
                child: GlobalText.regular(
                  'Gagal memuat data pengguna.',
                  color: AppColors.textLight,
                ),
              )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    CircleAvatar(
                      radius: 55.r,
                      backgroundColor: AppColors.secondaryAccent,
                      child: CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppColors.secondaryAccent.withOpacity(
                          0.5,
                        ),
                        backgroundImage:
                            _userData?['avatar_url'] != null
                                ? NetworkImage(_userData!['avatar_url'])
                                : null,
                        child:
                            _userData?['avatar_url'] == null
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
                      _userData?['username'] ?? 'Nama Pengguna',
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
                      hintText: 'Nomor Telepon',
                      keyboardType: TextInputType.phone,
                      enabled: isEditing,
                    ),
                    const Spacer(),
                    GlobalButton(
                      onPressed: onLogoutPressed,
                      backgroundColor: AppColors.danger.withOpacity(0.85),
                      text: 'Logout',
                      textColor: AppColors.textLight,
                      width: 1.sw - 40.w,
                      height: 48.h,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
    );
  }
}
