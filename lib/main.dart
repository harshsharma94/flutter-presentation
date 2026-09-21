import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

void main() => runApp(const GoPayDeckApp());

class GoPayDeckApp extends StatelessWidget {
  const GoPayDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterDeckApp(
      configuration: FlutterDeckConfiguration(
        transition: FlutterDeckTransition.fade(),
        slideSize: FlutterDeckSlideSize.fromAspectRatio(
          aspectRatio: FlutterDeckAspectRatio.ratio16x9(),
          resolution: FlutterDeckResolution.fhd(),
        ),
      ),
      slides: [
        FlutterDeckSlide.title(
          configuration: const FlutterDeckSlideConfiguration(route: '/title'),
          title: 'GoPay · Flutter Bootcamp',
          subtitle: 'Day 2 — Making It Real',
        ),
      ],
    );
  }
}
