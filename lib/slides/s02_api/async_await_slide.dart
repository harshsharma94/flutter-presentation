import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/annotate.dart';
import 'package:gopay_flutter_deck/widgets/correlation_panel.dart';
import 'package:gopay_flutter_deck/widgets/frame_strip.dart';
import 'package:gopay_flutter_deck/widgets/phone_frame.dart';
import 'package:gopay_flutter_deck/widgets/step_reveal.dart';

/// Fixed canvas the two lanes, the phone and the floating `fetchPhotos()`
/// block are laid out against — the same fixed-canvas-plus-`Positioned`
/// convention every other diagram slide in this deck uses, so every
/// coordinate below agrees with what actually renders.
const _canvasWidth = 980.0;
const _canvasHeight = 220.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _lanesLeft = 0.0;
const _lanesWidth = 800.0;

const _mainLaneTop = 32.0;
const _laneHeight = 36.0;
const _mainLaneCenterY = _mainLaneTop + _laneHeight / 2;

const _secondLaneTop = 118.0;
const _secondLaneCenterY = _secondLaneTop + _laneHeight / 2;

const _phoneWidth = 100.0;
const _phoneLeft = _canvasWidth - _phoneWidth;

const _frameCount = 60;

/// The tick range `fetchPhotos()` sits over once it "drops onto" the strip
/// (step 2) — the range [FrameStrip] paints red while [_isBlocked] is true.
const _stalledFrom = 25;
const _stalledTo = 40;

const _blockWidth = 170.0;
const _blockHeight = 40.0;

/// Centred over the [_stalledFrom]..[_stalledTo] tick range.
const _blockLeft =
    _lanesLeft + (_stalledFrom + _stalledTo) / 2 / _frameCount * _lanesWidth - _blockWidth / 2;
const _blockTopInMainLane = _mainLaneCenterY - _blockHeight / 2;
const _blockTopInSecondLane = _secondLaneCenterY - _blockHeight / 2;

/// Slide 9 — `/async-await` (4 steps, A6) ⭐ PROTECTED. One of four slides in
/// the deck where the animation *is* the explanation rather than an
/// illustration of one — see the file-level rationale on [_Spinner] for the
/// single detail that makes or breaks it.
///
/// Step 1: 60 ticks flowing green, the phone's spinner turning. Step 2: a
/// synchronous `fetchPhotos()` call drops onto the strip — the ticks under
/// it go red and stop, the spinner freezes. Step 3: the same call detaches
/// onto a second "suspended" lane; the strip resumes, the spinner spins
/// again. Step 4: the result rejoins the main lane and four other
/// languages' names for the same idea fade in.
class AsyncAwaitBody extends StatelessWidget {
  const AsyncAwaitBody({required this.step, super.key});

  final int step;

  bool get _isBlocked => step == 2;
  bool get _isSuspended => step == 3;

