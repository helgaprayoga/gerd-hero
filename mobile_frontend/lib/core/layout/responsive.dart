import 'package:flutter/material.dart';

/// Small responsive helpers shared by compact mobile layouts.
abstract final class Responsive {
  /// Widths below this value use stacked actions and tighter layouts.
  static const compactBreakpoint = 360.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static EdgeInsets horizontalPadding(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: isCompact(context) ? 16 : 20);
}
