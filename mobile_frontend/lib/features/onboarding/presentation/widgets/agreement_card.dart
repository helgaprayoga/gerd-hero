import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AgreementCard extends StatelessWidget {
  const AgreementCard({required this.isAgreed, required this.onTap, super.key});

  final bool isAgreed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: isAgreed ? AppColors.surfaceContainerLow : Colors.white,
    borderRadius: BorderRadius.circular(12),
    elevation: 1,
    shadowColor: const Color(0x12000000),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAgreed
                        ? AppColors.primary
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isAgreed
                        ? const Icon(
                            Icons.check,
                            key: ValueKey('checked'),
                            color: Colors.white,
                            size: 18,
                          )
                        : const SizedBox(key: ValueKey('unchecked')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Saya memahami dan menyetujui.',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                'Centang kotak di atas untuk membuka akses ke langkah selanjutnya.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
