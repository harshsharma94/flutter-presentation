import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/demos/three_state_demo.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';

/// Slide 11 — `/loading-state` (1 step, A8) ⭐ INTERACTIVE. One of only three
/// slides in the deck (11, 34, 36) the audience drives instead of the arrow
/// keys — [ThreeStateDemo] is a genuine `StatefulWidget`. `step` is accepted
/// only to satisfy the body/wrapper convention every slide follows and is
/// unused here.
class LoadingStateBody extends StatelessWidget {
  const LoadingStateBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(Tokens.gapLg),
          child: ThreeStateDemo(),
        ),
      );
}
