import 'package:flutter/material.dart';

/// Raw colour constants for the deck. Accents carry semantic roles:
/// [blue] means "Flutter / the new thing", [green] means "what you already know".
abstract final class Palette {
  static const base = Color(0xFF0B0E13);
  static const surface = Color(0xFF141922);
  static const blue = Color(0xFF118EEA);   // GoPay
  static const green = Color(0xFF00AA5B);  // Gojek
  static const amber = Color(0xFFF5A623);
  static const red = Color(0xFFE5484D);
  static const textPrimary = Color(0xFFE8EDF4);
  static const textSecondary = Color(0xFF93A1B5);

  static const lightBase = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF4F7FB);
  static const lightTextPrimary = Color(0xFF0B0E13);
  static const lightTextSecondary = Color(0xFF5A6B80);
}
