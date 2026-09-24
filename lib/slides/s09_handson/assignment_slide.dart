import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/confetti_burst.dart';

const _canvasWidth = 1200.0;
const _canvasHeight = 600.0;

/// Slide 40 — `/assignment` (1 step). Homework, and today it is only reading.
///
/// It used to be "Tonight" with three coding tasks revealed one per step.
/// Today's homework is the references on the next slide and nothing else, so
/// the slide says exactly that and gets out of the way: one tap and the
/// reading list is on screen.
///
/// The confetti is a one-shot burst when the slide arrives — a reward for the
/// room getting through the day, not an animation anything depends on.
class AssignmentBody extends StatelessWidget {
  const AssignmentBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: _canvasWidth,
          height: _canvasHeight,
          child: Stack(
            children: [
              const Positioned.fill(child: ConfettiBurst()),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Bounce(
                      child: Icon(
                        Icons.celebration_rounded,
                        color: Palette.amber,
                        size: 120,
                      ),
                    ),
                    SizedBox(height: Tokens.gapMd),
                    Text(
                      'Homework',
                      style: TextStyle(
                        color: pal.textPrimary,
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Tokens.gapSm),
                    Text(
                      'Just one thing: read. The list is on the next slide.',
                      style: TextStyle(color: pal.textPrimary, fontSize: 32),
                    ),
                    SizedBox(height: Tokens.gapXs),
                    Text(
                      'No code tonight. You earned it.',
                      style: TextStyle(color: Palette.green, fontSize: 26),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The icon pops in with a small overshoot. Plays once per mount, like the
/// confetti behind it.
class _Bounce extends StatelessWidget {
  const _Bounce({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 700),
    curve: Curves.elasticOut,
    builder: (context, scale, child) =>
        Transform.scale(scale: scale, child: child),
    child: child,
  );
}
