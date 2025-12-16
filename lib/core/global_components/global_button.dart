import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';

class GlobalButton extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final String? svgAsset;
  final IconData? icon;
  final double width;
  final double height;
  final double iconSize;
  final bool isLoading;
  final double? fontSize;

  const GlobalButton({
    super.key,
    this.text,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.onPressed,
    this.svgAsset,
    this.icon,
    this.width = 354.16,
    this.height = 48,
    this.iconSize = 24,
    this.isLoading = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<double> scaleNotifier = ValueNotifier(1.0);

    return Listener(
      onPointerDown: (_) {
        if (!isLoading) scaleNotifier.value = 0.97;
      },
      onPointerUp: (_) {
        scaleNotifier.value = 1.0;
      },
      onPointerCancel: (_) {
        scaleNotifier.value = 1.0;
      },
      child: ValueListenableBuilder<double>(
        valueListenable: scaleNotifier,
        builder: (context, scale, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: scale),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: GestureDetector(
              onTap: isLoading ? null : onPressed,
              child: Container(
                width: width.w,
                height: height.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient:
                      backgroundColor == null
                          ? const LinearGradient(
                            colors: [Color(0xFF6D2AFF), Color(0xFF00E6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E6FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child:
                      isLoading
                          ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                textColor,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (svgAsset != null) ...[
                                SvgPicture.asset(
                                  svgAsset!,
                                  width: iconSize.w,
                                  height: iconSize.h,
                                  color: textColor,
                                ),
                                if (text != null && text!.isNotEmpty)
                                  SizedBox(width: 8.w),
                              ] else if (icon != null) ...[
                                Icon(icon, size: iconSize.sp, color: textColor),
                                if (text != null && text!.isNotEmpty)
                                  SizedBox(width: 8.w),
                              ],
                              if (text != null && text!.isNotEmpty)
                                GlobalText.regular(
                                  text ?? '',
                                  color: textColor,
                                  fontSize: fontSize ?? 14.sp,
                                ),
                            ],
                          ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
