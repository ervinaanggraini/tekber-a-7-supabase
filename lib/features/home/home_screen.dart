import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;

      // Tampilkan snackbar atau toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
        ),
      );
      return false; // Gak keluar aplikasi
    }

    return true; // Keluar aplikasi
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BaseWidgetContainer(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlobalText.semiBold('Halo,', fontSize: 16.sp),
                          GlobalText.medium('John Doe', fontSize: 14.sp),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(NavigationRoutes.profile);
                        },
                        child: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.grey.shade300,
                          child: ClipOval(
                            child: Image.network(
                              'https://picsum.photos/200/300',
                              fit: BoxFit.cover,
                              width: 40.r,
                              height: 40.r,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  FinanceSummaryCard(
                    pengeluaran: 2000000,
                    pemasukan: 5000000,
                    sisaSaldo: 4998000,
                    bulan: 'Mei 2025',
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomeMenuButton(
                        icon: Icons.receipt_long,
                        label: 'Laporan',
                        onTap: () {
                          Get.toNamed(NavigationRoutes.financeReport);
                        },
                      ),
                      HomeMenuButton(
                        icon: Icons.pie_chart,
                        label: 'Analisa',
                        onTap: () {
                          Get.toNamed(NavigationRoutes.chatBot);
                        },
                      ),
                      HomeMenuButton(
                        icon: Icons.group,
                        label: 'Patungan',
                        isActive: false,
                      ),
                      HomeMenuButton(
                        icon: Icons.edit_note,
                        label: 'Catatan',
                        isActive: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
