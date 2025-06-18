// File: lib/screens/education_simulation_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/features/invest/assets_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenRouterService {
  static final String? _apiKey = dotenv.env['OPENROUTER_API_KEY'];
  static const String _apiUrl = "https://openrouter.ai/api/v1/chat/completions";
  static const String _model = "google/gemini-flash-1.5";

  static Future<Map<String, dynamic>?> fetchMarketEvent() async {
    if (_apiKey == null) {
      print("ERROR: OpenRouter API Key tidak ditemukan!");
      return null;
    }
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "model": _model,
      "response_format": {"type": "json_object"},
      "messages": [
        {
          "role": "system",
          "content":
              "Anda adalah AI untuk game simulasi investasi. Buat event pasar fiktif dalam format JSON yang valid.",
        },
        {
          "role": "user",
          "content":
              "Buatkan satu event berita pasar keuangan yang mempengaruhi salah satu sektor ini: Teknologi, Finansial, Energi, Otomotif, atau Konsumen. Format JSON harus memiliki kunci: 'headline' (string), 'description' (string, 1 kalimat), dan 'impact' (JSON object dengan 'sector' dan 'effect' (float antara 0.8 hingga 1.25)).",
        },
      ],
    });

    try {
      final response = await http
          .post(Uri.parse(_apiUrl), headers: headers, body: body)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final content = decodedBody['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        print(
          "Error API OpenRouter Event: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Exception saat memanggil API event: $e");
      return null;
    }
  }

  static Future<String?> fetchAssetAnalysis(
    String assetCode,
    String assetName,
    List<double> priceHistory,
  ) async {
    if (_apiKey == null) return "API Key tidak ditemukan.";

    // 1. Mengolah data histori menjadi persentase
    String formattedHistoryString = "Data tidak cukup.";
    if (priceHistory.length > 1) {
      List<String> percentageChanges = [];
      for (int i = 1; i < priceHistory.length; i++) {
        double change =
            ((priceHistory[i] - priceHistory[i - 1]) / priceHistory[i - 1]) *
            100;
        percentageChanges.add(
          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
        );
      }
      formattedHistoryString = percentageChanges.join(', ');
    }

    // 2. Membuat prompt baru yang lebih canggih
    final prompt = """
    Berikan analisis singkat untuk aset dengan kode '$assetCode' ($assetName).

    Berikut adalah data historis pergerakan harganya (dalam persen) untuk beberapa periode terakhir (dari yang terlama hingga terbaru):
    [$formattedHistoryString]

    Berdasarkan data di atas, berikan analisamu tentang tren (naik/turun/sideways), tingkat volatilitas (tinggi/sedang/rendah), dan sentimen pasar saat ini untuk aset ini. Berikan jawaban dalam 2-3 kalimat saja.
    """;

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "model": _model,
      "messages": [
        {
          "role": "system",
          "content":
              "Anda adalah seorang analis keuangan AI yang tajam dan memberikan opini singkat berdasarkan data yang diberikan untuk sebuah game simulasi.",
        },
        {"role": "user", "content": prompt},
      ],
    });

    try {
      final response = await http
          .post(Uri.parse(_apiUrl), headers: headers, body: body)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['choices'][0]['message']['content'];
      }
      return "Gagal mendapatkan analisis dari AI.";
    } catch (e) {
      return "Terjadi kesalahan koneksi saat meminta analisis.";
    }
  }
}

// === KELAS UTAMA SCREEN ===
class EducationAndSimulationScreen extends StatefulWidget {
  const EducationAndSimulationScreen({super.key});
  @override
  State<EducationAndSimulationScreen> createState() =>
      _EducationAndSimulationScreenState();
}

