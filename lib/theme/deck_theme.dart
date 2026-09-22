import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

const _display = 'Outfit';
const _mono = 'JetBrainsMono';

ThemeData _base(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: _display,
    scaffoldBackgroundColor: dark ? Palette.base : Palette.lightBase,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: Palette.blue,
          brightness: brightness,
        ).copyWith(
          primary: Palette.blue,
          secondary: Palette.green,
          error: Palette.red,
          surface: dark ? Palette.surface : Palette.lightSurface,
        ),
  );
}

// NOTE: `FlutterDeckThemeData.fromTheme()` (flutter_deck 0.29.0) has a bug:
// internally it does `FlutterDeckThemeData(brightness: theme.brightness)
// .merge(FlutterDeckThemeData.fromThemeAndText(theme, textTheme))`, and
// `merge` -> `copyWith` reference an unqualified `materialTheme` that
// resolves to the *receiver's* (default theme's) field, not the merged-in
// custom theme. The result is that `.fromTheme(theme).materialTheme` is
// always flutter_deck's own default blue-seeded ThemeData, silently
// discarding the ThemeData that was passed in — confirmed by reading the
// package source and empirically (materialTheme.colorScheme.primary comes
// back as a seed-derived pastel blue, not Palette.blue).
//
// The plain `FlutterDeckThemeData(theme: ...)` factory does not go through
// that merge path — it calls `fromThemeAndText(theme, textTheme)` directly,
// which stores `theme` as-is in `materialTheme`. Using it here is the
// documented, non-buggy way to get a deck theme with our own ThemeData.
final deckDarkTheme = FlutterDeckThemeData(theme: _base(Brightness.dark));
final deckLightTheme = FlutterDeckThemeData(theme: _base(Brightness.light));

/// Monospace style for every code and JSON surface in the deck.
const deckCodeStyle = TextStyle(fontFamily: _mono, fontSize: 24, height: 1.4);
