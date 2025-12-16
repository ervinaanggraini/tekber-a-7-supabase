import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/data/budget_datasource.dart';
import 'package:moneyvesto/data/transaction_datasource.dart';

class BudgetController extends GetxController {
  final BudgetDataSource _budgetDataSource = BudgetDataSourceImpl();
  final TransactionDataSource _transactionDataSource = TransactionDataSourceImpl();

  final isLoading = true.obs;
  final budgets = <Map<String, dynamic>>[].obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final budgetProgress = <String, double>{}.obs; // Category -> Spent Amount

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading(true);
    try {
      await Future.wait([
        fetchBudgets(),
        fetchTransactions(),
      ]);
      calculateProgress();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat data budget: ${e.toString()}",
        backgroundColor: AppColors.danger,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBudgets() async {
    final response = await _budgetDataSource.getBudgets();
    if (response.statusCode == 200 && response.data['data'] != null) {
      budgets.assignAll(List<Map<String, dynamic>>.from(response.data['data']));
    }
  }

  Future<void> fetchTransactions() async {
    // Fetch all transactions to calculate spending
    // Assuming size 1000 is enough for now, or we need a better way to get aggregate data from backend
    final response = await _transactionDataSource.getTransactions(size: 1000);
    if (response.statusCode == 200 && response.data['data'] != null) {
      transactions.assignAll(List<Map<String, dynamic>>.from(response.data['data']));
    }
  }

  void calculateProgress() {
    final progress = <String, double>{};
    
    // Initialize with 0 for all budget categories
    for (var budget in budgets) {
      progress[budget['category']] = 0.0;
    }

    // Sum expenses per category
    for (var transaction in transactions) {
      if (transaction['transaction_type'] == 'withdrawal') {
        // Assuming transaction has 'description' which might be used as category or we need to match it
        // Since we don't have explicit category in transaction yet, we might need to rely on description matching or add category to transaction.
        // For now, let's assume description IS the category or contains it.
        // Or better, let's try to match description to budget category.
        
        // NOTE: Ideally, Transaction should have a 'category' field.
        // For this implementation, I will assume the user inputs the category name in description 
        // or we map it somehow. 
        // Let's try to match exact string for now.
        
        String category = transaction['description']; // Temporary mapping
        // If we have a budget for this category (case insensitive)
        String? matchedCategory;
        for (var key in progress.keys) {
          if (key.toLowerCase() == category.toLowerCase()) {
            matchedCategory = key;
            break;
          }
        }

        if (matchedCategory != null) {
          progress[matchedCategory] = (progress[matchedCategory] ?? 0) + (transaction['amount'] as num).toDouble();
        }
      }
    }
    budgetProgress.assignAll(progress);
  }

  Future<void> addBudget(String category, double amount) async {
    try {
      final response = await _budgetDataSource.createBudget({
        'category': category,
        'amount': amount,
        'period': 'monthly'
      });
      
      if (response.statusCode == 201) {
        Get.back(); // Close dialog
        Get.snackbar("Sukses", "Budget berhasil ditambahkan", backgroundColor: AppColors.success, colorText: AppColors.textLight);
        fetchData();
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah budget: ${e.toString()}", backgroundColor: AppColors.danger, colorText: AppColors.textLight);
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      final response = await _budgetDataSource.deleteBudget(id);
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Budget berhasil dihapus", backgroundColor: AppColors.success, colorText: AppColors.textLight);
        fetchData();
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus budget: ${e.toString()}", backgroundColor: AppColors.danger, colorText: AppColors.textLight);
    }
  }
}
