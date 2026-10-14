part of 'daily_log_step_two_view.dart';

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.foods, required this.onChanged});
  final Map<String, bool> foods;
  final void Function(String, bool) onChanged;

  static const _items = [
    ('🌶️', 'Makanan pedas'),
    ('🧀', 'Makanan berlemak / gorengan'),
    ('🍋', 'Makanan asam (sitrus/tomat/cuka)'),
    ('☕', 'Minuman berkafein (kopi/teh)'),
    ('🥤', 'Makanan / minuman bersoda'),
  ];

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Column(
      children: [
        for (final item in _items)
          _FoodRow(
            emoji: item.$1,
            label: item.$2,
            selected: foods[item.$2] ?? false,
            onChanged: (value) => onChanged(item.$2, value),
          ),
      ],
    ),
  );
}
