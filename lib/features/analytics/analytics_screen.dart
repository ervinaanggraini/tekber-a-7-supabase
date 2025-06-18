import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'dart:math'; // Added for max value calculation

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data dummy untuk transaksi di bulan Juni 2025
  // This is the master list of all transactions
  final List<Map<String, dynamic>> _allTransactions = [
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
    // Added data for "This Week" demonstration (assuming today is June 18, 2025)
    {
      'category': 'Makan',
      'amount': 110000,
      'isIncome': false,
      'date': DateTime(2025, 6, 16),
    },
    {
      'category': 'Proyek Sampingan',
      'amount': 2500000,
      'isIncome': true,
      'date': DateTime(2025, 6, 17),
    },
    {
      'category': 'Transportasi',
      'amount': 45000,
      'isIncome': false,
      'date': DateTime(2025, 6, 18),
    },
  ];

  // Palet warna untuk chart
  final List<Color> _chartColors = [
    AppColors.primaryAccent,
    AppColors.success,
    Colors.cyan,
    Colors.purpleAccent,
    Colors.orange,
    Colors.redAccent,
    Colors.blueAccent,
  ];

  // State variables that will be updated based on the selected tab
  late List<Map<String, dynamic>> _filteredTransactions;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  String _cashFlowChartTitle = '';

  @override
  void initState() {
    super.initState();
    _filteredTransactions = [];
    _tabController = TabController(length: 3, vsync: this);
    // Add a listener to the TabController to update data when the tab changes
    _tabController.addListener(_handleTabSelection);
    // Set the initial filter for the default tab (Bulan Ini)
    _filterData(1); // 0: Week, 1: Month, 2: Year
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Avoid running filter logic twice for an animation
    } else {
      _filterData(_tabController.index);
    }
  }

  void _filterData(int tabIndex) {
    final now = DateTime(
      2025,
      6,
      18,
    ); // Using a fixed 'now' for consistent demo
    DateTime startDate;
    DateTime endDate = now;

    switch (tabIndex) {
      case 0: // Minggu Ini
        startDate = now.subtract(Duration(days: now.weekday - 1));
        _cashFlowChartTitle = 'Tren Arus Kas (Minggu Ini)';
        break;
      case 1: // Bulan Ini
        startDate = DateTime(now.year, now.month, 1);
        _cashFlowChartTitle =
            'Tren Arus Kas (${DateFormat('MMMM yyyy').format(now)})';
        break;
      case 2: // Tahun Ini
        startDate = DateTime(now.year, 1, 1);
        _cashFlowChartTitle = 'Tren Arus Kas (${now.year})';
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    setState(() {
      _filteredTransactions =
          _allTransactions.where((t) {
            final date = t['date'] as DateTime;
            return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                date.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

      _totalIncome = _filteredTransactions
          .where((t) => t['isIncome'])
          .fold<double>(0, (sum, t) => sum + t['amount']);

      _totalExpense = _filteredTransactions
          .where((t) => !t['isIncome'])
          .fold<double>(0, (sum, t) => sum + t['amount']);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    return 'Rp ${NumberFormat("#,##0", "id_ID").format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          indicatorColor: AppColors.textLight,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.6),
          tabs: [
            Tab(child: GlobalText.regular('Minggu Ini', fontSize: 14.sp, color: AppColors.textLight,)),
            Tab(child: GlobalText.regular('Bulan Ini', fontSize: 14.sp, color: AppColors.textLight,)),
            Tab(child: GlobalText.regular('Tahun Ini', fontSize: 14.sp, color: AppColors.textLight,)),
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
              _buildSummaryCard(_totalIncome, _totalExpense),
              SizedBox(height: 28.h),
              // Only build charts if there is data to prevent errors
              if (_filteredTransactions.isNotEmpty) ...[
                _buildExpenseBreakdownCard(),
                SizedBox(height: 28.h),
                _buildCashFlowTrendCard(),
                SizedBox(height: 20.h),
              ] else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50.h),
        child: GlobalText.regular(
          'Tidak ada data untuk periode ini.',
          color: AppColors.textLight.withOpacity(0.6),
          fontSize: 16.sp,
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

  Widget _buildExpenseBreakdownCard() {
    Map<String, double> expenseByCategory = {};
    _filteredTransactions.where((t) => !t['isIncome']).forEach((t) {
      expenseByCategory.update(
        t['category'],
        (value) => value + (t['amount'] as num),
        ifAbsent: () => (t['amount'] as num).toDouble(),
      );
    });

    // FIXED: Handle case where there are no expenses to avoid division by zero
    if (_totalExpense == 0) {
      return Container(); // Or a widget saying "No expenses"
    }

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
                  final percentage = (value / _totalExpense) * 100;
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
    // FIXED: Aggregate data by day to handle multiple transactions on the same day.
    Map<int, double> dailyIncome = {};
    Map<int, double> dailyExpense = {};

    _filteredTransactions.forEach((t) {
      final day = (t['date'] as DateTime).day;
      final amount = (t['amount'] as num).toDouble();
      if (t['isIncome']) {
        dailyIncome.update(
          day,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      } else {
        dailyExpense.update(
          day,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    });

    List<FlSpot> incomeSpots =
        dailyIncome.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
    List<FlSpot> expenseSpots =
        dailyExpense.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();

    // Sort spots by day to ensure the line is drawn correctly
    incomeSpots.sort((a, b) => a.x.compareTo(b.x));
    expenseSpots.sort((a, b) => a.x.compareTo(b.x));

    // FIXED: Dynamically calculate max values for the chart axes
    final maxIncome = dailyIncome.values.fold(
      0.0,
      (prev, element) => max(prev, element),
    );
    final maxExpense = dailyExpense.values.fold(
      0.0,
      (prev, element) => max(prev, element),
    );
    final maxY = max(maxIncome, maxExpense) * 1.2; // Add 20% padding

    final now = DateTime(2025, 6, 18);
    final maxX =
        DateTime(
          now.year,
          now.month + 1,
          0,
        ).day.toDouble(); // Days in current month

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
            _cashFlowChartTitle, // FIXED: Dynamic chart title
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
                      interval:
                          5, // Keep interval simple, can be made more dynamic
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
                maxX: maxX, // FIXED: Dynamic max X
                minY: 0,
                maxY: maxY, // FIXED: Dynamic max Y
                lineBarsData: [
                  _buildLineChartBarData(incomeSpots, true),
                  _buildLineChartBarData(expenseSpots, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, bool isIncome) {
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
