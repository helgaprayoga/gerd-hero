import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/google_logo.svg',
    width: 20,
    height: 20,
    semanticsLabel: 'Logo Google',
  );
}
