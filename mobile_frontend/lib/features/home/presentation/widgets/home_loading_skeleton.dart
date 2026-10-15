import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SkeletonBox(width: 150, height: 22),
                const SizedBox(height: 8),
                _SkeletonBox(width: 220, height: 12),
              ],
            ),
            const _SkeletonBox(width: 40, height: 40, radius: 40),
          ],
        ),
        const SizedBox(height: 18),
        const _SkeletonBox(width: 112, height: 28, radius: 999),
        const SizedBox(height: 16),
        const _SkeletonBox(width: double.infinity, height: 218, radius: 24),
        const SizedBox(height: 16),
        const _SkeletonCard(height: 212),
        const SizedBox(height: 20),
        const _SkeletonCard(height: 126),
        const SizedBox(height: 20),
        const _SkeletonCard(height: 150),
        const SizedBox(height: 72),
      ],
    ),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: height,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonBox(width: 132, height: 16),
        const SizedBox(height: 12),
        _SkeletonBox(width: double.infinity, height: 12),
        const SizedBox(height: 8),
        const _SkeletonBox(width: 220, height: 12),
        const Spacer(),
        const _SkeletonBox(width: double.infinity, height: 10, radius: 999),
      ],
    ),
  );
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, required this.height, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
