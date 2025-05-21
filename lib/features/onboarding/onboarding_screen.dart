import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/base_widget_container.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/utils/route_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

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
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      int nextPage = (_currentPage + 1) % onboardingData.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidgetContainer(
      backgroundColor: const Color(0xFF002366),
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
                  return Container(
                    width: indicatorWidth,
                    height: 4.h,
                    margin: EdgeInsets.only(
                      right: index != onboardingData.length - 1 ? 4.w : 0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _currentPage >= index
                              ? Colors.black
                              : Colors.white.withOpacity(0.5),
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
                  },
                  itemBuilder: (context, index) {
                    final data = onboardingData[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalText.semiBold(
                          data['title']!,
                          fontSize: 22.sp,
                          color: Colors.white,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 10.h),
                        GlobalText.regular(
                          data['description'] ?? '',
                          fontSize: 14.sp,
                          color: Colors.white,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              data['image']!,
                              width: 250.w,
                              height: 250.h,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlobalButton(
                    text: 'Sign Up',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    onPressed: () {
                      Get.toNamed(NavigationRoutes.signUp);
                    },
                    width: 0.38.sw,
                    fontSize: 14.sp,
                  ),
                  GlobalButton(
                    text: 'Sign In',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      Get.toNamed(NavigationRoutes.login);
                    },
                    width: 0.38.sw,
                    fontSize: 14.sp,
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
