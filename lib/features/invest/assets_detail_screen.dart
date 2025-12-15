// File: lib/screens/asset_detail_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Sesuaikan path import ini dengan struktur proyek Anda
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';

class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key});

  String formatCurrency(double amount) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2, // Tampilkan desimal untuk detail
  ).format(amount);

  @override
  Widget build(BuildContext context) {
    // Ambil data aset yang dikirim dari halaman sebelumnya
    final Map<String, dynamic> asset = Get.arguments;
    final List<double> priceHistory = asset['priceHistory'];

    // Ubah data List<double> menjadi List<FlSpot> untuk grafik
    final List<FlSpot> spots =
        priceHistory.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value);
        }).toList();

    // Tentukan warna grafik berdasarkan tren
    final bool isUpTrend =
        priceHistory.isNotEmpty && priceHistory.last >= priceHistory.first;
    final Color chartColor = isUpTrend ? AppColors.success : AppColors.danger;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: GlobalText.medium(
          'Detail ${asset['code']}',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Detail Saham
            Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.secondaryAccent,
                  child: Image.asset(
                    'assets/images/${asset['code']}.png',
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        asset['icon'],
                        color: AppColors.textLight,
                        size: 30.sp,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalText.semiBold(
                      asset['name'],
                      fontSize: 18.sp,
                      color: AppColors.textLight,
                    ),
                    GlobalText.regular(
                      formatCurrency(asset['price']),
                      fontSize: 16.sp,
                      color: AppColors.textLight.withOpacity(0.8),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Grafik Histori Harga
            GlobalText.semiBold(
              "Grafik Pergerakan Harga",
              fontSize: 16.sp,
              color: AppColors.textLight,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child:
                  priceHistory.length < 2
                      ? Center(
                        child: GlobalText.regular(
                          "Data histori tidak cukup untuk menampilkan grafik.",
                          color: AppColors.textLight,
                        ),
                      )
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: AppColors.secondaryAccent.withOpacity(
                                  0.5,
                                ),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: AppColors.secondaryAccent.withOpacity(
                                  0.5,
                                ),
                                strokeWidth: 1,
                              );
                            },
                          ),

                          // --- AWAL PERUBAHAN ---
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45, // Beri sedikit ruang lebih
                                getTitlesWidget: (value, meta) {
                                  // Fungsi untuk membuat widget label di sisi kiri
                                  final style = TextStyle(
                                    color: AppColors.textLight.withOpacity(
                                      0.8,
                                    ), // Warna teks diubah menjadi putih
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  );
                                  // Menggunakan NumberFormat.compact agar ringkas (misal: 9K, 1M)
                                  String text = NumberFormat.compact().format(
                                    value,
                                  );
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(text, style: style),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color:
                                  AppColors
                                      .secondaryAccent, // Warna border diganti agar lebih soft
                              width: 1,
                            ),
                          ),

                          // --- AKHIR PERUBAHAN ---
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: chartColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: chartColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
