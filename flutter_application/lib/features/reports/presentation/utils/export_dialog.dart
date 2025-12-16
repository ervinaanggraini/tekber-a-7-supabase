import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

Future<void> showExportSuccessDialog(BuildContext context, String fileType) async {
  final message = 'Berhasil mengunduh file $fileType';
  // use showGeneralDialog for centered popup with custom style
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Export Success',
    pageBuilder: (_, __, ___) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: AppColors.b93160,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );

  // Auto-dismiss after a short delay
  await Future.delayed(const Duration(milliseconds: 1500));
  try {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  } catch (_) {}
}
