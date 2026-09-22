import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/widgets/live_badge.dart';

/// Slide 7 — `/live-first-request` (2 steps). Hands off to live coding: the
/// audience looks at the coach's IDE, not this screen. The full script
/// (including the deliberate missing-header 401, which sets up slide 13)
/// lives only in `SlideSpec.speakerNotes`, never on the slide itself.
class LiveFirstRequestBody extends StatelessWidget {
  const LiveFirstRequestBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => LiveSlideBody(
    goal: 'One GET. Print what comes back.',
    constraint: 'Dio only. No async, no await — not yet.',
    hints: [
      "final dio = Dio();",
      "dio.get('https://picsum.photos/v2/list')",
      "   .then((response) => print(response.data));",
    ],
  );
}
