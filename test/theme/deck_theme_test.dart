import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

void main() {
  test('dark theme uses the deck base and blue accent', () {
    final scheme = deckDarkTheme.materialTheme.colorScheme;
    expect(scheme.brightness, Brightness.dark);
    expect(scheme.primary, Palette.blue);
    expect(deckDarkTheme.materialTheme.scaffoldBackgroundColor, Palette.base);
  });

  test('light theme keeps the same accents', () {
    expect(deckLightTheme.materialTheme.colorScheme.primary, Palette.blue);
    expect(
      deckLightTheme.materialTheme.colorScheme.brightness,
      Brightness.light,
    );
  });

  test('correlation accents are distinct and semantic', () {
    expect(Palette.blue, isNot(Palette.green));
  });
}
