import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeGerdqPromptCard extends StatelessWidget {
  const HomeGerdqPromptCard({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.primaryFixed.withValues(alpha: .55)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C1F2D2B),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.assignment_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kuesioner GERD-Q belum diisi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Isi 6 pertanyaan singkat untuk mendapatkan gambaran awal kondisi refluksmu.',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onPressed,
          tooltip: 'Isi GERD-Q',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_forward, size: 18),
        ),
      ],
    ),
  );
}
