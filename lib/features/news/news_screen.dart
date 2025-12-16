import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http; // Import package http
import 'dart:convert'; // Untuk mengurai JSON
import 'package:url_launcher/url_launcher.dart'; // Import package url_launcher
import 'package:moneyvesto/core/models/article.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  // State untuk data berita dari API
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true; // Indikator loading
  String? _errorMessage; // Untuk menampilkan error

  final String _apiKey =
      'cd49b3635d89429ea1fa330e78a2ed14'; // Ganti dengan API key Anda
  final String _baseUrl = 'https://newsapi.org/v2/everything';

  final Map<String, String> _categoryQueries = {
    'Semua': 'finance OR investment OR business OR stocks OR economy',
    'Saham': 'stock market OR shares OR trading OR IHSG OR stocks',
    'Ekonomi': 'economy OR inflation OR interest rates OR central bank OR GDP',
    'Teknologi':
        'tech OR innovation OR artificial intelligence OR startup OR gadgets',
    'Global':
        'global economy OR international trade OR geopolitics OR world markets',
    'Tips':
        'investment tips OR financial planning OR personal finance OR money management',
  };

  final List<String> _categories = [
    'Semua',
    'Saham',
    'Ekonomi',
    'Teknologi',
    'Global',
    'Tips',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _searchController.addListener(_filterNews);
    _fetchNews();
  }

  // Fungsi untuk mengambil berita dari News API
  Future<void> _fetchNews() async {
    if (!mounted) return; // Pastikan widget masih ada di tree
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String query = _categoryQueries[_selectedCategory] ?? 'finance';

      if (_searchController.text.isNotEmpty) {
        query += ' AND (${_searchController.text})';
      }

      final Uri uri = Uri.parse(
        '$_baseUrl?q=$query&language=en&sortBy=publishedAt&apiKey=$_apiKey',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          List<Article> fetchedArticles =
              (data['articles'] as List)
                  .map((articleJson) => Article.fromJson(articleJson))
                  // PERUBAHAN UTAMA DI SINI: Filter artikel yang tidak punya gambar atau judulnya '[Removed]'
                  .where((article) {
                    final hasImage =
                        article.urlToImage != null &&
                        article.urlToImage!.isNotEmpty;
                    final isNotRemoved =
                        article.title.toLowerCase() != "[removed]";
                    return hasImage && isNotRemoved;
                  })
                  .toList();

          if (mounted) {
            setState(() {
              _allArticles = fetchedArticles;
              _filteredArticles = _allArticles;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = data['message'] ?? 'Failed to load articles.';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Failed to load news: Status Code ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _isLoading = false;
        });
      }
      print('Error fetching news: $e');
    }
  }

  // Fungsi yang dipanggil ketika teks di search bar berubah atau kategori berubah
  void _filterNews() {
    _fetchNews();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchNews();
    });
  }

  // Fungsi untuk membuka URL di browser eksternal
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      Get.snackbar(
        'Gagal Membuka Berita',
        'Tidak dapat membuka tautan berita ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return DateFormat('d MMM yyyy', 'id_ID').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: GlobalText.medium(
          'Berita Keuangan',
          fontSize: 18.sp,
          color: AppColors.textLight,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textLight,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                minHeight: 60.h,
                maxHeight: 60.h,
                child: _buildCategoryFilters(),
              ),
              pinned: true,
            ),
          ];
        },
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                )
                : _errorMessage != null
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: GlobalText.regular(
                      _errorMessage!,
                      color: Colors.red,
                      fontSize: 16.sp,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : _filteredArticles.isEmpty
                ? Center(
                  child: GlobalText.regular(
                    'Tidak ada berita ditemukan untuk kategori atau pencarian ini.',
                    color: AppColors.textLight.withOpacity(0.7),
                    fontSize: 16.sp,
                    textAlign: TextAlign.center,
                  ),
                )
                : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _filteredArticles.length,
                  itemBuilder: (context, index) {
                    return _buildNewsCard(_filteredArticles[index]);
                  },
                ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textLight, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Cari berita...',
          hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textLight.withOpacity(0.7),
          ),
          filled: true,
          fillColor: AppColors.secondaryAccent,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60.h,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => _selectCategory(category),
            child: Container(
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primaryAccent
                        : AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: GlobalText.medium(
                  category,
                  color: AppColors.textLight,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Card untuk menampilkan setiap item berita
  Widget _buildNewsCard(Article article) {
    // Karena sudah difilter, kita bisa asumsikan article.urlToImage tidak null
    return GestureDetector(
      onTap: () => _launchUrl(article.url),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.secondaryAccent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
              child: Image.network(
                article.urlToImage!,
                width: 110.w,
                height: 110.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback jika URL gambar valid tapi gagal di-load
                  return Container(
                    width: 110.w,
                    height: 110.h,
                    color: AppColors.secondaryAccent,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textLight.withOpacity(0.5),
                      size: 40.sp,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 110.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: GlobalText.regular(
                        article.sourceName.toUpperCase(),
                        textAlign: TextAlign.start,
                        color: AppColors.textLight.withOpacity(0.6),
                        fontSize: 11.sp,
                      ),
                    ),
                    GlobalText.medium(
                      article.title,
                      textAlign: TextAlign.start,
                      color: AppColors.textLight,
                      fontSize: 14.sp,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h, right: 12.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlobalText.regular(
                            _formatTimeAgo(article.publishedAt),
                            color: AppColors.textLight.withOpacity(0.6),
                            fontSize: 11.sp,
                          ),
                          Icon(
                            Icons.bookmark_border_rounded,
                            color: AppColors.textLight.withOpacity(0.6),
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class (tidak ada perubahan)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
