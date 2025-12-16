import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/features/gamification/controller/gamification_controller.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GamificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: GlobalText.medium(
          'Gamifikasi',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.userProfile;
        final level = profile['level'] ?? 1;
        final xp = profile['total_xp'] ?? 0;
        final points = profile['total_points'] ?? 0;
        final streak = profile['current_streak'] ?? 0;

        return RefreshIndicator(
          onRefresh: controller.fetchGamificationData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(level, xp, points, streak),
                SizedBox(height: 24.h),
                GlobalText.semiBold(
                  'Misi Aktif',
                  fontSize: 16.sp,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 12.h),
                _buildMissionsList(controller.missions),
                SizedBox(height: 24.h),
                GlobalText.semiBold(
                  'Lencana Saya',
                  fontSize: 16.sp,
                  color: AppColors.textLight,
                ),
                SizedBox(height: 12.h),
                _buildBadgesGrid(controller.badges),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard(int level, int xp, int points, int streak) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalText.regular(
                    'Level $level',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 4.h),
                  GlobalText.bold(
                    '$xp XP',
                    color: Colors.white,
                    fontSize: 24.sp,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 4.w),
                    GlobalText.semiBold(
                      '$streak Hari Streak',
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalText.regular(
                      'Total Poin',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                    GlobalText.semiBold(
                      '$points Poin',
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ],
                ),
              ),
              // Placeholder for progress bar if needed
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList(List<Map<String, dynamic>> missions) {
    if (missions.isEmpty) {
      return Center(
        child: GlobalText.regular(
          'Tidak ada misi aktif saat ini.',
          color: AppColors.textSecondary,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: missions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final mission = missions[index];
        final progress = (mission['current_progress'] as num).toDouble();
        final target = (mission['target_progress'] as num).toDouble();
        final percent = (progress / target).clamp(0.0, 1.0);

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GlobalText.semiBold(
                      mission['title'] ?? 'Misi',
                      color: AppColors.textLight,
                      fontSize: 14.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: GlobalText.medium(
                      '+${mission['xp_reward']} XP',
                      color: AppColors.primary,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              GlobalText.regular(
                mission['description'] ?? '',
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
              SizedBox(height: 12.h),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.background,
                color: AppColors.primary,
                minHeight: 6.h,
                borderRadius: BorderRadius.circular(3.r),
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: GlobalText.regular(
                  '${progress.toInt()} / ${target.toInt()}',
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgesGrid(List<Map<String, dynamic>> badges) {
    if (badges.isEmpty) {
      return Center(
        child: GlobalText.regular(
          'Belum ada lencana yang didapatkan.',
          color: AppColors.textSecondary,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events, // Placeholder icon
                color: Colors.amber,
                size: 32.sp,
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GlobalText.medium(
                  badge['name'] ?? 'Badge',
                  color: AppColors.textLight,
                  fontSize: 12.sp,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
