import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/three_state_demo.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 12 — `/loading-state` (1 step, A8) ⭐ INTERACTIVE. One of only three
/// slides in the deck the audience drives instead of the arrow keys —
/// [ThreeStateDemo] is a genuine `StatefulWidget`, so its three states are
/// real `State`, not a function of `step`, which is accepted here only to
/// satisfy the body/wrapper convention every slide follows.
///
/// Nothing but the phone. The `switch` that produces these three branches is
/// slide 13's job, two beats later — printed here as well it was the same
/// lesson twice on adjacent slides.
class LoadingStateBody extends StatelessWidget {
  const LoadingStateBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: ThreeStateDemo(),
      ),
    ),
  );
}