class _EducationAndSimulationScreenState
    extends State<EducationAndSimulationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _marketUpdateTimer;

  bool _isStateLoading = true;
  int _xp = 0;
  int _level = 1;
  late List<Map<String, dynamic>> _missions;
  double _virtualCash = 100000000;
  List<Map<String, dynamic>> _mySimulatedAssets = [];
  List<Map<String, dynamic>> _transactionHistory = [];
  final List<FlSpot> _portfolioHistory = [const FlSpot(0, 100000000)];
  Map<String, dynamic>? _currentMarketEvent;
  bool _isEventLoading = false;
  int _tick = 0; // Tick counter for market events

  // === PERUBAHAN: Setiap aset kini punya histori harganya sendiri ===
  final List<Map<String, dynamic>> _simulatedMarketAssets = [
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
  ];
  final List<Map<String, dynamic>> investmentArticles = [
    {
      'title': 'Memulai Investasi Saham untuk Pemula',
      'category': 'Dasar-Dasar Saham',
      'imageUrl': 'https://picsum.photos/seed/invest1/400/200',
    },
    {
      'title': 'Apa itu Reksadana Pasar Uang?',
      'category': 'Panduan Reksadana',
      'imageUrl': 'https://picsum.photos/seed/invest2/400/200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSimulationState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _marketUpdateTimer?.cancel();
    super.dispose();
  }

  // === LOGIKA PENYIMPANAN & PEMUATAN DATA ===
  Future<void> _saveSimulationState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('virtualCash', _virtualCash);
    await prefs.setInt('xp', _xp);
    await prefs.setInt('level', _level);
    await prefs.setString('myAssets', jsonEncode(_mySimulatedAssets));
    final encodableHistory =
        _transactionHistory
            .map(
              (t) => {
                ...t,
                'timestamp': (t['timestamp'] as DateTime).toIso8601String(),
              },
            )
            .toList();
    await prefs.setString('transactionHistory', jsonEncode(encodableHistory));
    final completedMissions =
        _missions.where((m) => m['isCompleted']).map((m) => m['id']).toList();
    await prefs.setStringList(
      'completedMissions',
      completedMissions.map((id) => id.toString()).toList(),
    );
    print("SIMULASI DISIMPAN!");
  }

  Future<void> _loadSimulationState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _virtualCash = prefs.getDouble('virtualCash') ?? 100000000;
        _xp = prefs.getInt('xp') ?? 0;
        _level = prefs.getInt('level') ?? 1;
        final assetsString = prefs.getString('myAssets');
        if (assetsString != null)
          _mySimulatedAssets = List<Map<String, dynamic>>.from(
            jsonDecode(assetsString),
          );
        final historyString = prefs.getString('transactionHistory');
        if (historyString != null) {
          final decodedHistory = jsonDecode(historyString) as List;
          _transactionHistory =
              decodedHistory
                  .map<Map<String, dynamic>>(
                    (t) => {...t, 'timestamp': DateTime.parse(t['timestamp'])},
                  )
                  .toList();
        }
        _isStateLoading = false;
      });
    }
    _initializeMissions();
    _startMarketSimulation();
  }

  void _initializeMissions() {
    _missions = [
      {
        'id': 1,
        'title': 'Langkah Pertama',
        'desc': 'Lakukan pembelian aset pertamamu',
        'xp': 50,
        'isCompleted': false,
        'condition': () => _mySimulatedAssets.isNotEmpty,
      },
      {
        'id': 2,
        'title': 'Diversifikasi Awal',
        'desc': 'Miliki minimal 2 jenis aset berbeda',
        'xp': 100,
        'isCompleted': false,
        'condition':
            () => _mySimulatedAssets.map((a) => a['code']).toSet().length >= 2,
      },
      {
        'id': 3,
        'title': 'Trader Aktif',
        'desc': 'Lakukan total 5 transaksi (beli/jual)',
        'xp': 150,
        'isCompleted': false,
        'condition': () => _transactionHistory.length >= 5,
      },
      {
        'id': 4,
        'title': 'Calon Sultan',
        'desc': 'Raih total nilai portofolio Rp 120 Juta',
        'xp': 250,
        'isCompleted': false,
        'condition':
            () => (_calculateTotalAssetValue() + _virtualCash) >= 120000000,
      },
      {
        'id': 5,
        'title': 'Tahan Banting',
        'desc': 'Bertahan melalui event pasar negatif',
        'xp': 100,
        'isCompleted': false,
        'condition':
            () => _transactionHistory.any(
              (t) =>
                  t['event'] != null &&
                  (t['event']['impact']['effect'] as num) < 1.0,
            ),
      },
    ];
    SharedPreferences.getInstance().then((prefs) {
      final completedMissionIds =
          prefs.getStringList('completedMissions')?.map(int.parse).toSet() ??
          {};
      if (mounted) {
        setState(() {
          for (var mission in _missions) {
            if (completedMissionIds.contains(mission['id']))
              mission['isCompleted'] = true;
          }
        });
      }
    });
  }

  void _startMarketSimulation() {
    _marketUpdateTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (!mounted) return;

      _tick++;
      if (mounted) {
        setState(() {
          if (_tick % 2 == 0 && !_isEventLoading) {
            _isEventLoading = true;
            _currentMarketEvent = null;
            OpenRouterService.fetchMarketEvent().then((event) {
              if (mounted && event != null)
                setState(() => _currentMarketEvent = event);
              if (mounted) setState(() => _isEventLoading = false);
            });
          }
          final random = Random();
          for (var asset in _simulatedMarketAssets) {
            double eventMultiplier = 1.0;
            if (_currentMarketEvent != null) {
              final impact = _currentMarketEvent!['impact'];
              if (impact['sector'] == asset['type'] ||
                  impact['sector'] == 'Semua') {
                eventMultiplier =
                    impact['effect'] is int
                        ? (impact['effect'] as int).toDouble()
                        : impact['effect'];
              }
            }
            double changePercent =
                ((random.nextDouble() - 0.48) * 0.05) * eventMultiplier;
            double newPrice = asset['price'] * (1 + changePercent);
            asset['price'] = newPrice;
            asset['lastChange'] = changePercent * 100;

            // PERUBAHAN: Menyimpan histori harga per aset
            (asset['priceHistory'] as List<double>).add(newPrice);
            if ((asset['priceHistory'] as List).length > 20) {
              (asset['priceHistory'] as List).removeAt(0);
            }
          }
          double newPortfolioValue = _calculateTotalAssetValue() + _virtualCash;
          _portfolioHistory.add(
            FlSpot(_portfolioHistory.last.x + 1, newPortfolioValue),
          );
          if (_portfolioHistory.length > 20) _portfolioHistory.removeAt(0);
          _checkMissions();
        });
      }
    });
  }

  String formatCurrency(double amount) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
  double _calculateTotalAssetValue() {
    if (_mySimulatedAssets.isEmpty) return 0.0;
    double totalValue = 0;
    for (var myAsset in _mySimulatedAssets) {
      final marketAsset = _simulatedMarketAssets.firstWhere(
        (a) => a['code'] == myAsset['code'],
      );
      totalValue +=
          (myAsset['quantity'] as num) * (marketAsset['price'] as num);
    }
    return totalValue;
  }

  String get _investorTitle {
    if (_level >= 10) return "Sultan Andara";
    if (_level >= 5) return "Juragan Investasi";
    if (_level >= 3) return "Trader Andal";
    return "Investor Pemula";
  }

  int get _xpForNextLevel => (_level * _level * 100) + 200;

  void _addXp(int amount) {
    setState(() {
      _xp += amount;
      while (_xp >= _xpForNextLevel) {
        _xp -= _xpForNextLevel;
        _level++;
        _showLevelUpDialog();
      }
    });
    _saveSimulationState();
  }

  void _addTransaction(String type, String code, int quantity, double price) {
    setState(() {
      final newTransaction = {
        'type': type,
        'code': code,
        'quantity': quantity,
        'price': price,
        'total': quantity * price,
        'timestamp': DateTime.now(),
        'event': _currentMarketEvent,
      };
      _transactionHistory.insert(0, newTransaction);
      if (_transactionHistory.length > 10) _transactionHistory.removeLast();
      _addXp(5);
    });
  }

  void _checkMissions() {
    bool missionCompletedThisCheck = false;
    for (var mission in _missions) {
      if (!mission['isCompleted'] && mission['condition']()) {
        setState(() => mission['isCompleted'] = true);
        _addXp(mission['xp']);
        _showMissionCompleteDialog(mission);
        missionCompletedThisCheck = true;
      }
    }
    if (missionCompletedThisCheck) _saveSimulationState();
  }

  void _buyAsset(Map<String, dynamic> asset, int quantity) {
    num totalCost = (asset['price'] as num) * quantity;
    if (_virtualCash >= totalCost) {
      setState(() {
        _virtualCash -= totalCost;
        int existingIndex = _mySimulatedAssets.indexWhere(
          (a) => a['code'] == asset['code'],
        );
        if (existingIndex != -1) {
          var existingAsset = _mySimulatedAssets[existingIndex];
          num newQuantity = (existingAsset['quantity'] as num) + quantity;
          num newTotalCost =
              ((existingAsset['avgPrice'] as num) *
                  (existingAsset['quantity'] as num)) +
              totalCost;
          existingAsset['quantity'] = newQuantity;
          existingAsset['avgPrice'] = newTotalCost / newQuantity;
        } else {
          _mySimulatedAssets.add({
            'code': asset['code'],
            'name': asset['name'],
            'icon': asset['icon'],
            'quantity': quantity.toDouble(),
            'avgPrice': asset['price'],
          });
        }
        _addTransaction('Beli', asset['code'], quantity, asset['price']);
      });
      _saveSimulationState();
    }
  }

  void _sellAsset(Map<String, dynamic> myAsset, int quantity) {
    if (quantity > (myAsset['quantity'] as num)) {
      Get.snackbar('Gagal Menjual', 'Jumlah unit tidak mencukupi.');
      return;
    }
    final marketAsset = _simulatedMarketAssets.firstWhere(
      (a) => a['code'] == myAsset['code'],
    );
    num totalProceeds = (marketAsset['price'] as num) * quantity;
    setState(() {
      _virtualCash += totalProceeds;
      myAsset['quantity'] = (myAsset['quantity'] as num) - quantity;
      if (myAsset['quantity'] <= 0) _mySimulatedAssets.remove(myAsset);
      _addTransaction('Jual', myAsset['code'], quantity, marketAsset['price']);
    });
    _saveSimulationState();
  }

  // === PERUBAHAN: Mengirim histori harga ke service API ===
  void _handleAskAi(String assetCode, String assetName) {
    final asset = _simulatedMarketAssets.firstWhere(
      (a) => a['code'] == assetCode,
    );
    final priceHistory = asset['priceHistory'] as List<double>;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    OpenRouterService.fetchAssetAnalysis(
      assetCode,
      assetName,
      priceHistory,
    ).then((analysis) {
      Get.back();
      Get.defaultDialog(
        title: "Analisis AI untuk $assetCode",
        titleStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        backgroundColor: AppColors.background.withBlue(35),
        content: Padding(
          padding: EdgeInsets.all(8.w),
          child: Text(
            analysis ?? "Gagal memuat analisis.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.9),
              fontSize: 14.sp,
            ),
          ),
        ),
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text("Mengerti"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isStateLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              GlobalText.regular("Memuat Simulasi..."),
            ],
          ),
        ),
      );
    }

    double totalPortfolioValue = _calculateTotalAssetValue() + _virtualCash;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: GlobalText.medium(
          'Investasi',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.6),
          tabs: [
            Tab(
              child: GlobalText.medium(
                'Simulasi Pasar',
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
            Tab(
              child: GlobalText.medium(
                'Materi Edukasi',
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSimulationTab(totalPortfolioValue),
          _buildEducationTab(),
        ],
      ),
    );
  }

  Widget _buildSimulationTab(double totalPortfolioValue) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayerProfileCard(),
            SizedBox(height: 24.h),
            _buildPortfolioSummary(totalPortfolioValue),
            SizedBox(height: 28.h),
            _buildGamificationSection(),
            SizedBox(height: 28.h),
            _buildMarketSection(),
            SizedBox(height: 28.h),
            _buildMyAssetsSection(),
            SizedBox(height: 28.h),
            _buildTransactionHistory(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerProfileCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle,
                color: AppColors.primaryAccent,
                size: 32.sp,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalText.semiBold(
                    _investorTitle,
                    fontSize: 16.sp,
                    color: AppColors.textLight,
                  ),
                  GlobalText.regular(
                    "Level $_level",
                    fontSize: 13.sp,
                    color: AppColors.textLight.withOpacity(0.7),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              GlobalText.medium(
                "XP",
                fontSize: 12.sp,
                color: AppColors.primaryAccent,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: LinearProgressIndicator(
                  value: _xpForNextLevel > 0 ? _xp / _xpForNextLevel : 0,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryAccent,
                  ),
                  minHeight: 6.h,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(width: 8.w),
              GlobalText.medium(
                "$_xp / $_xpForNextLevel",
                fontSize: 12.sp,
                color: AppColors.textLight.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold(
          "Misi & Tantangan",
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        SizedBox(height: 12.h),
        ..._missions.map((mission) => _buildMissionTile(mission)).toList(),
      ],
    );
  }

  Widget _buildMissionTile(Map<String, dynamic> mission) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            mission['isCompleted']
                ? AppColors.secondaryAccent.withOpacity(0.4)
                : AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              mission['isCompleted'] ? AppColors.success : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            mission['isCompleted']
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color:
                mission['isCompleted']
                    ? AppColors.success
                    : AppColors.primaryAccent,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalText.medium(
                  mission['title'],
                  color: AppColors.textLight,
                  fontSize: 14.sp,
                ),
                GlobalText.regular(
                  mission['desc'],
                  color: AppColors.textLight.withOpacity(0.7),
                  fontSize: 12.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (!mission['isCompleted'])
            GlobalText.bold(
              "+${mission['xp']} XP",
              color: AppColors.primaryAccent,
              fontSize: 13.sp,
            ),
        ],
      ),
    );
  }

  Widget _buildMarketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold(
          'Pasar Simulasi',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        SizedBox(height: 8.h),
        if (_isEventLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_currentMarketEvent != null)
          _buildMarketEventCard()
        else
          GlobalText.regular(
            "Pasar sedang stabil... Refresh setiap 20 detik.",
            fontSize: 13.sp,
            color: AppColors.textLight.withOpacity(0.6),
          ),
        SizedBox(height: 16.h),
        ListView.builder(
          itemCount: _simulatedMarketAssets.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final asset = _simulatedMarketAssets[index];
            final color =
                asset['lastChange'] >= 0 ? AppColors.success : AppColors.danger;
            return InkWell( // 1. Dibungkus dengan InkWell agar bisa di-tap
              onTap: () {
                // 2. Navigasi ke halaman detail dan kirim data 'asset'
                Get.to(() => const AssetDetailScreen(), arguments: asset);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAccent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: AppColors.background,
                      child: Image.asset(
                        'assets/images/${asset['code']}.png',
                        width: 30.w,
                        height: 30.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(asset['icon'], color: AppColors.textLight, size: 20.sp);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlobalText.medium(
                            asset['code'],
                            color: AppColors.textLight,
                            fontSize: 14.sp,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              GlobalText.regular(
                                formatCurrency(asset['price']),
                                color: AppColors.textLight.withOpacity(0.9),
                                fontSize: 13.sp,
                              ),
                              SizedBox(width: 8.w),
                              GlobalText.regular(
                                '${asset['lastChange'] >= 0 ? '+' : ''}${asset['lastChange'].toStringAsFixed(2)}%',
                                color: color,
                                fontSize: 12.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.psychology_alt_rounded,
                        color: AppColors.primaryAccent.withOpacity(0.8),
                        size: 20.sp,
                      ),
                      tooltip: "Tanya Analisis AI",
                      onPressed: () => _handleAskAi(asset['code'], asset['name']),
                    ),
                    ElevatedButton(
                      onPressed: () => _showTransactionDialog(true, asset),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: GlobalText.medium(
                        'Beli',
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMarketEventCard() {
    final event = _currentMarketEvent!;
    final impact = event['impact'];
    final color =
        ((impact['effect'] as num) >= 1.0)
            ? AppColors.success
            : AppColors.danger;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalText.bold("HEADLINE DARI AI:", color: color, fontSize: 12.sp),
          SizedBox(height: 4.h),
          GlobalText.semiBold(
            event['headline'],
            color: AppColors.textLight,
            fontSize: 15.sp,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 8.h),
          GlobalText.regular(
            event['description'],
            color: AppColors.textLight.withOpacity(0.8),
            fontSize: 13.sp,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(double totalPortfolioValue) {
    double profitLoss = totalPortfolioValue - 100000000;
    double profitLossPercent =
        totalPortfolioValue > 0 ? (profitLoss / 100000000) * 100 : 0;
    bool isProfit = profitLoss >= 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryAccent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalText.regular(
            'Total Nilai Portofolio',
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 14.sp,
          ),
          SizedBox(height: 8.h),
          AnimatedFlipCounter(
            value: totalPortfolioValue,
            prefix: "Rp ",
            thousandSeparator: ".",
            fractionDigits: 0,
            textStyle: GoogleFonts.poppins(
              fontSize: 28.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                color: isProfit ? AppColors.success : AppColors.danger,
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              GlobalText.medium(
                '${isProfit ? '+' : ''} ${formatCurrency(profitLoss)} (${profitLossPercent.toStringAsFixed(2)}%)',
                color: isProfit ? AppColors.success : AppColors.danger,
                fontSize: 14.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 50.h,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _portfolioHistory,
                    isCurved: true,
                    color: AppColors.primaryAccent,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryAccent.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAssetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold(
          'Portofolio Saya',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        SizedBox(height: 12.h),
        _mySimulatedAssets.isEmpty
            ? Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: GlobalText.regular(
                  'Anda belum memiliki aset.',
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 13.sp,
                ),
              ),
            )
            : ListView.builder(
              itemCount: _mySimulatedAssets.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final myAsset = _mySimulatedAssets[index];
                final marketAsset = _simulatedMarketAssets.firstWhere(
                  (a) => a['code'] == myAsset['code'],
                );
                final currentValue =
                    (myAsset['quantity'] as num) *
                    (marketAsset['price'] as num);
                final totalCost =
                    (myAsset['quantity'] as num) * (myAsset['avgPrice'] as num);
                final pnl = currentValue - totalCost;
                final pnlPercent = totalCost > 0 ? (pnl / totalCost) * 100 : 0;
                final color = pnl >= 0 ? AppColors.success : AppColors.danger;

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAccent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: AppColors.background,
                            child: Icon(
                              myAsset['icon'],
                              color: AppColors.textLight,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GlobalText.medium(
                                  myAsset['code'],
                                  color: AppColors.textLight,
                                  fontSize: 14.sp,
                                ),
                                SizedBox(height: 4.h),
                                GlobalText.regular(
                                  '${(myAsset['quantity'] as num).toInt()} unit @ ${formatCurrency(myAsset['avgPrice'])}',
                                  color: AppColors.textLight.withOpacity(0.7),
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GlobalText.semiBold(
                                formatCurrency(currentValue.toDouble()),
                                color: AppColors.textLight,
                                fontSize: 14.sp,
                              ),
                              SizedBox(height: 4.h),
                              GlobalText.regular(
                                '${pnl >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%',
                                color: color,
                                fontSize: 12.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                () => _showTransactionDialog(false, myAsset),
                            child: GlobalText.medium(
                              'Jual',
                              color: AppColors.danger,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalText.semiBold(
          'Riwayat Transaksi Terkini',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        SizedBox(height: 12.h),
        _transactionHistory.isEmpty
            ? Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: GlobalText.regular(
                  'Belum ada transaksi.',
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 13.sp,
                ),
              ),
            )
            : ListView.builder(
              itemCount: _transactionHistory.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final trx = _transactionHistory[index];
                final isBuy = trx['type'] == 'Beli';
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAccent.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlobalText.medium(
                              '${trx['type']} ${trx['code']}',
                              color:
                                  isBuy ? AppColors.success : AppColors.danger,
                              fontSize: 14.sp,
                            ),
                            SizedBox(height: 4.h),
                            GlobalText.regular(
                              '${trx['quantity']} unit @ ${formatCurrency(trx['price'])}',
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 12.sp,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GlobalText.medium(
                            formatCurrency(trx['total']),
                            color: AppColors.textLight,
                            fontSize: 13.sp,
                          ),
                          SizedBox(height: 4.h),
                          GlobalText.regular(
                            DateFormat(
                              'HH:mm:ss',
                            ).format(trx['timestamp'] as DateTime),
                            color: AppColors.textLight.withOpacity(0.5),
                            fontSize: 11.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }

  Widget _buildEducationTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: investmentArticles.length,
      itemBuilder: (context, index) {
        final article = investmentArticles[index];
        return Card(
          color: AppColors.secondaryAccent,
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: Image.network(
                  article['imageUrl'],
                  height: 120.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 120.h,
                        color: Colors.grey.shade800,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade500,
                        ),
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalText.regular(
                      article['category'].toUpperCase(),
                      color: AppColors.primaryAccent,
                      fontSize: 11.sp,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 8.h),
                    GlobalText.semiBold(
                      article['title'],
                      color: AppColors.textLight,
                      fontSize: 15.sp,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlobalText.clickable(
                        'Mulai Belajar >',
                        onTap: () {
                          Get.snackbar(
                            'Fitur Dalam Pengembangan',
                            'Halaman detail artikel akan segera tersedia.',
                          );
                        },
                        color: AppColors.textLight.withOpacity(0.9),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTransactionDialog(bool isBuy, Map<String, dynamic> assetData) {
    final TextEditingController controller = TextEditingController();
    final marketAsset =
        isBuy
            ? assetData
            : _simulatedMarketAssets.firstWhere(
              (a) => a['code'] == assetData['code'],
            );
    final unitType = "unit";

    Get.defaultDialog(
      title: '${isBuy ? "Beli" : "Jual"} ${marketAsset['code']}',
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      backgroundColor: AppColors.background.withBlue(30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlobalText.regular(
            'Harga Pasar: ${formatCurrency(marketAsset['price'])} / $unitType',
            fontSize: 14.sp,
            color: AppColors.textLight.withOpacity(0.8),
          ),
          if (!isBuy)
            GlobalText.regular(
              'Anda memiliki: ${(assetData['quantity'] as num).toInt()} $unitType',
              fontSize: 12.sp,
              color: AppColors.textLight.withOpacity(0.6),
            ),
          SizedBox(height: 16.h),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: AppColors.textLight),
            decoration: InputDecoration(
              labelText: 'Jumlah ($unitType)',
              labelStyle: TextStyle(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryAccent),
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isBuy ? AppColors.primaryAccent : AppColors.danger,
        ),
        onPressed: () {
          if (controller.text.isNotEmpty) {
            int quantity = int.parse(controller.text);
            if (isBuy)
              _buyAsset(marketAsset, quantity);
            else
              _sellAsset(assetData, quantity);
            Get.back();
          }
        },
        child: GlobalText.medium(
          'Konfirmasi ${isBuy ? "Beli" : "Jual"}',
          fontSize: 14.sp,
          color: Colors.white,
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: GlobalText.medium(
          'Batal',
          fontSize: 14.sp,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  void _showLevelUpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryAccent, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 60.sp),
              SizedBox(height: 16.h),
              GlobalText.bold(
                "LEVEL UP!",
                fontSize: 24.sp,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              GlobalText.regular(
                "Selamat! Anda telah mencapai Level $_level",
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.sp,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              GlobalText.medium(
                "Gelar barumu: $_investorTitle",
                color: Colors.yellow.shade200,
                fontSize: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionCompleteDialog(Map<String, dynamic> mission) {
    Get.snackbar(
      "MISI SELESAI!",
      "${mission['title']}\n+${mission['xp']} XP Diterima!",
      icon: Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: Colors.white,
      margin: EdgeInsets.all(12.w),
      duration: const Duration(seconds: 4),
    );
  }
}
