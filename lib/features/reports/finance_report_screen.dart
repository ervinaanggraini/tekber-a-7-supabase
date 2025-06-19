import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// --- SESUAIKAN PATH IMPOR INI ---
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/data/transaction_datasource.dart';

class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  // Gunakan implementasi data source untuk mengambil data
  final TransactionDataSource _transactionDataSource =
      TransactionDataSourceImpl();

  // State untuk menampung data yang sudah ditransformasi
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String selectedMonth = 'Bulan'; // Nilai awal sebelum data dimuat

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    try {
      // Mengambil data dari TransactionDataSource
      final response = await _transactionDataSource.getTransactions(size: 100);

      if (response.statusCode == 200 && response.data['data'] != null) {
        List<dynamic> fetchedTransactions = response.data['data'];

        if (fetchedTransactions.isEmpty) {
          setState(() => isLoading = false);
          return;
        }

        // Tentukan format input dari API. Locale 'en_US' digunakan karena
        // nama hari dan bulan (Thu, Jun) dalam bahasa Inggris.
        final inputFormat = DateFormat('E, d MMM yyyy HH:mm:ss z', 'en_US');

        // Tentukan format output yang diinginkan dalam bahasa Indonesia.
        final outputFormat = DateFormat('d MMMM yyyy', 'id_ID');

        final transformedTransactions =
            fetchedTransactions.map((trx) {
              // 1. Parse string dari API menggunakan format yang benar
              final DateTime createdAt = inputFormat.parse(trx['created_at']);

              // 2. Format objek DateTime ke string yang diinginkan
              final String formattedDate = outputFormat.format(createdAt);

              return {
                'date': formattedDate,
                'category': trx['description'],
                'amount': (trx['total_price'] as num).toInt(),
                'isIncome': trx['transaction_type'] == 'deposit',
                'day': createdAt.day, // Tambahkan hari untuk data chart
              };
            }).toList();

        // Atur bulan yang dipilih berdasarkan data pertama
        final firstDateString = fetchedTransactions[0]['created_at'];
        final firstTransactionDate = inputFormat.parse(firstDateString);

        setState(() {
          transactions = transformedTransactions;
          selectedMonth = DateFormat(
            'MMMM yyyy',
            'id_ID',
          ).format(firstTransactionDate);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load transactions: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar('Error', 'Gagal memuat data transaksi');
    }
  }

  int get totalIncome => transactions
      .where((e) => e['isIncome'] == true)
      .fold(0, (sum, e) => sum + e['amount'] as int);

  int get totalExpense => transactions
      .where((e) => e['isIncome'] == false)
      .fold(0, (sum, e) => sum + e['amount'] as int);

  String formatCurrency(int amount) {
    // Format angka ke format Rupiah (contoh: Rp 1.500.000)
    return 'Rp ${NumberFormat.decimalPattern('id_ID').format(amount)}';
  }

  // Membuat data BarChart secara dinamis
  List<BarChartGroupData> _generateBarGroups() {
    return transactions.map((trx) {
      return BarChartGroupData(
        x: trx['day'],
        barRods: [
          BarChartRodData(
            // Normalisasi nilai agar chart terlihat bagus
            // Di sini, kita bagi dengan 1,000,000 agar menjadi satuan juta
            toY: trx['amount'] / 1000000.0,
            color: trx['isIncome'] ? AppColors.success : AppColors.danger,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : transactions.isEmpty
              ? Center(
                child: GlobalText.regular(
                  'Tidak ada data transaksi.',
                  color: AppColors.textLight,
                ),
              )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 24.h, top: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
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
                            [selectedMonth] // Dibuat statis untuk contoh ini
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

                    // CHART: Bar chart dengan data dinamis
                    SizedBox(
                      height: 200.h,
                      child: BarChart(
                        BarChartData(
                          barGroups: _generateBarGroups(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: GlobalText.regular(
                                      value.toInt().toString(),
                                      color: AppColors.textLight.withOpacity(
                                        0.7,
                                      ),
                                      fontSize: 12.sp,
                                    ),
                                  );
                                },
                                reservedSize: 28,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2, // Interval 2Jt
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) {
                                    return GlobalText.regular(
                                      '0',
                                      color: AppColors.textLight.withOpacity(
                                        0.7,
                                      ),
                                      fontSize: 12.sp,
                                    );
                                  }
                                  return GlobalText.regular(
                                    '${value.toInt()}Jt',
                                    color: AppColors.textLight.withOpacity(0.7),
                                    fontSize: 12.sp,
                                  );
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
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                String amountText = formatCurrency(
                                  (rod.toY * 1000000).toInt(),
                                );
                                String type =
                                    rod.color == AppColors.success
                                        ? "Pemasukan"
                                        : "Pengeluaran";
                                return BarTooltipItem(
                                  '$type\n',
                                  TextStyle(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: amountText,
                                      style: TextStyle(
                                        color: rod.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            handleBuiltInTouches: true,
                          ),
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

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  isIncome
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: itemColor,
                                  size: 22.sp,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GlobalText.regular(
                                        item['category'],
                                        color: AppColors.textLight,
                                        fontSize: 14.sp,
                                      ),
                                      SizedBox(height: 4.h),
                                      GlobalText.regular(
                                        item['date'],
                                        color: AppColors.textLight.withOpacity(
                                          0.7,
                                        ),
                                        fontSize: 12.sp,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
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
