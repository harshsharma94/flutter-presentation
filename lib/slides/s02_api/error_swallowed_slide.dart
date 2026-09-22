import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/annotate.dart';
import 'package:gopay_flutter_deck/widgets/code_panel.dart';
import 'package:gopay_flutter_deck/widgets/phone_frame.dart';
import 'package:gopay_flutter_deck/widgets/step_reveal.dart';

const _tryCatchCode = '''
try {
  final photos = await repo.fetch();
  setState(() => _photos = photos);
} catch (e) {}''';

/// 0-indexed — the empty `catch (e) {}` block, per
/// `FlutterDeckCodeHighlight.highlightedLines`.
const _catchLine = [3];

const _codeWidth = 520.0;
const _phoneWidth = 110.0;

/// How long the clock climbs from 5s to 30s and the spinner keeps turning.
/// Deliberately not one of the deck's shared `Tokens.fade`/`Tokens.travel`
/// values — those describe a UI element settling into place; this describes
/// real wall-clock seconds passing while a person stares at a spinner, which
/// has to read as several seconds, not an instant snap. Still driven by a
/// finite, step-derived `TweenAnimationBuilder` (never a `Timer` or
/// `AnimationController`), so it settles cleanly for `pumpAndSettle` and
/// reverses correctly if the presenter steps back — see [_Spinner].
const _waitDuration = Duration(seconds: 4);

/// Slide 12 — `/error-swallowed` (3 steps, A9). The section's emotional
/// beat: an empty `catch` block, then the spinner that never resolves, then
/// the person who gave up waiting on it.
class ErrorSwallowedBody extends StatelessWidget {
  const ErrorSwallowedBody({required this.step, super.key});

  final int step;

  bool get _waiting => step >= 2;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: _codeWidth,
                    child: StepReveal(
                      atStep: 1,
                      child: const CodePanel(
                        code: _tryCatchCode,
                        fileName: 'photo_repository.dart',
                        highlightedLines: _catchLine,
                      ),
                    ),
                  ),
                  const SizedBox(width: Tokens.gapLg),
                  StepReveal(
                    atStep: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhoneFrame(
                          width: _phoneWidth,
                          child: Center(child: _Spinner(waiting: _waiting)),
                        ),
                        const SizedBox(height: Tokens.gapSm),
                        _ClockText(waiting: _waiting),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Tokens.gapLg),
              const StepReveal(
                atStep: 3,
                dimWhenPast: false,
                child: Icon(Icons.touch_app, color: Palette.textSecondary, size: 32),
              ),
              const SizedBox(height: Tokens.gapSm),
              const Callout(
                atStep: 3,
                text: "They didn't file a bug. They left.",
                color: Palette.red,
              ),
            ],
          ),
        ),
      );
}

/// The wait spinner — never [CircularProgressIndicator]: an indeterminate
/// animation never settles, which hangs `pumpAndSettle` and kills the smoke
/// test outright (the exact trap an earlier batch of this deck hit).
/// Instead the target angle is a large but finite number of turns, reached
/// over [_waitDuration] once [waiting] flips true — several real seconds of
/// visible spinning that the framework still sees as an animation with an
/// end, so it settles for the gate and reverses cleanly if the presenter
/// steps back to step 1.
class _Spinner extends StatelessWidget {
  const _Spinner({required this.waiting});

  final bool waiting;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: waiting ? math.pi * 2 * 10 : 0.0),
        duration: _waitDuration,
        curve: Tokens.curve,
        builder: (context, angle, child) => Transform.rotate(angle: angle, child: child),
        child: const Icon(Icons.autorenew, size: 28, color: Palette.textSecondary),
      );
}

/// "5s" ticking up to "30s" — the same finite-target technique as [_Spinner],
/// animating a number instead of an angle, off the same [_waitDuration] so
/// the two read as one continuous wait.
class _ClockText extends StatelessWidget {
  const _ClockText({required this.waiting});

  final bool waiting;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 5.0, end: waiting ? 30.0 : 5.0),
        duration: _waitDuration,
        curve: Tokens.curve,
        builder: (context, seconds, child) => Text(
          '${seconds.round()}s',
          style: const TextStyle(
            color: Palette.textSecondary,
            fontFamily: 'JetBrainsMono',
            fontSize: 18,
          ),
        ),
      );
}
