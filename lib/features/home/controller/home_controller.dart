// lib/features/home/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart'; // DIKEMBALIKAN
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart';
import 'package:moneyvesto/data/transaction_datasource.dart';

class HomeController extends GetxController {
  // --- DEPENDENCIES ---
  final TransactionDataSource _dataSource = TransactionDataSourceImpl();
  final SharedPreferencesUtils _prefsUtils = SharedPreferencesUtils();

  // --- UI STATE ---
  final isLoading = true.obs;
  DateTime? lastBackPressed;
  final fabKey = GlobalKey<ExpandableFabState>(); // DIKEMBALIKAN

  // --- DATA (menggunakan Map<String, dynamic>) ---
  final user = Rx<Map<String, dynamic>>({'name': 'Guest'});
  final totalExpenses = 0.0.obs;
  final totalDeposits = 0.0.obs;
  final balance = 0.0.obs;
  final recentTransactions = <Map<String, dynamic>>[].obs;
  final latestNews =
      {
        'title':
            'IHSG Diprediksi Menguat Terbatas, Cermati Saham BBCA dan MDKA',
        'imageUrl': 'https://picsum.photos/seed/ihsg1/400/300',
        'source': 'Kontan',
      }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  // --- DATA FETCHING ---
  Future<void> fetchAllData() async {
    isLoading(true);
    try {
      await Future.wait([
        _fetchUserData(),
        _fetchFinancialSummary(),
        _fetchRecentTransactions(),
      ]);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat data: ${e.toString()}",
        backgroundColor: AppColors.danger,
        colorText: AppColors.textLight,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchUserData() async {
    final userData = _prefsUtils.getData('currentUser');
    print('User data: $userData');
    if (userData != null) {
      user.value = userData; // simpan seluruh objek
    }
  }

  Future<void> _fetchFinancialSummary() async {
    final result = await _dataSource.calculateExpensesAndDeposits();
    totalDeposits.value = result['total_deposits'] ?? 0.0;
    totalExpenses.value = result['total_expenses'] ?? 0.0;
    balance.value = totalDeposits.value - totalExpenses.value;
  }

  Future<void> _fetchRecentTransactions() async {
    final response = await _dataSource.getTransactions(size: 3, order: 'desc');
    if (response.statusCode == 200 && response.data['data'] != null) {
      final List<dynamic> data = response.data['data'];
      recentTransactions.assignAll(List<Map<String, dynamic>>.from(data));
    }
  }

  // --- UI LOGIC & NAVIGATION ---
  Future<bool> onWillPop(BuildContext context) async {
    final now = DateTime.now();
    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit',
            style: TextStyle(color: AppColors.textLight),
          ),
          backgroundColor: AppColors.secondaryAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  void navigateTo(String route) {
    Get.toNamed(route);
  }

  // LOGIKA UNTUK FAB DIKEMBALIKAN
  void navigateToChatBot() {
    final state = fabKey.currentState;
    if (state != null && state.isOpen) {
      state.toggle();
    }
    Get.toNamed(NavigationRoutes.chatBot);
  }

  // --- UTILS ---
  IconData getIconForCategory(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'gaji':
        return Icons.account_balance_wallet_outlined;
      case 'makanan':
        return Icons.fastfood_outlined;
      case 'transportasi':
        return Icons.directions_car_outlined;
      case 'langganan':
      case 'hiburan':
        return Icons.movie_creation_outlined;
      case 'belanja':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.money_outlined;
    }
  }

  String formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "Tanggal tidak tersedia";

    final date = DateTime.tryParse(dateString);
    if (date == null) return "Format tanggal salah";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini, ${DateFormat.Hm('id_ID').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Kemarin, ${DateFormat.Hm('id_ID').format(date)}';
    } else {
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
    }
  }
}
