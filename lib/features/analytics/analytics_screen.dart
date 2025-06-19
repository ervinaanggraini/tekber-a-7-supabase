import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// --- SESUAIKAN PATH IMPOR INI ---
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/data/transaction_datasource.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransactionDataSource _transactionDataSource =
      TransactionDataSourceImpl();

  // Daftar ini sekarang akan diisi dari API
  List<Map<String, dynamic>> _allTransactions = [];

  // State variables
  bool _isLoading = true;
  late List<Map<String, dynamic>> _filteredTransactions;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  String _cashFlowChartTitle = '';

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

  @override
  void initState() {
    super.initState();
    _filteredTransactions = [];
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    ); // Default ke "Bulan Ini"
    _tabController.addListener(_handleTabSelection);
    _loadAndProcessData(); // Memuat data saat screen pertama kali dibuka
  }

  Future<void> _loadAndProcessData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data dalam jumlah besar untuk mencakup filter tahunan
      final response = await _transactionDataSource.getTransactions(size: 1000);

      if (response.statusCode == 200 && response.data['data'] != null) {
        List<dynamic> fetchedTransactions = response.data['data'];
        final inputFormat = DateFormat('E, d MMM yyyy HH:mm:ss z', 'en_US');

        // Transformasi data API ke format yang dibutuhkan UI
        _allTransactions =
            fetchedTransactions.map((trx) {
              return {
                'category': trx['description'],
                'amount': (trx['total_price'] as num).toDouble(),
                'isIncome': trx['transaction_type'] == 'deposit',
                'date': inputFormat.parse(trx['created_at']),
              };
            }).toList();

        // Setelah data dimuat, terapkan filter awal
        _filterData(_tabController.index);
      }
    } catch (e) {
      print("Failed to load analytics data: $e");
      // Anda bisa menampilkan pesan error di sini jika perlu
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _filterData(_tabController.index);
    }
  }

  void _filterData(int tabIndex) {
    // ---- MENGGUNAKAN WAKTU SEBENARNYA (DINAMIS) ----
    final now = DateTime.now();
    // Untuk demo, jika ingin tanggal tetap, gunakan:
    // final now = DateTime(2025, 6, 19);
    // ----------------------------------------------------

    DateTime startDate;
    // Tentukan endDate sebagai akhir hari ini agar data hari ini masuk
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (tabIndex) {
      case 0: // Minggu Ini (Senin hingga hari ini)
        startDate = now.subtract(Duration(days: now.weekday - 1));
        _cashFlowChartTitle = 'Tren Arus Kas (Minggu Ini)';
        break;
      case 1: // Bulan Ini
        startDate = DateTime(now.year, now.month, 1);
        _cashFlowChartTitle =
            'Tren Arus Kas (${DateFormat('MMMM yyyy', 'id_ID').format(now)})';
        break;
      case 2: // Tahun Ini
        startDate = DateTime(now.year, 1, 1);
        _cashFlowChartTitle = 'Tren Arus Kas (${now.year})';
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    // Set startDate ke awal hari
    startDate = DateTime(startDate.year, startDate.month, startDate.day);

    setState(() {
      _filteredTransactions =
          _allTransactions.where((t) {
            final date = t['date'] as DateTime;
            // Cek apakah tanggal berada di antara startDate (inklusif) dan endDate (inklusif)
            return !date.isBefore(startDate) && !date.isAfter(endDate);
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
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.6),
          tabs: [
            Tab(child: GlobalText.regular('Minggu Ini', fontSize: 14.sp, color: AppColors.textLight,)),
            Tab(child: GlobalText.regular('Bulan Ini', fontSize: 14.sp, color: AppColors.textLight,)),
            Tab(child: GlobalText.regular('Tahun Ini', fontSize: 14.sp, color: AppColors.textLight,)),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildSummaryCard(_totalIncome, _totalExpense),
                      SizedBox(height: 28.h),
                      if (_filteredTransactions.isNotEmpty) ...[
                        // Hanya build chart jika ada pengeluaran
                        if (_totalExpense > 0) ...[
                          _buildExpenseBreakdownCard(),
                          SizedBox(height: 28.h),
                        ],
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

  // --- SEMUA WIDGET PEMBANTU (BUILD HELPER) DI BAWAH INI TIDAK PERLU DIUBAH ---
  // --- KARENA MEREKA SUDAH MEMBACA DARI STATE YANG DINAMIS ---

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

    if (_totalExpense == 0) {
      return Container();
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

    incomeSpots.sort((a, b) => a.x.compareTo(b.x));
    expenseSpots.sort((a, b) => a.x.compareTo(b.x));

    final maxIncome = dailyIncome.values.fold(
      0.0,
      (prev, element) => max(prev, element),
    );
    final maxExpense = dailyExpense.values.fold(
      0.0,
      (prev, element) => max(prev, element),
    );
    final maxY = max(maxIncome, maxExpense) * 1.2;

    final now = DateTime.now();
    final maxX = DateTime(now.year, now.month + 1, 0).day.toDouble();

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
            _cashFlowChartTitle,
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
                maxX: maxX,
                minY: 0,
                maxY: maxY > 0 ? maxY : 100000, // Handle case where maxY is 0
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
