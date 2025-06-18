import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data dummy untuk transaksi di bulan Juni 2025
  final List<Map<String, dynamic>> _transactions = [
    {
      'category': 'Gaji',
      'amount': 7500000,
      'isIncome': true,
      'date': DateTime(2025, 6, 1),
    },
    {
      'category': 'Makan',
      'amount': 75000,
      'isIncome': false,
      'date': DateTime(2025, 6, 2),
    },
    {
      'category': 'Transportasi',
      'amount': 50000,
      'isIncome': false,
      'date': DateTime(2025, 6, 2),
    },
    {
      'category': 'Belanja',
      'amount': 350000,
      'isIncome': false,
      'date': DateTime(2025, 6, 3),
    },
    {
      'category': 'Freelance',
      'amount': 1500000,
      'isIncome': true,
      'date': DateTime(2025, 6, 5),
    },
    {
      'category': 'Makan',
      'amount': 120000,
      'isIncome': false,
      'date': DateTime(2025, 6, 5),
    },
    {
      'category': 'Hiburan',
      'amount': 250000,
      'isIncome': false,
      'date': DateTime(2025, 6, 7),
    },
    {
      'category': 'Transportasi',
      'amount': 60000,
      'isIncome': false,
      'date': DateTime(2025, 6, 8),
    },
    {
      'category': 'Makan',
      'amount': 80000,
      'isIncome': false,
      'date': DateTime(2025, 6, 9),
    },
    {
      'category': 'Tagihan',
      'amount': 850000,
      'isIncome': false,
      'date': DateTime(2025, 6, 10),
    },
    {
      'category': 'Kesehatan',
      'amount': 175000,
      'isIncome': false,
      'date': DateTime(2025, 6, 11),
    },
    {
      'category': 'Makan',
      'amount': 95000,
      'isIncome': false,
      'date': DateTime(2025, 6, 12),
    },
  ];

  // Palet warna untuk chart
  final List<Color> _chartColors = [
    AppColors.primaryAccent,
    AppColors.success,
    Colors.cyan,
    Colors.purpleAccent,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    // Logika sederhana untuk filter data (di aplikasi nyata, ini lebih kompleks)
    final totalIncome = _transactions
        .where((t) => t['isIncome'])
        .fold<double>(0, (sum, t) => sum + t['amount']);
    final totalExpense = _transactions
        .where((t) => !t['isIncome'])
        .fold<double>(0, (sum, t) => sum + t['amount']);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: GlobalText.medium(
          'Analisis Keuangan',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.6),
          tabs: [
            Tab(child: GlobalText.regular('Minggu Ini', fontSize: 14.sp)),
            Tab(child: GlobalText.regular('Bulan Ini', fontSize: 14.sp)),
            Tab(child: GlobalText.regular('Tahun Ini', fontSize: 14.sp)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildSummaryCard(totalIncome, totalExpense),
              SizedBox(height: 28.h),
              _buildExpenseBreakdownCard(totalExpense),
              SizedBox(height: 28.h),
              _buildCashFlowTrendCard(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double income, double expense) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Pemasukan', income, AppColors.success),
          Container(
            width: 1.w,
            height: 50.h,
            color: AppColors.textLight.withOpacity(0.2),
          ),
          _buildSummaryItem('Pengeluaran', expense, AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        GlobalText.regular(
          title,
          fontSize: 14.sp,
          color: AppColors.textLight.withOpacity(0.7),
        ),
        SizedBox(height: 8.h),
        GlobalText.semiBold(
          _formatCurrency(amount),
          fontSize: 16.sp,
          color: color,
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownCard(double totalExpense) {
    Map<String, double> expenseByCategory = {};
    _transactions.where((t) => !t['isIncome']).forEach((t) {
      expenseByCategory.update(
        t['category'],
        (value) => value + t['amount'],
        ifAbsent: () => t['amount'],
      );
    });

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalText.semiBold(
            'Rincian Pengeluaran',
            fontSize: 16.sp,
            color: AppColors.textLight,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 160.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40.r,
                sections: List.generate(expenseByCategory.length, (i) {
                  final value = expenseByCategory.values.elementAt(i);
                  final percentage = (value / totalExpense) * 100;
                  return PieChartSectionData(
                    color: _chartColors[i % _chartColors.length],
                    value: value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 45.r,
                    titleStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ...List.generate(expenseByCategory.length, (i) {
            final category = expenseByCategory.keys.elementAt(i);
            final value = expenseByCategory.values.elementAt(i);
            return _buildCategoryListItem(
              color: _chartColors[i % _chartColors.length],
              category: category,
              amount: value,
              percentage: (value / totalExpense) * 100,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem({
    required Color color,
    required String category,
    required double amount,
    required double percentage,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          GlobalText.regular(
            category,
            fontSize: 14.sp,
            color: AppColors.textLight,
          ),
          const Spacer(),
          GlobalText.semiBold(
            _formatCurrency(amount),
            fontSize: 14.sp,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowTrendCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalText.semiBold(
            'Tren Arus Kas (Juni)',
            fontSize: 16.sp,
            color: AppColors.textLight,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.textLight.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.h,
                      interval: 5,
                      getTitlesWidget:
                          (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.6),
                              fontSize: 12.sp,
                            ),
                          ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 12, // Sampai tanggal 12 Juni
                minY: 0,
                maxY: 8000000, // Sedikit di atas gaji
                lineBarsData: [
                  _buildLineChartBarData(true), // Income
                  _buildLineChartBarData(false), // Expense
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(bool isIncome) {
    List<FlSpot> spots = [];
    _transactions.where((t) => t['isIncome'] == isIncome).forEach((t) {
      spots.add(FlSpot(t['date'].day.toDouble(), t['amount'].toDouble()));
    });
    // Menambahkan titik nol agar garis tidak terputus
    if (spots.isEmpty || spots.first.x != 1) spots.insert(0, FlSpot(1, 0));
    if (spots.last.x != 12) spots.add(FlSpot(12, 0));

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: isIncome ? AppColors.success : AppColors.danger,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: (isIncome ? AppColors.success : AppColors.danger).withOpacity(
          0.1,
        ),
      ),
    );
  }
}
