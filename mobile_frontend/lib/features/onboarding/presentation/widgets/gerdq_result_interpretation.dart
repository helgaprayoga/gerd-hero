import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'gerdq_classification_row.dart';

class GerdQResultInterpretation extends StatelessWidget {
  const GerdQResultInterpretation({required this.score, super.key});

  final int score;

  bool get isLikelyGerd => score >= 8;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
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
        Text(
          'Interpretasi Hasil',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Klasifikasi acuan instrumen GERD-Q standar:',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        GerdQClassificationRow(
          score: '0 – 7',
          label: 'Tidak menderita GERD',
          active: !isLikelyGerd,
        ),
        SizedBox(height: 8),
        GerdQClassificationRow(
          score: '8 – 18',
          label: 'Kemungkinan menderita GERD',
          active: isLikelyGerd,
        ),
        SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x4CDCECE8),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hasil ini merupakan skrining awal, bukan diagnosis mutlak. Jika nyeri dada atau sesak berlanjut, segera temui dokter spesialis gastroenterologi.',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
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
