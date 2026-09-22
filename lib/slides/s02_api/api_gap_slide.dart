import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the phone, cloud, gap-crossing arrows and the three
/// architecture boxes are laid out against, mirroring `structure_slide.dart`
/// and `beautiful_lie_slide.dart`'s own fixed-canvas-plus-`Positioned`
/// convention so every [AnimatedArrow]'s coordinates agree with where things
/// actually render.
const _canvasWidth = 900.0;
const _canvasHeight = 260.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _phoneWidth = 150.0;
const _phoneHeight = _phoneWidth * 19.5 / 9;
const _phoneTop = 10.0;
const _laneY = _phoneTop + _phoneHeight / 2;

const _cloudSize = 100.0;
const _cloudLeft = _canvasWidth - _cloudSize;
const _cloudTop = _laneY - _cloudSize / 2;

/// Where the failed, dashed attempt (step 2) stops — the literal "gap".
const _gapMidX = (_phoneWidth + _cloudLeft) / 2;

/// Slide 5 — `/api-gap` (3 steps, A4). Opens §1 API: a phone that wants
/// data and a server that has it, with nothing between them — then the
/// naive attempt that fails, then the request that works.
///
/// This slide used to end on a Dio → Repository → Model chain. It was cut:
/// none of those three words means anything to the room yet, so the payoff
/// step was naming three unknowns instead of showing one idea. Dio arrives
/// on the next slide, Repository after the break, Model in §3.
class ApiGapBody extends StatelessWidget {
  const ApiGapBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.fromSize(
              size: _canvasSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: _phoneTop,
                    child: PhoneFrame(
                      width: _phoneWidth,
                      child: ColoredBox(color: pal.surface),
                    ),
                  ),
                  Positioned(
                    left: _cloudLeft,
                    top: _cloudTop,
                    child: Icon(
                      Icons.cloud_outlined,
                      size: _cloudSize,
                      color: pal.textSecondary,
                    ),
                  ),
                  // Step 2: the failed, dashed attempt — halts at the
                  // midpoint of the gap, never reaches the cloud. Wrapped
                  // in `StepReveal(..., until: 2, ...)` so it disappears
                  // once step 3's completed crossing takes over — a
                  // `Positioned` must stay the direct `Stack` child, with
                  // `StepReveal` nested inside it (not the other way
                  // round), or `Positioned`'s parent data never reaches
                  // the `Stack`.
                  Positioned.fill(
                    child: StepReveal(
                      atStep: 2,
                      until: 2,
                      dimWhenPast: false,
                      child: AnimatedArrow(
                        from: Offset(_phoneWidth, _laneY),
                        to: Offset(_gapMidX, _laneY),
                        atStep: 2,
                        dashed: true,
                      ),
                    ),
                  ),
                  Positioned(
                    left: _gapMidX - 14,
                    top: _laneY - 14,
                    child: StepReveal(
                      atStep: 2,
                      until: 2,
                      dimWhenPast: false,
                      child: const _ErrorPulse(),
                    ),
                  ),
                  // Step 3: the crossing that works, and the one line
                  // of code that makes it.
                  Positioned.fill(
                    child: AnimatedArrow(
                      from: Offset(_phoneWidth + 8, _laneY),
                      to: Offset(_cloudLeft - 8, _laneY),
                      atStep: 3,
                      color: Palette.blue,
                    ),
                  ),
                  Positioned(
                    left: _phoneWidth + 20,
                    top: _laneY - 44,
                    child: StepReveal(
                      atStep: 3,
                      dimWhenPast: false,
                      child: _RequestLabel(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The request itself, written the way they will type it in a minute —
/// a URL and a verb, nothing they have to take on faith.
class _RequestLabel extends StatelessWidget {
  const _RequestLabel();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Tokens.gapSm,
        vertical: Tokens.gapXs,
      ),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Text(
        'GET https://api.unsplash.com/photos',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          color: Palette.blue,
          fontSize: 21,
        ),
      ),
    );
  }
}

/// A small "×" that scales in once (rather than fading in flat), so the
/// break in the crossing reads as a distinct, momentary event rather than
/// just another element appearing. Built from [Tokens.fade]/[Tokens.curve]
/// like every other implicit animation in the deck — no
/// [AnimationController], no custom curve.
class _ErrorPulse extends StatelessWidget {
  const _ErrorPulse();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1.0),
        duration: Tokens.fade,
        curve: Tokens.curve,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Icon(Icons.close, color: Palette.red, size: 28),
      );
}
