import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    Color backgroundColor =
        isActive ? const Color(0xFFE8F1FF) : Colors.grey.shade200;
    Color iconColor = isActive ? const Color(0xFF003366) : Colors.grey;
    Color textColor = isActive ? Colors.black : Colors.grey;

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Icon(icon, color: iconColor, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
