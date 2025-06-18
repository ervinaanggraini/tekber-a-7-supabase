import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneyvesto/core/constants/color.dart'; // Impor AppColors
import 'package:moneyvesto/core/global_components/global_text.dart';

class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  String selectedMonth = 'Mei 2025';

  final List<Map<String, dynamic>> transactions = [
    {
      'date': '20 Mei 2025',
      'category': 'Belanja Harian',
      'amount': 2000,
      'isIncome': false,
    },
    {
      'date': '21 Mei 2025',
      'category': 'Pendapatan Sampingan',
      'amount': 5000000,
      'isIncome': true,
    },
    {
      'date': '22 Mei 2025',
      'category': 'Transportasi',
      'amount': 15000,
      'isIncome': false,
    },
    {
      'date': '22 Mei 2025',
      'category': 'Gaji Bulanan',
      'amount': 7000000,
      'isIncome': true,
    },
    {
      'date': '23 Mei 2025',
      'category': 'Makan di Luar',
      'amount': 45000,
      'isIncome': false,
    },
    {
      'date': '24 Mei 2025',
      'category': 'Langganan Streaming',
      'amount': 120000,
      'isIncome': false,
    },
    {
      'date': '24 Mei 2025',
      'category': 'Freelance Desain',
      'amount': 1500000,
      'isIncome': true,
    },
  ];

  int get totalIncome => transactions
      .where((e) => e['isIncome'] == true)
      .fold(0, (sum, e) => sum + e['amount'] as int);

  int get totalExpense => transactions
      .where((e) => e['isIncome'] == false)
      .fold(0, (sum, e) => sum + e['amount'] as int);

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: GlobalText.medium(
          'Laporan',
          color: AppColors.textLight,
          fontSize: 20.sp,
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 24.h, top: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButton<String>(
                value: selectedMonth,
                iconEnabledColor: AppColors.textLight,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                ),
                underline: Container(),
                isExpanded: true,
                dropdownColor: AppColors.secondaryAccent,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedMonth = value);
                  }
                },
                items:
                    ['Mei 2025']
                        .map<DropdownMenuItem<String>>(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: GlobalText.regular(
                              month,
                              color: AppColors.textLight,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

            // Anda dapat menambahkan Chart di sini jika diperlukan
                        // CHART: Bar chart dengan warna baru
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 20,
                      barRods: [
                        BarChartRodData(
                          toY: 0.002,
                          color: AppColors.danger, // Ganti warna
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 21,
                      barRods: [
                        BarChartRodData(
                          toY: 5,
                          color: AppColors.success, // Ganti warna
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    // Anda perlu menambahkan data lainnya di sini agar chart lengkap
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GlobalText.regular(
                              value.toInt().toString(),
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 12.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5, // Ubah interval agar tidak terlalu padat
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return GlobalText.regular(
                              '0',
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 12.sp,
                            );
                          }
                          if (value % 5 == 0 && value > 0) {
                            return GlobalText.regular(
                              '${value.toInt()}M',
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 12.sp,
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 32.w,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

            SizedBox(height: 24.h),


            _buildSummaryRow(
              "Total Pemasukan",
              formatCurrency(totalIncome),
              AppColors.success,
            ),
            _buildSummaryRow(
              "Total Pengeluaran",
              formatCurrency(totalExpense),
              AppColors.danger,
            ),

            SizedBox(height: 24.h),
            GlobalText.semiBold(
              'Transaksi',
              fontSize: 18.sp,
              color: AppColors.textLight,
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: transactions.length,
                separatorBuilder:
                    (context, index) => Divider(
                      color: AppColors.textLight.withOpacity(0.15),
                      height: 1,
                    ),
                itemBuilder: (context, index) {
                  final item = transactions[index];
                  final bool isIncome = item['isIncome'];
                  final Color itemColor =
                      isIncome ? AppColors.success : AppColors.danger;

                  // GANTI DARI LISTTILE KE ROW UNTUK RATA KIRI
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isIncome ? Icons.trending_up : Icons.trending_down,
                          color: itemColor,
                          size: 22.sp,
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlobalText.regular(
                              item['category'],
                              color: AppColors.textLight,
                              fontSize: 14.sp,
                            ),
                            SizedBox(height: 4.h),
                            GlobalText.regular(
                              item['date'],
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 12.sp,
                            ),
                          ],
                        ),
                        const Spacer(),
                        GlobalText.semiBold(
                          (isIncome ? '+ ' : '- ') +
                              formatCurrency(item['amount']),
                          color: itemColor,
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlobalText.medium(label, fontSize: 16.sp, color: AppColors.textLight),
          GlobalText.semiBold(value, color: valueColor, fontSize: 16.sp),
        ],
      ),
    );
  }
}
