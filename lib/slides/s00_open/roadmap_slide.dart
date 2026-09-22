import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/roadmap_spine.dart';

/// Slide 3 — `/roadmap` (5 steps, A2). Introduces [RoadmapSpine] full-size:
/// one node lights per step, in the order the two-hour session actually
/// covers them.
class RoadmapBody extends StatelessWidget {
  const RoadmapBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapXl),
          child: RoadmapSpine(activeNode: step),
        ),
      );
}
