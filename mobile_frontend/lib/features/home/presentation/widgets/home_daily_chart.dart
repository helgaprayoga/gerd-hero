import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/home_dashboard_data.dart';

class HomeDailyChart extends StatelessWidget {
  const HomeDailyChart({required this.latestGerdq, this.onAction, super.key});

  final HomeGerdqData? latestGerdq;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skor GERD-Q Terakhir',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  latestGerdq == null
                      ? '-- / 18'
                      : '${latestGerdq!.score} / 18',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestGerdq?.evaluation ?? 'Belum ada hasil GERD-Q',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      if (latestGerdq == null && onAction != null) ...[
                        const SizedBox(height: 8),
                        _ActionButton(
                          label: 'Isi GERD-Q',
                          onPressed: onAction!,
                        ),
                      ],
                      if (latestGerdq != null && onAction != null) ...[
                        const SizedBox(height: 8),
                        _ActionButton(
                          label: 'Evaluasi ulang',
                          onPressed: onAction!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 28),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.centerLeft,
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
