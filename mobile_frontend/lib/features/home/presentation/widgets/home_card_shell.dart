import 'package:flutter/material.dart';

class HomeCardShell extends StatelessWidget {
  const HomeCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A1F2D2B),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
