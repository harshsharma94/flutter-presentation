import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/widgets/live_badge.dart';

/// Slide 18 — `/live-map-model` (1 step). Keyboard, not slides.
class LiveMapModelBody extends StatelessWidget {
  const LiveMapModelBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) =>
      LiveSlideBody(goal: "Map the response onto yesterday's model.");
}
