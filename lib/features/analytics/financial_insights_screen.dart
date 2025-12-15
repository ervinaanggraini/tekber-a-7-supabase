import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';

class FinancialInsightsScreen extends StatelessWidget {
  const FinancialInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: GlobalText.semiBold(
          'Financial Insights',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textLight, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsightCard(
              "Analisis Pengeluaran",
              "Pengeluaranmu bulan ini lebih hemat 15% dibanding bulan lalu. Pertahankan!",
              Icons.trending_down,
              AppColors.success,
            ),
            SizedBox(height: 16.h),
            _buildInsightCard(
              "Tips Hemat",
              "Coba kurangi jajan kopi kekinian, kamu bisa hemat Rp 500.000 bulan ini.",
              Icons.lightbulb_outline,
              Colors.orange,
            ),
            SizedBox(height: 16.h),
            _buildInsightCard(
              "Peluang Investasi",
              "Dengan sisa budgetmu, kamu bisa mulai investasi di Reksadana Pasar Uang.",
              Icons.monetization_on_outlined,
              Colors.blue,
            ),
            SizedBox(height: 24.h),
            GlobalText.semiBold("Tren Keuangan", fontSize: 16.sp, color: AppColors.textLight),
            SizedBox(height: 12.h),
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: GlobalText.regular(
                  "Grafik Tren (Coming Soon)",
                  color: AppColors.textLight.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalText.semiBold(title, fontSize: 16.sp, color: AppColors.textLight),
                SizedBox(height: 4.h),
                GlobalText.regular(
                  description,
                  fontSize: 14.sp,
                  color: AppColors.textLight.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
