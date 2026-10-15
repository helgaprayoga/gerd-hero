import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryLoadingSkeleton extends StatelessWidget {
  const HistoryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    itemCount: 3,
    separatorBuilder: (_, index) => const SizedBox(height: 12),
    itemBuilder: (_, index) => const _HistorySkeletonCard(),
  );
}

class _HistorySkeletonCard extends StatelessWidget {
  const _HistorySkeletonCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A1F2D2B),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SkeletonBox(width: 130, height: 16),
            _SkeletonBox(width: 66, height: 24, radius: 99),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const _SkeletonBox(width: 72, height: 72, radius: 72),
            const SizedBox(width: 14),
            const _SkeletonBox(width: 90, height: 16),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const _SkeletonBox(width: 90, height: 28, radius: 99),
            const SizedBox(width: 8),
            const _SkeletonBox(width: 110, height: 28, radius: 99),
          ],
        ),
      ],
    ),
  );
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });
  final double width;
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
