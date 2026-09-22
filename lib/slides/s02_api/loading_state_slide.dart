import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/three_state_demo.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Slide 10 — `/loading-state` (2 steps, A8) ⭐ INTERACTIVE. One of only three
/// slides in the deck the audience drives instead of the arrow keys —
/// [ThreeStateDemo] is a genuine `StatefulWidget`, so its three states are
/// real `State`, not a function of `step`.
///
/// `step` drives one thing only: the step-2 note on how to reach the error
/// branch without a fake button. That note, and the `sealed`/`switch` code
/// beside the phone, are what the retired `/three-states-code` slide used to
/// carry — it reprinted this same `switch` a beat later, which taught nothing
/// the live demo had not already shown.
class LoadingStateBody extends StatelessWidget {
  const LoadingStateBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThreeStateDemo(),
              SizedBox(height: Tokens.gapLg),
              StepReveal(
                atStep: 2,
                dimWhenPast: false,
                child: SizedBox(
                  width: 860,
                  child: Text(
                    'That error button is a cheat. To hit the branch for '
                    'real: turn wifi off, or point the URL at a host that '
                    'does not exist. On Android an app with no INTERNET '
                    'permission fails the same way; on macOS it is the '
                    'network entitlement — both look like a hang, not an '
                    'error, until you catch them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 20,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
