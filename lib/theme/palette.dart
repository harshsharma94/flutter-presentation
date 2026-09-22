import 'package:flutter/material.dart';

/// Raw colour constants for the deck. Accents carry semantic roles:
/// [blue] means "Flutter / the new thing", [green] means "what you already know".
abstract final class Palette {
  static const base = Color(0xFF0B0E13);
  static const surface = Color(0xFF141922);
  static const blue = Color(0xFF118EEA);   // primary accent
  static const green = Color(0xFF00AA5B);  // familiar-platform accent
  static const amber = Color(0xFFF5A623);
  static const red = Color(0xFFE5484D);
  static const textPrimary = Color(0xFFE8EDF4);
  /// Secondary text. Deliberately a mid-slate rather than the pale blue-grey
  /// it started as: slides hardcode this constant, so one value has to read
  /// on both grounds. At the deck's type sizes it clears the large-text
  /// contrast threshold on white (~4.0:1) and on [base] (~4.8:1); the old
  /// value managed only 2.5:1 on white, which is what made light-mode
  /// subtitles look washed out.
  static const textSecondary = Color(0xFF6E8098);

  static const lightBase = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF4F7FB);
  static const lightTextPrimary = Color(0xFF0B0E13);
  static const lightTextSecondary = Color(0xFF5A6B80);
}
