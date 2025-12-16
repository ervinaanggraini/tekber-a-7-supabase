import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';
import 'package:moneyvesto/core/constants/color.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // Tambahkan SingleTickerProviderStateMixin
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation Controller and Animations
  late AnimationController _contentAnimationController;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _descriptionSlideAnimation;
  late Animation<double> _descriptionFadeAnimation;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Smart Personal\nFinance',
      'description':
          'Master your money effortlessly with intuitive expense and income tracking.',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Instant Receipt\nOCR Scanner',
      'description':
          'Snap and save your receipts automatically with cutting-edge OCR technology.',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'AI Financial\nChatbot',
      'description':
          'Get personalized money advice anytime from your smart financial assistant.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _contentAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 900,
      ), // Durasi animasi konten per halaman
      vsync: this,
    );

    // Animasi Gambar (0ms - 500ms)
    _imageScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Animasi Judul (200ms - 700ms)
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Interval(0.22, 0.77, curve: Curves.easeOutCubic),
      ),
    );
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Interval(0.22, 0.77, curve: Curves.easeOut),
      ),
    );

    // Animasi Deskripsi (400ms - 900ms)
    _descriptionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Interval(0.44, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Interval(0.44, 1.0, curve: Curves.easeOut),
      ),
    );

    // Jalankan animasi untuk halaman pertama
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentAnimationController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String buttonText =
        _currentPage < onboardingData.length - 1 ? 'Next' : 'Get Started';
    VoidCallback buttonOnPressed =
        _currentPage < onboardingData.length - 1
            ? () {
              if (_pageController.hasClients) {
                _pageController.animateToPage(
                  _currentPage + 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutSine,
                );
              }
            }
            : () {
              Get.offNamed(
                NavigationRoutes.getStarted,
              ); // Menggunakan offNamed agar tidak bisa kembali ke onboarding
            };

    return BaseWidgetContainer(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Row(
                children: List.generate(onboardingData.length, (index) {
                  double indicatorWidth =
                      (1.sw - 48.w - (onboardingData.length - 1) * 4.w) /
                      onboardingData.length;
                  return AnimatedContainer(
                    // Membuat indikator lebih smooth saat berganti warna
                    duration: const Duration(milliseconds: 300),
                    width: indicatorWidth,
                    height: 4.h,
                    margin: EdgeInsets.only(
                      right: index != onboardingData.length - 1 ? 4.w : 0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _currentPage >= index
                              ? AppColors.primaryAccent
                              : AppColors.inactiveIndicator,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    // Reset dan jalankan ulang animasi untuk konten halaman baru
                    _contentAnimationController.reset();
                    _contentAnimationController.forward();
                  },
                  itemBuilder: (context, index) {
                    final data = onboardingData[index];
                    // Hanya terapkan animasi jika halaman saat ini adalah yang sedang dibangun
                    // atau jika controller sedang beranimasi (untuk transisi awal)
                    // Namun, lebih sederhana untuk selalu membangunnya karena transition widget akan menangani visibility.
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animasi untuk Judul
                        FadeTransition(
                          opacity: _titleFadeAnimation,
                          child: SlideTransition(
                            position: _titleSlideAnimation,
                            child: GlobalText.semiBold(
                              data['title']!,
                              fontSize: 22.sp,
                              color: AppColors.textLight,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // Animasi untuk Deskripsi
                        FadeTransition(
                          opacity: _descriptionFadeAnimation,
                          child: SlideTransition(
                            position: _descriptionSlideAnimation,
                            child: GlobalText.regular(
                              data['description'] ?? '',
                              fontSize: 14.sp,
                              color: AppColors.textLight,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Center(
                            // Animasi untuk Gambar
                            child: ScaleTransition(
                              scale: _imageScaleAnimation,
                              child: FadeTransition(
                                opacity: _imageFadeAnimation,
                                child: Image.asset(
                                  data['image']!,
                                  width: 250.w,
                                  height: 250.h,
                                  // key: ValueKey<String>(data['image']!), // Opsional: key untuk memastikan widget diganti jika image path berubah
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 30.h),
              // Tombol bisa juga diberi animasi sederhana saat teks berubah jika diinginkan
              AnimatedSwitcher(
                // Animasi untuk perubahan teks tombol
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: GlobalButton(
                  key: ValueKey<String>(
                    buttonText,
                  ), // Key penting untuk AnimatedSwitcher
                  text: buttonText,
                  backgroundColor: AppColors.primaryAccent,
                  textColor: AppColors.textLight,
                  onPressed: buttonOnPressed,
                  width: 1.sw - 48.w,
                  fontSize: 16.sp,
                  height: 48.h, // Menambahkan tinggi tombol agar konsisten
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
