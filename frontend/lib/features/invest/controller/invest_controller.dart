import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/data/invest_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InvestController extends GetxController {
  final InvestDataSource _dataSource = InvestDataSource();
  
  // State
  final isLoading = true.obs;
  final virtualCash = 100000000.0.obs;
  final xp = 0.obs;
  final level = 1.obs;
  final myAssets = <Map<String, dynamic>>[].obs;
  final transactionHistory = <Map<String, dynamic>>[].obs;
  
  // Market Simulation
  final simulatedMarketAssets = <Map<String, dynamic>>[
    {
      'code': 'BBCA',
      'name': 'Bank Central Asia Tbk.',
      'type': 'Finansial',
      'price': 9750.0,
      'lastChange': 0.0,
      'icon': Icons.account_balance_wallet,
      'priceHistory': <double>[],
    },
    {
      'code': 'GOTO',
      'name': 'GoTo Gojek Tokopedia Tbk',
      'type': 'Teknologi',
      'price': 54.0,
      'lastChange': 0.0,
      'icon': Icons.apps_rounded,
      'priceHistory': <double>[],
    },
    {
      'code': 'ADRO',
      'name': 'Adaro Energy Tbk.',
      'type': 'Energi',
      'price': 2750.0,
      'lastChange': 0.0,
      'icon': Icons.local_fire_department,
      'priceHistory': <double>[],
    },
    {
      'code': 'ASII',
      'name': 'Astra International Tbk.',
      'type': 'Otomotif',
      'price': 4450.0,
      'lastChange': 0.0,
      'icon': Icons.directions_car_filled,
      'priceHistory': <double>[],
    },
    {
      'code': 'UNVR',
      'name': 'Unilever Indonesia Tbk.',
      'type': 'Konsumen',
      'price': 2980.0,
      'lastChange': 0.0,
      'icon': Icons.shopping_bag,
      'priceHistory': <double>[],
    },
  ].obs;

  Timer? _marketUpdateTimer;
  final isEventLoading = false.obs;
  Map<String, dynamic>? currentMarketEvent;
  int _tick = 0;

  @override
  void onInit() {
    super.onInit();
    fetchPortfolio();
    startMarketSimulation();
  }

  @override
  void onClose() {
    _marketUpdateTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchPortfolio() async {
    isLoading(true);
    try {
      final response = await _dataSource.getPortfolio();
      if (response.statusCode == 200) {
        final data = response.data['data'];
        virtualCash.value = (data['virtual_cash'] as num).toDouble();
        xp.value = data['xp'];
        level.value = data['level'];
        
        // Map assets
        List<dynamic> assets = data['assets'];
        myAssets.assignAll(assets.map((a) => {
          'code': a['asset_code'],
          'name': a['asset_name'],
          'quantity': a['quantity'],
          'avgPrice': a['avg_price'],
          // Find icon from market assets
          'icon': simulatedMarketAssets.firstWhere(
            (m) => m['code'] == a['asset_code'], 
            orElse: () => {'icon': Icons.error}
          )['icon']
        }).toList());

        // Map transactions
        List<dynamic> transactions = data['transactions'];
        transactionHistory.assignAll(transactions.map((t) => {
          'type': t['type'] == 'BUY' ? 'Beli' : 'Jual',
          'assetCode': t['asset_code'],
          'quantity': t['quantity'],
          'price': t['price'],
          'timestamp': DateTime.parse(t['timestamp'])
        }).toList());
      }
    } catch (e) {
      print("Error fetching portfolio: $e");
      Get.snackbar("Error", "Gagal memuat portofolio");
    } finally {
      isLoading(false);
    }
  }

  Future<void> buyAsset(Map<String, dynamic> asset, double quantity) async {
    if (quantity <= 0) return;
    try {
      final response = await _dataSource.buyAsset(
        assetCode: asset['code'],
        assetName: asset['name'],
        quantity: quantity,
        price: asset['price'],
      );
      
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Berhasil membeli ${asset['code']}", backgroundColor: AppColors.success, colorText: Colors.white);
        fetchPortfolio(); // Refresh data
      }
    } catch (e) {
      Get.snackbar("Gagal", "Gagal membeli aset: ${e.toString()}", backgroundColor: AppColors.danger, colorText: Colors.white);
    }
  }

  Future<void> sellAsset(Map<String, dynamic> myAsset, double quantity) async {
    if (quantity <= 0) return;
    // Find current market price
    final marketAsset = simulatedMarketAssets.firstWhere((a) => a['code'] == myAsset['code']);
    
    try {
      final response = await _dataSource.sellAsset(
        assetCode: myAsset['code'],
        quantity: quantity,
        price: marketAsset['price'],
      );
      
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Berhasil menjual ${myAsset['code']}", backgroundColor: AppColors.success, colorText: Colors.white);
        fetchPortfolio(); // Refresh data
      }
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menjual aset: ${e.toString()}", backgroundColor: AppColors.danger, colorText: Colors.white);
    }
  }

  // --- Market Simulation Logic (Simplified from original screen) ---
  void startMarketSimulation() {
    _marketUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _tick++;
      updateAllAssetPrices();
    });
  }

  void updateAllAssetPrices() {
    final random = Random();
    for (var asset in simulatedMarketAssets) {
      double changePercent = (random.nextDouble() - 0.48) * 0.05;
      double newPrice = asset['price'] * (1 + changePercent);
      asset['price'] = newPrice > 0 ? newPrice : 1;
      asset['lastChange'] = changePercent * 100;
      
      (asset['priceHistory'] as List<double>).add(asset['price']);
      if ((asset['priceHistory'] as List).length > 20) {
        (asset['priceHistory'] as List).removeAt(0);
      }
    }
    simulatedMarketAssets.refresh(); // Notify Obx
  }
  
  double calculateTotalAssetValue() {
    double total = 0;
    for (var myAsset in myAssets) {
      var marketAsset = simulatedMarketAssets.firstWhere(
        (a) => a['code'] == myAsset['code'],
        orElse: () => {'price': 0.0},
      );
      total += (myAsset['quantity'] as num) * (marketAsset['price'] as num);
    }
    return total;
  }
}
