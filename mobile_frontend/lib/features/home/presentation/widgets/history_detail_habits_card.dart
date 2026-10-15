import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'history_detail_card_shell.dart';

class HistoryDetailHabitsCard extends StatelessWidget {
  const HistoryDetailHabitsCard({
    required this.triggers,
    required this.onChanged,
    super.key,
  });

  final Set<String> triggers;
  final ValueChanged<String> onChanged;

  static const _foods = [
    ('Makanan Pedas', 'Sambal terasi saat makan siang', '🌶️'),
    ('Gorengan & Berlemak', '2 pcs tempe mendoan, 1 bakwan', '🍟'),
    ('Kafein (Kopi / Teh)', '1 cangkir es kopi susu gula aren', '☕'),
    ('Makanan Asam & Jeruk', 'Jeruk nipis pada soto ayam', '🍋'),
    ('Minuman Bersoda', 'Bebas soda sepanjang hari', '🥤'),
  ];

  @override
  Widget build(BuildContext context) => HistoryDetailCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _NumberBadge(number: '2'),
            const SizedBox(width: 8),
            const Expanded(
              child: _Heading(
                title: 'Pemicu & Kebiasaan',
                subtitle: 'Evaluasi makanan, pola makan, stres & obat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'MAKANAN & MINUMAN PEMICU',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        for (final food in _foods) ...[
          _FoodTriggerRow(
            title: food.$1,
            description: food.$2,
            emoji: food.$3,
            active: triggers.contains(_triggerKey(food.$1)),
            onChanged: () => onChanged(_triggerKey(food.$1)),
          ),
          const SizedBox(height: 10),
        ],
      ],
    ),
  );

  static String _triggerKey(String title) => switch (title) {
    'Makanan Pedas' => 'Pedas',
    'Gorengan & Berlemak' => 'Berlemak/gorengan',
    'Kafein (Kopi / Teh)' => 'Berkafein',
    'Makanan Asam & Jeruk' => 'Asam',
    _ => 'Bersoda',
  };
}

class _FoodTriggerRow extends StatelessWidget {
  const _FoodTriggerRow({
    required this.title,
    required this.description,
    required this.emoji,
    required this.active,
    required this.onChanged,
  });
  final String title;
  final String description;
  final String emoji;
  final bool active;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFFFDAD6)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _Choice(label: 'Ya', active: active, onTap: onChanged),
              _Choice(label: 'Tidak', active: !active, onTap: onChanged),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? (label == 'Ya' ? AppColors.error : AppColors.primaryContainer)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.secondary,
          fontSize: 11,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
  );
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});
  final String number;
  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Color(0x19006A61),
      shape: BoxShape.circle,
    ),
    child: Text(
      number,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    ],
  );
}
