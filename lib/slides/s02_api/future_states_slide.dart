import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the three circles and the two branch arrows are laid out
/// against, mirroring every other diagram slide's fixed-canvas-plus-
/// `Positioned` convention so the arrows' coordinates agree with where the
/// circles actually render.
const _canvasWidth = 780.0;
const _canvasHeight = 330.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _circleSize = 96.0;

const _pendingLeft = 30.0;
const _pendingCenterY = _canvasHeight / 2;
const _pendingRight = _pendingLeft + _circleSize;

const _outcomeLeft = _canvasWidth - _circleSize - 140.0;
const _dataTop = 18.0;
const _errorTop = _canvasHeight - _circleSize - 18.0;
const _dataCenterY = _dataTop + _circleSize / 2;
const _errorCenterY = _errorTop + _circleSize / 2;

/// Slide 8 — `/future-states` (4 steps, A7). Defines the thing before the
/// next slide animates it: a `Future` is a receipt for a value that does not
/// exist yet.
///
/// It is drawn as a **fork**, and that is the whole correction. An earlier
/// version filled one circle from `pending` to `data` and then drew an arrow
/// from `data` to a second circle marked `error` — which says a Future
/// resolves with a value and *then* fails. It does not, and the slide's own
/// heading says so: it settles exactly once, exactly one way. Two arrows
/// leaving `pending`, with `or` between them, is the model; the data branch
/// dims when the error branch arrives so the second is read as the
/// alternative, never as what happened next.
class FutureStatesBody extends StatelessWidget {
  const FutureStatesBody({required this.step, super.key});

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
              Text(
                'A Future is a receipt for a value you do not have yet.',
                style: TextStyle(color: pal.textPrimary, fontSize: 32),
              ),
              SizedBox(height: Tokens.gapXs),
              Text(
                'You get it the instant you ask. It settles exactly once, '
                'later, exactly one way.',
                style: TextStyle(color: pal.textSecondary, fontSize: 22),
              ),
              SizedBox(height: Tokens.gapLg),
              SizedBox.fromSize(
                size: _canvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _pendingLeft,
                      top: _pendingCenterY - _circleSize / 2,
                      child: const _OutcomeCircle(
                        filled: false,
                        color: Palette.blue,
                        label: 'pending',
                      ),
                    ),
                    // The two branches. Neither follows the other.
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 2,
                        child: AnimatedArrow(
                          from: Offset(_pendingRight, _pendingCenterY - 12),
                          to: Offset(_outcomeLeft - 8, _dataCenterY),
                          atStep: 2,
                          color: Palette.blue,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(_pendingRight, _pendingCenterY + 12),
                          to: Offset(_outcomeLeft - 8, _errorCenterY),
                          atStep: 3,
                          color: Palette.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _pendingRight + 120,
                      top: _pendingCenterY - 18,
                      child: StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: pal.textPrimary,
                            fontSize: 30,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _outcomeLeft,
                      top: _dataTop,
                      child: StepReveal(
                        atStep: 2,
                        child: const _OutcomeCircle(
                          filled: true,
                          color: Palette.blue,
                          label: 'data',
                        ),
                      ),
                    ),
                    Positioned(
                      left: _outcomeLeft,
                      top: _errorTop,
                      child: StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: const _OutcomeCircle(
                          filled: true,
                          color: Palette.red,
                          label: 'error',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              StepReveal(
                atStep: 3,
                dimWhenPast: false,
                child: SizedBox(
                  width: 900,
                  child: Text(
                    'One or the other. Never both, never neither, never '
                    'twice — and the error branch is part of the model, not '
                    'an edge case bolted onto it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 21,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 4,
                dimWhenPast: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'And there is no cancel().',
                      style: TextStyle(color: Palette.amber, fontSize: 26),
                    ),
                    SizedBox(height: Tokens.gapXs),
                    SizedBox(
                      width: 900,
                      child: Text(
                        'You can stop caring about the answer. You cannot stop '
                        'the work — it finishes, and any error it throws still '
                        'has to land somewhere. Aborting the request itself is '
                        'the HTTP client\u2019s job, not the Future\u2019s: '
                        'that is Dio\u2019s CancelToken.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: pal.textSecondary,
                          fontSize: 21,
                          height: 1.35,
                        ),
                      ),
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

/// One circle: an outline that fills solid once [filled], with [label]
/// cross-fading beneath it.
class _OutcomeCircle extends StatelessWidget {
  const _OutcomeCircle({
    required this.filled,
    required this.color,
    required this.label,
  });

  final bool filled;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => _PulseOnce(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Tokens.travel,
          curve: Tokens.curve,
          width: _circleSize,
          height: _circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: Tokens.strokeWidth),
          ),
        ),
        SizedBox(height: Tokens.gapSm),
        AnimatedSwitcher(
          duration: Tokens.fade,
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(color: color, fontSize: 20),
          ),
        ),
      ],
    ),
  );
}

/// A single scale-in pulse played once when this subtree first mounts —
/// this slide's stand-in for a "pending" breathing pulse that stops short of
/// an indeterminate, never-settling animation. `CircularProgressIndicator`
/// and friends are banned deck-wide: an indeterminate animation never
/// settles, so `pumpAndSettle` hangs and the smoke test dies rather than
/// failing cleanly. [TweenAnimationBuilder] only re-animates when its
/// `tween.end` changes between builds; [begin]/[end] here are both constant,
/// so this plays exactly once per mount and then holds still for good —
/// finite by construction.
class _PulseOnce extends StatelessWidget {
  const _PulseOnce({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.85, end: 1.0),
    duration: Tokens.fade,
    curve: Tokens.curve,
    builder: (context, scale, child) =>
        Transform.scale(scale: scale, child: child),
    child: child,
  );
}
