import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Liburan ke Bali',
      'target': 5000000,
      'current': 1500000,
      'deadline': '31 Des 2025',
      'icon': Icons.beach_access,
      'color': Colors.blue,
    },
    {
      'title': 'Beli Laptop Baru',
      'target': 15000000,
      'current': 5000000,
      'deadline': '15 Jun 2025',
      'icon': Icons.laptop_mac,
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: GlobalText.semiBold(
          'Target Tabungan',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textLight, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _goals.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final goal = _goals[index];
          final progress = (goal['current'] / goal['target']).clamp(0.0, 1.0);
          
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.secondaryAccent,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: (goal['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(goal['icon'], color: goal['color'], size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlobalText.semiBold(goal['title'], fontSize: 16.sp, color: AppColors.textLight),
                          GlobalText.regular("Deadline: ${goal['deadline']}", fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.6)),
                        ],
                      ),
                    ),
                    GlobalText.semiBold("${(progress * 100).toInt()}%", fontSize: 16.sp, color: AppColors.primaryAccent),
                  ],
                ),
                SizedBox(height: 16.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.background,
                  color: goal['color'],
                  minHeight: 8.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlobalText.regular("Terkumpul: Rp ${goal['current']}", fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.8)),
                    GlobalText.regular("Target: Rp ${goal['target']}", fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.8)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddGoalDialog() {
    // Implementasi dialog tambah goal (UI only for now)
    Get.snackbar("Info", "Fitur tambah goal akan segera hadir!");
  }
}
