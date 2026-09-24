import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        // A presentation clicker is a USB keyboard, and nearly every model
        // sends Page Down / Page Up — the keys PowerPoint listens for.
        // flutter_deck binds only the arrow keys by default, so a clicker did
        // nothing. Both are bound now; the arrows keep working as before.
        //
        // Deliberately NOT added: Space and Enter (they would hijack a focused
        // button on the interactive slides), and anything for a clicker's
        // start/stop button — it sends F5, which a browser treats as reload.
        controls: const FlutterDeckControlsConfiguration(
          shortcuts: FlutterDeckShortcutsConfiguration(
            nextSlide: {
              SingleActivator(LogicalKeyboardKey.arrowRight),
              SingleActivator(LogicalKeyboardKey.pageDown),
            },
            previousSlide: {
              SingleActivator(LogicalKeyboardKey.arrowLeft),
              SingleActivator(LogicalKeyboardKey.pageUp),
            },
          ),
        ),
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
