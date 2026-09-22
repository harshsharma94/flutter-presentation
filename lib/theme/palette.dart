import 'package:flutter/material.dart';

/// Raw colour constants for the deck. Accents carry semantic roles:
/// [blue] means "Flutter / the new thing", [green] means "what you already know".
abstract final class Palette {
  static const base = Color(0xFF0B0E13);
  static const surface = Color(0xFF141922);
  static const blue = Color(0xFF118EEA); // primary accent
  static const green = Color(0xFF00AA5B); // familiar-platform accent
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
  static const lightSurface = Color(0xFFEDF1F7);
  static const lightTextPrimary = Color(0xFF0B0E13);
  static const lightTextSecondary = Color(0xFF4A5A6E);

  static const _dark = DeckColors(
    base: base,
    surface: surface,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
  );

  static const _light = DeckColors(
    base: lightBase,
    surface: lightSurface,
    textPrimary: lightTextPrimary,
    textSecondary: lightTextSecondary,
  );

  /// The ground-and-text colours for the theme currently in effect.
  ///
  /// The accents above are deliberately absent: [blue], [green], [amber] and
  /// [red] carry meaning, and that meaning must not change with the theme.
  /// Only the ground and the text on it flip.
  static DeckColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

/// The four colours that depend on which way round the deck is running.
///
/// Slides read these through [Palette.of] rather than as constants. They
/// were constants originally, which meant a slide painted near-white text
/// no matter what the theme said — light mode rendered titles invisible.
class DeckColors {
  const DeckColors({
    required this.base,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color base;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
}
