import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart'; // <-- 1. Impor paket

import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/features/home/widgets/finance_summary_card.dart';
import 'package:moneyvesto/features/home/widgets/home_menu_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? lastBackPressed;
  final _key = GlobalKey<ExpandableFabState>(); // <-- 2. Tambahkan GlobalKey

  // --- DATA DUMMY UNTUK WIDGET BARU ---
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'category': 'Makan di Luar',
      'date': 'Hari ini, 13:02',
      'amount': 75000,
      'isIncome': false,
      'icon': Icons.fastfood_outlined,
    },
    {
      'category': 'Gaji Bulanan',
      'date': 'Kemarin, 09:30',
      'amount': 7000000,
      'isIncome': true,
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'category': 'Langganan Streaming',
      'date': '10 Juni 2025',
      'amount': 120000,
      'isIncome': false,
      'icon': Icons.movie_creation_outlined,
    },
  ];

  final Map<String, dynamic> _latestNews = {
    'title': 'IHSG Diprediksi Menguat Terbatas, Cermati Saham BBCA dan MDKA',
    'imageUrl': 'https://picsum.photos/seed/ihsg1/400/300',
    'source': 'Kontan',
  };

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: GlobalText.regular(
            'Press back again to exit',
            color: AppColors.textLight,
          ),
          backgroundColor: AppColors.secondaryAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BaseWidgetContainer(
        backgroundColor: AppColors.background,
        // --- 3. Tambahkan properti FAB ke BaseWidgetContainer ---
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: _buildExpandableFab(),
        // ----------------------------------------------------
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  // --- HEADER PENGGUNA ---
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlobalText.semiBold(
                            'Halo,',
                            fontSize: 18.sp,
                            color: AppColors.textLight.withOpacity(0.8),
                          ),
                          GlobalText.medium(
                            'John Doe',
                            fontSize: 20.sp,
                            color: AppColors.textLight,
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(NavigationRoutes.profile);
                        },
                        child: CircleAvatar(
                          radius: 24.r,
                          backgroundColor: AppColors.secondaryAccent,
                          child: ClipOval(
                            child: Image.network(
                              'https://i.pravatar.cc/150?u=johndoe',
                              fit: BoxFit.cover,
                              width: 48.r,
                              height: 48.r,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    color: AppColors.textLight.withOpacity(0.7),
                                    size: 28.r,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // --- KARTU RINGKASAN KEUANGAN ---
                  FinanceSummaryCard(
                    pengeluaran: 2000000,
                    pemasukan: 7500000,
                    sisaSaldo: 5500000,
                    bulan: 'Juni 2025',
                  ),
                  SizedBox(height: 28.h),

                  // --- TOMBOL MENU UTAMA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomeMenuButton(
                        icon: Icons.receipt_long_outlined,
                        label: 'Report',
                        onTap:
                            () => Get.toNamed(NavigationRoutes.financeReport),
                      ),
                      HomeMenuButton(
                        icon: Icons.pie_chart_outline_rounded,
                        label: 'Analitics',
                        onTap: () => Get.toNamed(NavigationRoutes.analytics),
                      ), // Asumsi analytics ada di chatbot
                      HomeMenuButton(
                        icon: Icons.show_chart_rounded,
                        label: 'Invest',
                        onTap: () => Get.toNamed(NavigationRoutes.invest),
                      ), // Ikon diubah
                      HomeMenuButton(
                        icon: Icons.article_outlined,
                        label: 'News',
                        onTap: () => Get.toNamed(NavigationRoutes.news),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // --- BAGIAN BARU: TRANSAKSI TERAKHIR ---
                  _buildSectionHeader(
                    title: 'Transaksi Terakhir',
                    onTap: () => Get.toNamed(NavigationRoutes.financeReport),
                  ),
                  SizedBox(height: 12.h),
                  _buildRecentTransactionsList(),
                  SizedBox(height: 32.h),

                  // --- BAGIAN BARU: BERITA TERBARU ---
                  _buildSectionHeader(
                    title: 'Berita Terbaru',
                    onTap: () => Get.toNamed(NavigationRoutes.news),
                  ),
                  SizedBox(height: 12.h),
                  _buildLatestNewsCard(),
                  SizedBox(height: 20.h), // Padding bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableFab() {
    return ExpandableFab(
      key: _key,
      distance: 80,
      type: ExpandableFabType.fan,
      fanAngle: 90,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.6),
        blur: 5,
      ),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add_rounded),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.textLight,
        shape: const CircleBorder(),
      ),
      closeButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.close_rounded),
        fabSize: ExpandableFabSize.regular,
        backgroundColor: AppColors.danger,
        foregroundColor: AppColors.textLight,
        shape: const CircleBorder(),
      ),
      children: [
        FloatingActionButton.small(
          heroTag: "expense",
          backgroundColor: AppColors.danger,
          child: const Icon(Icons.arrow_downward_rounded),
          onPressed: () {
            final state = _key.currentState;
            if (state != null && state.isOpen) {
              state.toggle();
            }
            Get.toNamed(NavigationRoutes.chatBot);
          },
        ),
        FloatingActionButton.small(
          heroTag: "chatBot",
          backgroundColor: AppColors.primaryAccent,
          child: const Icon(Icons.smart_toy_outlined),
          onPressed: () {
            final state = _key.currentState;
            if (state != null && state.isOpen) {
              state.toggle();
            }
            Get.toNamed(NavigationRoutes.chatBot);
          },
        ),
        FloatingActionButton.small(
          heroTag: "income",
          backgroundColor: AppColors.success,
          child: const Icon(Icons.arrow_upward_rounded),
          onPressed: () {
            final state = _key.currentState;
            if (state != null && state.isOpen) {
              state.toggle();
            }
            Get.toNamed(NavigationRoutes.chatBot);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlobalText.semiBold(title, fontSize: 18.sp, color: AppColors.textLight),
        GestureDetector(
          onTap: onTap,
          child: GlobalText.medium(
            'Lihat Semua',
            fontSize: 14.sp,
            color: AppColors.primaryAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListView.separated(
        itemCount: _recentTransactions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder:
            (context, index) => Divider(
              color: AppColors.textLight.withOpacity(0.1),
              height: 1.h,
            ),
        itemBuilder: (context, index) {
          final item = _recentTransactions[index];
          final color = item['isIncome'] ? AppColors.success : AppColors.danger;
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              vertical: 4.h,
              horizontal: 8.w,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(item['icon'], color: color, size: 20.sp),
            ),
            title: GlobalText.medium(
              item['category'],
              color: AppColors.textLight,
              fontSize: 14.sp,
              textAlign: TextAlign.start,
            ),
            subtitle: GlobalText.regular(
              item['date'],
              color: AppColors.textLight.withOpacity(0.6),
              fontSize: 12.sp,
              textAlign: TextAlign.start,
            ),
            trailing: GlobalText.semiBold(
              '${item['isIncome'] ? '+' : '-'} ${formatCurrency(item['amount'])}',
              color: color,
              fontSize: 14.sp,
              textAlign: TextAlign.start,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestNewsCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(NavigationRoutes.news),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: NetworkImage(_latestNews['imageUrl']),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalText.regular(
                _latestNews['source'].toUpperCase(),
                color: AppColors.textLight.withOpacity(0.8),
                fontSize: 12.sp,
              ),
              SizedBox(height: 4.h),
              GlobalText.semiBold(
                _latestNews['title'],
                color: AppColors.textLight,
                fontSize: 15.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
