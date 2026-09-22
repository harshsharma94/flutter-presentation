import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/slides/registry.dart';
import 'package:flutter_bootcamp_deck/slides/slide_spec.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

void main() => runApp(const BootcampDeckApp());

class BootcampDeckApp extends StatelessWidget {
  const BootcampDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterDeckApp(
      lightTheme: deckLightTheme,
      darkTheme: deckDarkTheme,
      themeMode: ThemeMode.dark,
      speakerInfo: const FlutterDeckSpeakerInfo(
        name: 'Harsh Sharma',
        description: 'Coach · Assistant coaches: Harsh, Abhas',
        socialHandle: 'Flutter Bootcamp',
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
