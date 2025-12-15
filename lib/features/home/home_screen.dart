// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/features/home/controller/home_controller.dart';
import 'package:moneyvesto/features/home/widgets/add_transactions.dart';
import 'package:moneyvesto/features/home/widgets/finance_summary_card.dart';
import 'package:moneyvesto/features/home/widgets/home_menu_button.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return WillPopScope(
      onWillPop: () => controller.onWillPop(context),
      child: BaseWidgetContainer(
        backgroundColor: AppColors.background,
        floatingActionButtonLocation: ExpandableFab.location,
        // --- PERUBAHAN 2: Kirim 'context' ke dalam method build FAB ---
        floatingActionButton: _buildExpandableFab(context, controller),
        body: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAccent,
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: controller.fetchAllData,
                    color: AppColors.primaryAccent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),
                              _buildUserHeader(controller),
                              SizedBox(height: 24.h),
                              _buildFinanceSummary(controller),
                              SizedBox(height: 28.h),
                              _buildMainMenu(controller),
                              SizedBox(height: 32.h),
                              _buildSectionHeader(
                                title: 'Transaksi Terakhir',
                                onTap:
                                    () => controller.navigateTo(
                                      NavigationRoutes.financeReport,
                                    ),
                              ),
                              SizedBox(height: 12.h),
                              _buildRecentTransactionsList(controller),
                              SizedBox(height: 32.h),
                              _buildSectionHeader(
                                title: 'Berita Terbaru',
                                onTap:
                                    () => controller.navigateTo(
                                      NavigationRoutes.news,
                                    ),
                              ),
                              SizedBox(height: 12.h),
                              _buildLatestNewsCard(controller),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  // --- PERUBAHAN 3: Method ini sekarang menerima 'BuildContext' ---
  Widget _buildExpandableFab(BuildContext context, HomeController controller) {
    return ExpandableFab(
      key: controller.fabKey,
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
        // --- Tombol Pengeluaran ---
        FloatingActionButton.small(
          heroTag: "expense",
          backgroundColor: AppColors.danger,
          child: const Icon(Icons.arrow_downward_rounded),
          // --- PERUBAHAN 4: Ganti onPressed untuk memanggil dialog ---
          onPressed: () async {
            // Tutup menu FAB secara programatik untuk UX yang lebih baik
            controller.fabKey.currentState?.toggle();

            // Panggil fungsi dialog untuk pengeluaran
            final bool success = await showAndProcessAddTransactionDialog(
              context,
              initialType: TransactionType.withdrawal,
            );

            // Jika transaksi berhasil ditambahkan, refresh data di home
            if (success) {
              controller.fetchAllData();
            }
          },
        ),
        // --- Tombol ChatBot (TETAP SAMA) ---
        FloatingActionButton.small(
          heroTag: "chatBot",
          backgroundColor: AppColors.primaryAccent,
          child: const Icon(Icons.smart_toy_outlined),
          onPressed: controller.navigateToChatBot,
        ),
        // --- Tombol Pemasukan ---
        FloatingActionButton.small(
          heroTag: "income",
          backgroundColor: AppColors.success,
          child: const Icon(Icons.arrow_upward_rounded),
          // --- PERUBAHAN 5: Ganti onPressed untuk memanggil dialog ---
          onPressed: () async {
            // Tutup menu FAB secara programatik
            controller.fabKey.currentState?.toggle();

            // Panggil fungsi dialog untuk pemasukan
            final bool success = await showAndProcessAddTransactionDialog(
              context,
              initialType: TransactionType.deposit,
            );

            // Jika transaksi berhasil ditambahkan, refresh data di home
            if (success) {
              controller.fetchAllData();
            }
          },
        ),
      ],
    );
  }

  // --- Widget lain di bawah ini tidak perlu diubah ---

  Widget _buildUserHeader(HomeController controller) {
    // ... (kode tidak berubah)
    final user = controller.user.value;
    final profileImageUrl = user['profile_image_url'] as String?;

    return Row(
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
              user['username'] ?? 'Guest',
              fontSize: 20.sp,
              color: AppColors.textLight,
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => controller.navigateTo(NavigationRoutes.profile),
          child: CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.secondaryAccent,
            backgroundImage:
                profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
            child:
                (profileImageUrl == null || profileImageUrl.isEmpty)
                    ? Icon(
                      Icons.person,
                      color: AppColors.textLight.withOpacity(0.7),
                      size: 28.r,
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceSummary(HomeController controller) {
    // ... (kode tidak berubah)
    return FinanceSummaryCard(
      pengeluaran: controller.totalExpenses.value.toInt(),
      pemasukan: controller.totalDeposits.value.toInt(),
      sisaSaldo: controller.balance.value.toInt(),
      bulan: DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
    );
  }

  Widget _buildMainMenu(HomeController controller) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      runSpacing: 16.h,
      spacing: 12.w,
      children: [
        HomeMenuButton(
          icon: Icons.receipt_long_outlined,
          label: 'Report',
          onTap: () => controller.navigateTo(NavigationRoutes.financeReport),
        ),
        HomeMenuButton(
          icon: Icons.pie_chart_outline_rounded,
          label: 'Analitics',
          onTap: () => controller.navigateTo(NavigationRoutes.analytics),
        ),
        HomeMenuButton(
          icon: Icons.show_chart_rounded,
          label: 'Invest',
          onTap: () => controller.navigateTo(NavigationRoutes.invest),
        ),
        HomeMenuButton(
          icon: Icons.article_outlined,
          label: 'News',
          onTap: () => controller.navigateTo(NavigationRoutes.news),
        ),
        HomeMenuButton(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Budget',
          onTap: () => controller.navigateTo(NavigationRoutes.budget),
        ),
        HomeMenuButton(
          icon: Icons.emoji_events_outlined,
          label: 'Gamification',
          onTap: () => controller.navigateTo(NavigationRoutes.gamification),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    // ... (kode tidak berubah)
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

  Widget _buildRecentTransactionsList(HomeController controller) {
    // ... (kode tidak berubah)
    return controller.recentTransactions.isEmpty
        ? Container(
          height: 100.h,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: GlobalText.regular(
              "Belum ada transaksi.",
              color: AppColors.textLight.withOpacity(0.6),
            ),
          ),
        )
        : Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.separated(
            itemCount: controller.recentTransactions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            separatorBuilder:
                (context, index) => Divider(
                  color: AppColors.textLight.withOpacity(0.1),
                  height: 1.h,
                ),
            itemBuilder: (context, index) {
              final item = controller.recentTransactions[index];
              final bool isIncome = item['transaction_type'] == 'deposit';
              final color = isIncome ? AppColors.success : AppColors.danger;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4.h,
                  horizontal: 8.w,
                ),
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(
                    controller.getIconForCategory(item['category_name']),
                    color: color,
                    size: 20.sp,
                  ),
                ),
                title: GlobalText.medium(
                  item['description'] ?? 'Tanpa Deskripsi',
                  color: AppColors.textLight,
                  fontSize: 14.sp,
                  textAlign: TextAlign.start,
                ),
                subtitle: GlobalText.regular(
                  controller.formatDate(item['transaction_date']),
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 12.sp,
                  textAlign: TextAlign.start,
                ),
                trailing: GlobalText.semiBold(
                  '${isIncome ? '+' : '-'} ${controller.formatCurrency(item['total_price'] ?? 0)}',
                  color: color,
                  fontSize: 14.sp,
                  textAlign: TextAlign.start,
                ),
              );
            },
          ),
        );
  }

  Widget _buildLatestNewsCard(HomeController controller) {
    // ... (kode tidak berubah)
    return GestureDetector(
      onTap: () => controller.navigateTo(NavigationRoutes.news),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: NetworkImage(controller.latestNews['imageUrl']!),
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
                controller.latestNews['source']!.toUpperCase(),
                color: AppColors.textLight.withOpacity(0.8),
                fontSize: 12.sp,
              ),
              SizedBox(height: 4.h),
              GlobalText.semiBold(
                controller.latestNews['title']!,
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
