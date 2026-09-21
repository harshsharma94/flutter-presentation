import 'package:flutter/animation.dart';

/// The deck's motion language and spacing scale. One curve, two durations.
abstract final class Tokens {
  static const fade = Duration(milliseconds: 300);
  static const travel = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic;

  /// Completed steps dim to this rather than disappearing, so the audience
  /// keeps the context of what came before.
  static const dimmed = 0.4;

  static const gapXs = 8.0;
  static const gapSm = 16.0;
  static const gapMd = 24.0;
  static const gapLg = 40.0;
  static const gapXl = 64.0;

  static const radius = 12.0;
  static const strokeWidth = 2.0;
}
