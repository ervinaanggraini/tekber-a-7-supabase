import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
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
      'date': '23 Mei 2025',
      'category': 'Bonus Project',
      'amount': 2000000,
      'isIncome': true,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GlobalText.medium(
          'Laporan',
          color: Colors.black,
          fontSize: 20.sp,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedMonth,
              iconEnabledColor: Colors.black,
              style: TextStyle(color: Colors.black, fontSize: 16.sp),
              underline: Container(height: 1, color: Colors.black12),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedMonth = value);
                }
              },
              items:
                  ['Mei 2025']
                      .map<DropdownMenuItem<String>>(
                        (month) =>
                            DropdownMenuItem(value: month, child: Text(month)),
                      )
                      .toList(),
            ),

            SizedBox(height: 24.h),

            // CHART: Bar chart harian
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
                          color: Colors.red,
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
                          color: Colors.green,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0');
                          if (value == 5) return const Text('5M');
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Summary
            _buildSummaryRow(
              "Total Pemasukan",
              formatCurrency(totalIncome),
              Colors.green,
            ),
            _buildSummaryRow(
              "Total Pengeluaran",
              formatCurrency(totalExpense),
              Colors.red,
            ),

            SizedBox(height: 16.h),
            GlobalText.semiBold(
              'Transaksi',
              fontSize: 16.sp,
              color: Colors.black,
            ),

            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final item = transactions[index];
                  return ListTile(
                    leading: Icon(
                      item['isIncome']
                          ? Icons.trending_up
                          : Icons.shopping_cart,
                      color: item['isIncome'] ? Colors.green : Colors.red,
                    ),
                    title: Text(item['category']),
                    subtitle: Text(item['date']),
                    trailing: Text(
                      (item['isIncome'] ? '+ ' : '- ') +
                          formatCurrency(item['amount']),
                      style: TextStyle(
                        color: item['isIncome'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlobalText.medium(label, fontSize: 16.sp),
          GlobalText.semiBold(value, color: valueColor, fontSize: 16.sp),
        ],
      ),
    );
  }
}
