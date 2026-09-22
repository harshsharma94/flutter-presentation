import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/widgets/live_badge.dart';

/// Slide 8 — `/live-first-request` (1 step). Hands off to live coding: the
/// audience looks at the coach's IDE, not this screen. The full script
/// (including the deliberate missing-header 401, which sets up slide 15)
/// lives only in `SlideSpec.speakerNotes`, never on the slide itself.
class LiveFirstRequestBody extends StatelessWidget {
  const LiveFirstRequestBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) =>
      const LiveSlideBody(goal: 'One GET. Print the JSON.');
}