  double get _blockTop => _isSuspended ? _blockTopInSecondLane : _blockTopInMainLane;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.fromSize(
                size: _canvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _lanesLeft,
                      top: 0,
                      child: StepReveal(
                        atStep: 1,
                        until: 1,
                        child: const Text(
                          '60 fps.',
                          style: TextStyle(color: Palette.textPrimary, fontSize: 20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _lanesLeft,
                      top: _mainLaneTop,
                      width: _lanesWidth,
                      height: _laneHeight,
                      child: FrameStrip(
                        frameCount: _frameCount,
                        stalledFrom: _stalledFrom,
                        stalledTo: _stalledTo,
                        stalled: _isBlocked,
                        height: _laneHeight,
                      ),
                    ),
                    Positioned(
                      left: _lanesLeft,
                      top: _secondLaneTop,
                      width: _lanesWidth,
                      height: _laneHeight,
                      child: DashedBox(
                        atStep: 3,
                        color: Palette.blue,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: Tokens.gapSm),
                            child: Text(
                              'await — suspended',
                              style: TextStyle(
                                color: Palette.blue.withValues(alpha: Tokens.dimmed),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // The floating `fetchPhotos()` call: hidden at step 1,
                    // then repositioned between the main and suspended
                    // lanes purely as a function of `step` — see
                    // [_blockTop].
                    AnimatedPositioned(
                      duration: Tokens.travel,
                      curve: Tokens.curve,
                      left: _blockLeft,
                      top: _blockTop,
                      child: AnimatedOpacity(
                        duration: Tokens.fade,
                        curve: Tokens.curve,
                        opacity: step >= 2 ? 1.0 : 0.0,
                        child: IgnorePointer(child: _FetchBlock(blocked: _isBlocked)),
                      ),
                    ),
                    Positioned(
                      left: _blockLeft,
                      top: _blockTopInMainLane + _blockHeight + Tokens.gapXs,
                      child: const Callout(
                        atStep: 2,
                        text: 'blocked · 2.3s · 138 frames dropped',
                        color: Palette.red,
                      ),
                    ),
                    Positioned(
                      left: _phoneLeft,
                      top: 0,
                      child: PhoneFrame(
                        width: _phoneWidth,
                        child: Center(child: _Spinner(step: step)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.gapMd),
              const CorrelationPanel(
                flutterLabel: 'await',
                firstStep: 4,
                stepsPerRow: 0,
                rows: [
                  CorrelationRow(platform: 'Kotlin', concept: 'suspend'),
                  CorrelationRow(platform: 'Swift', concept: 'async/await'),
                  CorrelationRow(platform: 'Go', concept: 'goroutine'),
                  CorrelationRow(platform: 'Java', concept: 'CompletableFuture'),
                ],
              ),
            ],
          ),
        ),
      );
}

class _FetchBlock extends StatelessWidget {
  const _FetchBlock({required this.blocked});

  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final color = blocked ? Palette.red : Palette.blue;
    return Container(
      width: _blockWidth,
      height: _blockHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Palette.surface,
        border: Border.all(color: color, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Text(
        'fetchPhotos()',
        style: TextStyle(color: color, fontFamily: 'JetBrainsMono', fontSize: 16),
      ),
    );
  }
}

/// The phone's loading spinner — and the single detail this whole slide
/// stands or falls on.
///
/// Its rotation is driven **only** by [step] via [_targetAngle], animated
/// toward that target with a plain, finite `Tokens.travel`
/// [TweenAnimationBuilder] — the same step-derived-target technique
/// `beautiful_lie_slide.dart`'s tilted phone uses — rather than an
/// [AnimationController] or [Timer] of this deck's own authorship, or (an
/// earlier version of this widget) Flutter's own indeterminate
/// [CircularProgressIndicator].
///
/// That earlier version is worth recording because it failed for two
/// independent reasons, not one: a perpetually-spinning indicator would
/// have kept moving straight through step 2 regardless of any surrounding
/// "frozen" state, which is the pedagogical failure the task brief warns
/// about directly — but it also never reached the screen at all, because
/// `slides_smoke_test.dart` calls `pumpAndSettle()` on every slide at every
/// step, and an indeterminate animation never settles: the whole gate timed
/// out on this slide alone. Deriving the angle from `step` fixes both at
/// once — the animation is finite (it reaches [_targetAngle] and stops, so
/// `pumpAndSettle` succeeds), and step 2's target is simply never visited by
/// a running animation, so a screenshot taken at any point during step 2
/// looks identical to any other: it genuinely does not move.
///
/// Steps 1, 3 and 4 ("spinning") each advance the target by half a turn, so
/// stepping forward through them always reads as continued motion rather
/// than snapping back; step 2 ("frozen") breaks from that cadence with an
/// arbitrary, non-cardinal angle instead, so it reads as "caught mid-turn"
/// rather than a glyph that conveniently stopped on a round number.
class _Spinner extends StatelessWidget {
  const _Spinner({required this.step});

  final int step;

  bool get _frozen => step == 2;

  double get _targetAngle => _frozen ? 0.9 : step * math.pi;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28,
        height: 28,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: _targetAngle),
          duration: Tokens.travel,
          curve: Tokens.curve,
          builder: (context, angle, child) => Transform.rotate(angle: angle, child: child),
          child: Icon(
            Icons.autorenew,
            size: 28,
            color: _frozen ? Palette.red : Palette.textPrimary,
          ),
        ),
      );
}
