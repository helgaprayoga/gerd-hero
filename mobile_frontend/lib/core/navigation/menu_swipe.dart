import 'package:flutter/material.dart';

class MenuSwipe extends StatelessWidget {
  const MenuSwipe({
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    super.key,
  });
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onHorizontalDragEnd: (details) {
      final velocity = details.primaryVelocity ?? 0;
      if (velocity < -280) onSwipeLeft?.call();
      if (velocity > 280) onSwipeRight?.call();
    },
    child: child,
  );
}
