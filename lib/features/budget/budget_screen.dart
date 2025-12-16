import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/features/budget/controller/budget_controller.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BudgetController());

    return BaseWidgetContainer(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GlobalText.semiBold("Budget Management", fontSize: 18.sp, color: AppColors.textLight),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        onPressed: () => _showAddBudgetDialog(context, controller),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
        }

        if (controller.budgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 64.sp, color: AppColors.textLight.withOpacity(0.5)),
                SizedBox(height: 16.h),
                GlobalText.medium("Belum ada budget", color: AppColors.textLight.withOpacity(0.5)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.budgets.length,
          itemBuilder: (context, index) {
            final budget = controller.budgets[index];
            final category = budget['category'];
            final limit = (budget['amount'] as num).toDouble();
            final spent = controller.budgetProgress[category] ?? 0.0;
            final progress = (spent / limit).clamp(0.0, 1.0);
            final isOverBudget = spent > limit;

            return Card(
              color: AppColors.cardBackground,
              margin: EdgeInsets.only(bottom: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlobalText.semiBold(category, fontSize: 16.sp, color: AppColors.textLight),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () => controller.deleteBudget(budget['id']),
                        )
                      ],
                    ),
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.background,
                      color: isOverBudget ? AppColors.danger : AppColors.primaryAccent,
                      minHeight: 8.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlobalText.regular(
                          "Terpakai: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(spent)}",
                          fontSize: 12.sp,
                          color: isOverBudget ? AppColors.danger : AppColors.textLight.withOpacity(0.8),
                        ),
                        GlobalText.regular(
                          "Limit: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(limit)}",
                          fontSize: 12.sp,
                          color: AppColors.textLight.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddBudgetDialog(BuildContext context, BudgetController controller) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: GlobalText.semiBold("Tambah Budget", color: AppColors.textLight),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: "Kategori (misal: Makanan)",
                labelStyle: TextStyle(color: AppColors.textLight),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textLight)),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textLight),
              decoration: const InputDecoration(
                labelText: "Jumlah Limit (Rp)",
                labelStyle: TextStyle(color: AppColors.textLight),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textLight)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal", style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent),
            onPressed: () {
              if (categoryController.text.isNotEmpty && amountController.text.isNotEmpty) {
                controller.addBudget(
                  categoryController.text,
                  double.tryParse(amountController.text) ?? 0.0,
                );
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
