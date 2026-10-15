import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../../core/widgets/mascot_expression.dart';
import '../models/home_dashboard_data.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    required this.status,
    required this.gerdieState,
    this.onAction,
    super.key,
  });

  final HomeStatus status;
  final GerdieState gerdieState;
  final VoidCallback? onAction;

  bool get warning =>
      status == HomeStatus.symptomaticToday ||
      status == HomeStatus.evaluationDue;

  MascotExpression get _mascotExpression => switch (gerdieState) {
    GerdieState.firstVisit => MascotExpression.welcome,
    GerdieState.noSymptoms => MascotExpression.calm,
    GerdieState.moderateSymptoms => MascotExpression.moderate,
    GerdieState.highSymptoms => MascotExpression.high,
  };

  @override
  Widget build(BuildContext context) {
    final isEmpty = status == HomeStatus.noData;
    final loggedToday = status == HomeStatus.loggedToday;
    final isDue = status == HomeStatus.evaluationDue;
    final incomplete = status == HomeStatus.profileIncomplete;
    final title = incomplete
        ? 'Lengkapi profilmu\nagar aku lebih mengenalmu.'
        : loggedToday
        ? 'Mantap, log hari ini\nsudah tercatat!'
        : isDue
        ? 'Sudah waktunya\nevaluasi lagi.'
        : warning
        ? 'Hari ini terasa kurang\nnyaman. Aku temani ya.'
        : status == HomeStatus.noTodayLog
        ? 'Belum ada log hari ini.\nYuk catat kondisimu.'
        : isEmpty
        ? 'Belum ada catatan.\nYuk isi log pertamamu.'
        : 'Lambungmu terlihat\ntenang hari ini.';
    final subtitle = loggedToday
        ? 'Kebiasaan kecil yang konsisten membantu Gerdie memahami pola lambungmu.'
        : isDue
        ? 'Pantau perubahan gejalamu dengan evaluasi GERD-Q rutin.'
        : status == HomeStatus.noTodayLog
        ? 'Catat kondisi hari ini agar Gerdie bisa membantu mengenali polanya.'
        : isEmpty
        ? 'Catat makanan atau keluhan ringkas agar Gerdie bisa mengenali pola lambungmu.'
        : warning
        ? 'Tarik napas pelan. Catat keluhanmu agar kita bisa mengenali pemicunya.'
        : incomplete
        ? 'Lengkapi data dasar dan kebiasaan gaya hidup agar rekomendasi lebih akurat.'
        : 'Teks penenang anti kecemasan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: warning || isDue
              ? const [Color(0xFFFEF8EA), Color(0xFFFDECC4)]
              : isEmpty
              ? const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)]
              : const [Color(0xFFEBFBF7), Color(0xFFD6F2EC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: warning || isDue
              ? const Color(0xFFFDE68A)
              : isEmpty
              ? const Color(0xFFE2E8F0)
              : const Color(0xB299F6E4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C1F2D2B),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
                if (onAction != null) ...[
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Isi Kuesioner Sekarang'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0x66FFFFFF),
                ),
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Mascot(
                    animation: AlwaysStoppedAnimation(0),
                    expression: _mascotExpression,
                  ),
                ),
                if (warning || isDue)
                  const Positioned(
                    top: 2,
                    right: 0,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.tertiary,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
