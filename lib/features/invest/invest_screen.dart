import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/features/invest/controller/invest_controller.dart';

import 'package:moneyvesto/features/invest/savings_goal_screen.dart';

class EducationAndSimulationScreen extends StatelessWidget {
  const EducationAndSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvestController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: GlobalText.medium(
          'Investasi',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.savings_outlined, color: AppColors.primaryAccent),
            onPressed: () => Get.to(() => const SavingsGoalScreen()),
            tooltip: "Target Tabungan",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayerProfileCard(controller),
                SizedBox(height: 24.h),
                _buildPortfolioSummary(controller),
                SizedBox(height: 28.h),
                _buildLearningSection(context),
                SizedBox(height: 28.h),
                _buildMarketSection(context, controller),
                SizedBox(height: 28.h),
                _buildMyAssetsSection(context, controller),
                SizedBox(height: 28.h),
                _buildTransactionHistory(controller),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLearningSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlobalText.semiBold("Belajar Investasi", fontSize: 18.sp, color: AppColors.textLight),
            GlobalText.medium("Lihat Semua", fontSize: 14.sp, color: AppColors.primaryAccent),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCourseCard(
                "Dasar Saham",
                "Pelajari cara kerja pasar saham",
                Icons.trending_up,
                Colors.blue,
              ),
              SizedBox(width: 12.w),
              _buildCourseCard(
                "Reksadana 101",
                "Investasi aman untuk pemula",
                Icons.pie_chart,
                Colors.green,
              ),
              SizedBox(width: 12.w),
              _buildCourseCard(
                "Analisis Teknikal",
                "Membaca grafik harga saham",
                Icons.show_chart,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          const Spacer(),
          GlobalText.semiBold(title, fontSize: 14.sp, color: AppColors.textLight),
          SizedBox(height: 4.h),
          GlobalText.regular(
            subtitle,
            fontSize: 12.sp,
            color: AppColors.textLight.withOpacity(0.7),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerProfileCard(InvestController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle, color: AppColors.primaryAccent, size: 32.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalText.semiBold("Investor Pemula", fontSize: 16.sp, color: AppColors.textLight),
              GlobalText.regular("Level ${controller.level.value}", fontSize: 13.sp, color: AppColors.textLight.withOpacity(0.7)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GlobalText.medium("XP", fontSize: 12.sp, color: AppColors.primaryAccent),
              GlobalText.semiBold("${controller.xp.value}", fontSize: 14.sp, color: AppColors.textLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(InvestController controller) {
    double totalValue = controller.calculateTotalAssetValue() + controller.virtualCash.value;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryAccent.withOpacity(0.8), AppColors.primaryAccent.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.primaryAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalText.medium("Total Nilai Portofolio", fontSize: 14.sp, color: Colors.white.withOpacity(0.9)),
          SizedBox(height: 8.h),
          AnimatedFlipCounter(
            value: totalValue,
            prefix: "Rp ",
            textStyle: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem("Cash", controller.virtualCash.value),
              _buildSummaryItem("Aset", controller.calculateTotalAssetValue()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.regular(label, fontSize: 12.sp, color: Colors.white.withOpacity(0.8)),
        Text(
          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMarketSection(BuildContext context, InvestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold("Pasar Saham (Simulasi)", fontSize: 18.sp, color: AppColors.textLight),
        SizedBox(height: 16.h),
        ...controller.simulatedMarketAssets.map((asset) => _buildMarketAssetCard(context, controller, asset)),
      ],
    );
  }

  Widget _buildMarketAssetCard(BuildContext context, InvestController controller, Map<String, dynamic> asset) {
    double price = asset['price'];
    double change = asset['lastChange'];
    Color changeColor = change >= 0 ? AppColors.success : AppColors.danger;

    return Card(
      color: AppColors.cardBackground,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8.r)),
          child: Icon(asset['icon'], color: AppColors.primaryAccent),
        ),
        title: GlobalText.semiBold(asset['code'], fontSize: 16.sp, color: AppColors.textLight),
        subtitle: GlobalText.regular(asset['name'], fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.6)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textLight),
            ),
            Text(
              "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
              style: TextStyle(fontSize: 12.sp, color: changeColor),
            ),
          ],
        ),
        onTap: () => _showBuyDialog(context, controller, asset),
      ),
    );
  }

  Widget _buildMyAssetsSection(BuildContext context, InvestController controller) {
    if (controller.myAssets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold("Aset Saya", fontSize: 18.sp, color: AppColors.textLight),
        SizedBox(height: 16.h),
        ...controller.myAssets.map((asset) => _buildMyAssetCard(context, controller, asset)),
      ],
    );
  }

  Widget _buildMyAssetCard(BuildContext context, InvestController controller, Map<String, dynamic> asset) {
    // Find current market price
    final marketAsset = controller.simulatedMarketAssets.firstWhere(
      (a) => a['code'] == asset['code'],
      orElse: () => {'price': asset['avgPrice']},
    );
    double currentPrice = marketAsset['price'];
    double avgPrice = asset['avgPrice'];
    double quantity = asset['quantity'];
    double profitLoss = (currentPrice - avgPrice) * quantity;
    double profitLossPercent = ((currentPrice - avgPrice) / avgPrice) * 100;

    return Card(
      color: AppColors.cardBackground,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlobalText.semiBold(asset['code'], fontSize: 16.sp, color: AppColors.textLight),
                GlobalText.regular("${quantity.toStringAsFixed(0)} Lembar", fontSize: 14.sp, color: AppColors.textLight),
              ],
            ),
            Divider(color: AppColors.textLight.withOpacity(0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalText.regular("Nilai Sekarang", fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.6)),
                    GlobalText.medium(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(currentPrice * quantity),
                      fontSize: 14.sp,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GlobalText.regular("P/L", fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.6)),
                    Text(
                      "${profitLoss >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(profitLoss)} (${profitLossPercent.toStringAsFixed(2)}%)",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: profitLoss >= 0 ? AppColors.success : AppColors.danger),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () => _showSellDialog(context, controller, asset),
                child: const Text("Jual", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(InvestController controller) {
    if (controller.transactionHistory.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold("Riwayat Transaksi", fontSize: 18.sp, color: AppColors.textLight),
        SizedBox(height: 16.h),
        ...controller.transactionHistory.reversed.take(5).map((trx) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: trx['type'] == 'Beli' ? AppColors.success.withOpacity(0.2) : AppColors.danger.withOpacity(0.2),
            child: Icon(
              trx['type'] == 'Beli' ? Icons.arrow_downward : Icons.arrow_upward,
              color: trx['type'] == 'Beli' ? AppColors.success : AppColors.danger,
              size: 16.sp,
            ),
          ),
          title: GlobalText.medium("${trx['type']} ${trx['assetCode']}", fontSize: 14.sp, color: AppColors.textLight),
          subtitle: GlobalText.regular(DateFormat('dd MMM HH:mm').format(trx['timestamp']), fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.6)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GlobalText.semiBold(
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(trx['price'] * trx['quantity']),
                fontSize: 14.sp,
                color: AppColors.textLight,
              ),
              GlobalText.regular("${trx['quantity']} Lembar", fontSize: 12.sp, color: AppColors.textLight.withOpacity(0.6)),
            ],
          ),
        )),
      ],
    );
  }

  void _showBuyDialog(BuildContext context, InvestController controller, Map<String, dynamic> asset) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: GlobalText.semiBold("Beli ${asset['code']}", color: AppColors.textLight),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlobalText.regular("Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(asset['price'])}", color: AppColors.textLight),
            SizedBox(height: 16.h),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: "Jumlah Lembar",
                labelStyle: TextStyle(color: AppColors.textLight),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textLight)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: AppColors.textLight))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              double qty = double.tryParse(quantityController.text) ?? 0;
              if (qty > 0) {
                controller.buyAsset(asset, qty);
                Navigator.pop(context);
              }
            },
            child: const Text("Beli", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSellDialog(BuildContext context, InvestController controller, Map<String, dynamic> asset) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: GlobalText.semiBold("Jual ${asset['code']}", color: AppColors.textLight),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: "Jumlah Lembar",
                labelStyle: TextStyle(color: AppColors.textLight),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textLight)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: AppColors.textLight))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              double qty = double.tryParse(quantityController.text) ?? 0;
              if (qty > 0) {
                controller.sellAsset(asset, qty);
                Navigator.pop(context);
              }
            },
            child: const Text("Jual", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
