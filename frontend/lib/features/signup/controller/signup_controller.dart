// file: lib/modules/auth/signup_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/data/auth_datasource.dart';

class SignUpController extends GetxController {
  // Inisialisasi DataSource
  final AuthDataSource _authDataSource = AuthDataSourceImpl();

  // Controllers untuk setiap text field
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State reaktif untuk status loading
  final isLoading = false.obs;

  /// Fungsi untuk mendaftarkan pengguna baru
  Future<void> register() async {
    // 1. Validasi Input
    if (!_validateInput()) {
      return; // Hentikan fungsi jika validasi gagal
    }

    try {
      isLoading.value = true; // Mulai loading

      final response = await _authDataSource.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Asumsi status 201 (Created) adalah sukses
      if (response.statusCode == 201) {
        Get.snackbar(
          'Registrasi Berhasil',
          'Akun Anda telah dibuat. Silakan login.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        // Arahkan ke halaman login setelah berhasil mendaftar
        Get.offNamed(NavigationRoutes.login);
      }
    } catch (e) {
      Get.snackbar(
        'Registrasi Gagal',
        'Terjadi kesalahan. Mungkin email sudah digunakan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Selesai loading
    }
  }

  /// Fungsi private untuk validasi semua input
  bool _validateInput() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackbar('Semua kolom harus diisi.');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showErrorSnackbar('Format email tidak valid.');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showErrorSnackbar('Password minimal harus 6 karakter.');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Password dan konfirmasi password tidak cocok.');
      return false;
    }

    return true; // Semua validasi lolos
  }

  /// Helper untuk menampilkan snackbar error
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    // Selalu dispose controllers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
