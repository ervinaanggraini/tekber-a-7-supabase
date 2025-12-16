import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import 'package:flutter_application/core/widgets/skeleton_loading.dart';

class HomeSkeletonLoading extends StatelessWidget {
  const HomeSkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Padding(
            padding: const EdgeInsets.all(Spacing.s16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLine(width: 60, height: 18),
                    const SizedBox(height: 8),
                    const SkeletonLine(width: 150, height: 14),
                  ],
                ),
                const SkeletonCircle(size: 48),
              ],
            ),
          ),
          
          const SizedBox(height: Spacing.s16),
          
          // Cashflow Card Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
            child: Container(
              padding: const EdgeInsets.all(Spacing.s16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 80, height: 16),
                  const SizedBox(height: Spacing.s16),
                  const SkeletonLine(width: 200, height: 32),
                  const SizedBox(height: Spacing.s16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLine(width: 100, height: 14),
                              SizedBox(height: 8),
                              SkeletonLine(width: 120, height: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLine(width: 100, height: 14),
                              SizedBox(height: 8),
                              SkeletonLine(width: 120, height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: Spacing.s24),
          
          // Menu Icons Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => Column(
                  children: [
                    SkeletonLoading(
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 8),
                    const SkeletonLine(width: 50, height: 12),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: Spacing.s24),
          
          // Transaction Title Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.s16),
            child: SkeletonLine(width: 150, height: 18),
          ),
          
          const SizedBox(height: Spacing.s16),
          
          // Transaction List Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.s16),
            child: Container(
              padding: const EdgeInsets.all(Spacing.s16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        SkeletonLoading(
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLine(width: 120, height: 14),
                              SizedBox(height: 6),
                              SkeletonLine(width: 80, height: 12),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const SkeletonLine(width: 80, height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: Spacing.s24),
          
          // Floating Action Button Skeleton (positioned at bottom right)
          Padding(
            padding: const EdgeInsets.all(Spacing.s16),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SkeletonLoading(
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

