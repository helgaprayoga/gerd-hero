import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_card_icon.dart';
import 'home_card_shell.dart';

class HomeEmptyLogCard extends StatelessWidget {
  const HomeEmptyLogCard({super.key});

  @override
  Widget build(BuildContext context) => const HomeCardShell(
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Belum ada catatan.\nYuk isi log pertamamu.',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              height: 1.38,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        HomeCardIcon(icon: Icons.edit_note, large: true),
      ],
    ),
  );
}
