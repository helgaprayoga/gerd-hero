import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';

class GerdQResultMascot extends StatelessWidget {
  const GerdQResultMascot({required this.isLikelyGerd, super.key});

  final bool isLikelyGerd;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: isLikelyGerd
          ? Colors.white
          : AppColors.primaryFixed.withValues(alpha: 0.40),
      shape: BoxShape.circle,
      border: isLikelyGerd ? Border.all(color: const Color(0x4CBCC9C6)) : null,
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: Mascot(animation: AlwaysStoppedAnimation(0)),
        ),
        if (isLikelyGerd)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high,
                color: Colors.white,
                size: 11,
              ),
            ),
          ),
      ],
    ),
  );
}
