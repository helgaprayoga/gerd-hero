import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GerdQResultHeader extends StatelessWidget {
  const GerdQResultHeader({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Container(
      height: 64,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xCCEDFDF9),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: const Text(
        'Hasil Kuesioner',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
