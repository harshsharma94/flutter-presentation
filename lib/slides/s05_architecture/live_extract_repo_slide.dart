import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/widgets/live_badge.dart';

/// Slide 24 — `/live-extract-repo` (1 step).
class LiveExtractRepoBody extends StatelessWidget {
  const LiveExtractRepoBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) =>
      LiveSlideBody(goal: 'Pull the Dio call out of the widget.');
}
