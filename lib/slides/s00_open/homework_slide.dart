import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/widgets/live_badge.dart';

/// Slide 4 — `/homework` (1 step). Hands off to live coding: the audience
/// looks at the coach's IDE, not this screen, so the coaching script lives
/// only in `SlideSpec.speakerNotes`, never on the slide itself.
class HomeworkBody extends StatelessWidget {
  const HomeworkBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) =>
      const LiveSlideBody(goal: 'Show us what you built.');
}
