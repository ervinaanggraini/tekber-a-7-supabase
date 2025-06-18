import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart'; // Ditambahkan import AppColors

class HomeMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const HomeMenuButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;

    if (isActive) {
      backgroundColor = AppColors.primaryAccent.withOpacity(
        0.15,
      ); // Latar sedikit transparan dari aksen primer
      iconColor =
          AppColors.primaryAccent; // Ikon menggunakan warna aksen primer
      textColor = AppColors.textLight; // Teks label terang
    } else {
      backgroundColor = AppColors.secondaryAccent.withOpacity(
        0.5,
      ); // Latar abu-abu sekunder lebih transparan
      iconColor = AppColors.textLight.withOpacity(0.4); // Ikon redup
      textColor = AppColors.textLight.withOpacity(0.6); // Teks label redup
    }

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        // Membungkus Column dengan Container untuk padding jika perlu
        width: 70.w, // Atur lebar agar label panjang tidak terlalu mepet
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w, // Ukuran lingkaran sedikit disesuaikan
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26.sp,
              ), // Ukuran ikon disesuaikan
            ),
            SizedBox(height: 8.h),
            GlobalText.regular(
              // Menggunakan GlobalText
              label,
              fontSize: 12.sp,
              color: textColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
