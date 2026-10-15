import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/home_dashboard_data.dart';

class HomeDailyChart extends StatelessWidget {
  const HomeDailyChart({required this.latestGerdq, this.onAction, super.key});

  final HomeGerdqData? latestGerdq;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isLikelyGerd = latestGerdq?.score != null && latestGerdq!.score >= 8;
    final scoreColor = isLikelyGerd ? AppColors.gerdLikely : AppColors.primary;
    final scoreBackground = isLikelyGerd
        ? AppColors.gerdLikelyBackground
        : AppColors.surfaceContainerLow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Skor GERD-Q Terakhir',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scoreBackground,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                latestGerdq == null
                                    ? '-- / 18'
                                    : '${latestGerdq!.score} / 18',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: scoreColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (isLikelyGerd) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.gerdLikely,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    latestGerdq?.evaluation ?? 'Belum ada hasil GERD-Q',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  if (latestGerdq == null && onAction != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: _ActionButton(
                        label: 'Isi GERD-Q',
                        onPressed: onAction!,
                      ),
                    ),
                  ],
                  if (latestGerdq != null && onAction != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: _ActionButton(
                        label: 'Evaluasi ulang',
                        onPressed: onAction!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
