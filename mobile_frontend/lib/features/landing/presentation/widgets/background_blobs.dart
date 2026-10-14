import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -96,
          left: -80,
          child: _blob(288, AppColors.primaryFixed.withValues(alpha: 0.30), 34),
        ),
        Positioned(
          top: 270,
          right: -96,
          child: _blob(
            320,
            AppColors.surfaceContainerLow.withValues(alpha: 0.60),
            34,
          ),
        ),
        Positioned(
          bottom: 112,
          left: 32,
          child: _blob(384, AppColors.primaryFixed.withValues(alpha: 0.20), 24),
        ),
      ],
    ),
  );

  Widget _blob(double size, Color color, double blur) => ImageFiltered(
    imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}
