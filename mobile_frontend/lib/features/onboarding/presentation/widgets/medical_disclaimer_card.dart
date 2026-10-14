import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'disclaimer_card_header.dart';
import 'disclaimer_guidance_row.dart';
import 'disclaimer_surface_card.dart';

class MedicalDisclaimerCard extends StatelessWidget {
  const MedicalDisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) => DisclaimerSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DisclaimerCardHeader(
          icon: Icons.verified_user,
          title: 'Penting untuk Diketahui',
          subtitle: 'Protokol Pemantauan Mandiri',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aplikasi ini membantu memantau gejala dan risiko jangka panjang. Aplikasi ini bukan alat diagnosis dan tidak menggantikan konsultasi dokter.',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurface,
                    height: 20 / 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const DisclaimerGuidanceRow(
          icon: Icons.medical_services,
          iconBackground: AppColors.tertiaryFixed,
          iconColor: AppColors.onSurface,
          title: 'Bukan Pengganti Dokter',
          body:
              'Jika mengalami gejala darurat seperti nyeri dada hebat, sesak napas, atau muntah terus-menerus, segera kunjungi instalasi gawat darurat (IGD).',
        ),
        const SizedBox(height: 16),
        const DisclaimerGuidanceRow(
          icon: Icons.lock,
          iconBackground: AppColors.surfaceContainerHigh,
          iconColor: AppColors.primary,
          title: 'Data Pribadi Anda',
          body:
              'Seluruh riwayat catatan gejala tersimpan dengan enkripsi aman dan hanya untuk pemantauan pribadi Anda.',
        ),
      ],
    ),
  );
}
