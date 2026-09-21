import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:gopay_flutter_deck/slides/registry.dart';
import 'package:gopay_flutter_deck/slides/slide_spec.dart';
import 'package:gopay_flutter_deck/theme/deck_theme.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';

void main() => runApp(const GoPayDeckApp());

class GoPayDeckApp extends StatelessWidget {
  const GoPayDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterDeckApp(
      lightTheme: deckLightTheme,
      darkTheme: deckDarkTheme,
      themeMode: ThemeMode.dark,
      speakerInfo: const FlutterDeckSpeakerInfo(
        name: 'Harsh Sharma',
        description: 'Coach · Assistant coaches: Harsh, Abhas',
        socialHandle: 'GoPay · Flutter Bootcamp',
        imagePath: 'assets/images/logo.png',
      ),
      configuration: FlutterDeckConfiguration(
        transition: FlutterDeckTransition.fade(),
        slideSize: FlutterDeckSlideSize.fromAspectRatio(
          aspectRatio: FlutterDeckAspectRatio.ratio16x9(),
          resolution: FlutterDeckResolution.fhd(),
        ),
        footer: const FlutterDeckFooterConfiguration(
          showSlideNumbers: true,
          showSocialHandle: false,
        ),
        progressIndicator: const FlutterDeckProgressIndicator.gradient(
          gradient: LinearGradient(colors: [Palette.green, Palette.blue]),
          backgroundColor: Palette.surface,
        ),
      ),
      slides: [for (final spec in slideRegistry) DeckSlide(spec)],
    );
  }
}
