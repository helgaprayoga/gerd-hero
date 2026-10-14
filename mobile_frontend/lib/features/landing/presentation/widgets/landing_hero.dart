import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../../core/widgets/pill_badge.dart';

class LandingHero extends StatefulWidget {
  const LandingHero({
    required this.onMascotTap,
    required this.mascotAnimation,
    super.key,
  });

  final VoidCallback onMascotTap;
  final Animation<double> mascotAnimation;

  @override
  State<LandingHero> createState() => _LandingHeroState();
}

class _LandingHeroState extends State<LandingHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 340),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onMascotTap,
          child: SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withValues(alpha: 0.20),
                    ),
                  ),
                ),
                Mascot(animation: widget.mascotAnimation),
                Positioned(
                  bottom: -2,
                  right: -10,
                  child: AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        0,
                        -5 *
                            Curves.easeInOut.transform(_bounceController.value),
                      ),
                      child: child,
                    ),
                    child: const PillBadge(
                      label: '✦  Hai, aku Gery!',
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const PillBadge(
          label: 'Teman Sehat Lambungmu',
          icon: Icons.spa,
          backgroundColor: AppColors.surfaceContainerLow,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          shadow: false,
        ),
        const SizedBox(height: 8),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'GERD'),
              TextSpan(
                text: 'Hero',
                style: TextStyle(color: AppColors.primaryContainer),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Text(
            'Pantau gejala GERD, kenali pemicunya, dan jaga lambungmu lebih awal.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 16),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            PillBadge(label: '100% Privat & Aman', icon: Icons.lock),
            PillBadge(label: 'Rekomendasi Medis Ringan', icon: Icons.verified),
          ],
        ),
      ],
    ),
  );
}
