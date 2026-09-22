import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/roadmap_spine.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the phone, cloud, gap-crossing arrows and the three
/// architecture boxes are laid out against, mirroring `structure_slide.dart`
/// and `beautiful_lie_slide.dart`'s own fixed-canvas-plus-`Positioned`
/// convention so every [AnimatedArrow]'s coordinates agree with where things
/// actually render.
const _canvasWidth = 900.0;
const _canvasHeight = 260.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _phoneWidth = 110.0;
const _phoneHeight = _phoneWidth * 19.5 / 9;
const _phoneTop = 10.0;
const _laneY = _phoneTop + _phoneHeight / 2;

const _cloudSize = 100.0;
const _cloudLeft = _canvasWidth - _cloudSize;
const _cloudTop = _laneY - _cloudSize / 2;

/// Where the failed, dashed attempt (step 2) stops — the literal "gap".
const _gapMidX = (_phoneWidth + _cloudLeft) / 2;

const _boxWidth = 140.0;
const _boxHeight = 64.0;
const _boxGap = 35.0;
const _boxesLeft =
    _phoneWidth + ((_cloudLeft - _phoneWidth) - (3 * _boxWidth + 2 * _boxGap)) / 2;
const _boxTop = _laneY - _boxHeight / 2;

double _boxLeft(int i) => _boxesLeft + i * (_boxWidth + _boxGap);

const _boxLabels = ['Dio', 'Repository', 'Model'];

/// Slide 6 — `/api-gap` (3 steps, A4). Opens §2: a phone that wants data and
/// the internet that has it, nothing bridging them yet — then the dashed,
/// failed attempt, then the three-box Dio/Repository/Model chain that
/// actually closes it.
class ApiGapBody extends StatelessWidget {
  const ApiGapBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _canvasWidth,
                child: Align(
                  alignment: Alignment.topRight,
                  child: RoadmapSpine(activeNode: 1, compact: true),
                ),
              ),
              const SizedBox(height: Tokens.gapSm),
              SizedBox.fromSize(
                size: _canvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: _phoneTop,
                      child: const PhoneFrame(
                        width: _phoneWidth,
                        child: ColoredBox(color: Palette.surface),
                      ),
                    ),
                    Positioned(
                      left: _cloudLeft,
                      top: _cloudTop,
                      child: const Icon(
                        Icons.cloud_outlined,
                        size: _cloudSize,
                        color: Palette.textSecondary,
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
                          to: const Offset(_gapMidX, _laneY),
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
                    // Step 3: the three boxes that close the gap.
                    for (var i = 0; i < _boxLabels.length; i++)
                      Positioned(
                        left: _boxLeft(i),
                        top: _boxTop,
                        width: _boxWidth,
                        height: _boxHeight,
                        child: StepReveal(
                          atStep: 3,
                          slideFrom: Offset(-0.1 - 0.03 * i, 0),
                          dimWhenPast: false,
                          child: _ArchBox(label: _boxLabels[i]),
                        ),
                      ),
                    // Step 3: the completed crossing, drawn straight through
                    // the three boxes above.
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_phoneWidth, _laneY),
                        to: Offset(_cloudLeft, _laneY),
                        atStep: 3,
                        color: Palette.blue,
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

class _ArchBox extends StatelessWidget {
  const _ArchBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Palette.surface,
          border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Palette.blue, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
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
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: const Icon(Icons.close, color: Palette.red, size: 28),
      );
}
