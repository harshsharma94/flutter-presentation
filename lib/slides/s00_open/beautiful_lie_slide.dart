import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the phones, code panel and connecting arrows are laid out
/// against, so every [AnimatedArrow]'s `from`/`to` agrees with where the
/// phones and code actually render. Sized to stay clear of both the fhd and
/// hd smoke-test viewports once the caption/callout row and outer padding
/// are added.
const _canvasWidth = 900.0;
const _canvasHeight = 500.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _phoneWidth = 120.0;
const _phoneHeight = _phoneWidth * 19.5 / 9;
const _phoneTop = 10.0;
const _phoneBottom = _phoneTop + _phoneHeight;

const _leftPhoneCenterX = _canvasWidth * 0.27;
const _rightPhoneCenterX = _canvasWidth * 0.73;

const _codeTop = _phoneBottom + 40;
const _codeInset = 110.0;

const _hardcodedListCode = '''
const List<Photo> photos = [
  Photo(id: '1', author: 'Alex', likes: 128),
  Photo(id: '2', author: 'Sam', likes: 64),
];''';

/// Slide 2 — `/beautiful-lie` (3 steps, A1). The hook: the bootcampers' own
/// app, looking finished, tilts up to reveal the single hardcoded list
/// feeding both of its screens.
class BeautifulLieBody extends StatelessWidget {
  const BeautifulLieBody({required this.step, super.key});

  final int step;

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
                    _tiltedPhone(
                      left: _leftPhoneCenterX - _phoneWidth / 2,
                      child: const _ListScreenPreview(),
                    ),
                    _tiltedPhone(
                      left: _rightPhoneCenterX - _phoneWidth / 2,
                      child: const _DetailScreenPreview(),
                    ),
                    Positioned(
                      left: _codeInset,
                      right: _codeInset,
                      top: _codeTop,
                      child: StepReveal(
                        atStep: 2,
                        dimWhenPast: false,
                        child: const CodePanel(
                          code: _hardcodedListCode,
                          fileName: 'lib/data/hardcoded_photos.dart',
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_leftPhoneCenterX, _codeTop),
                        to: Offset(_leftPhoneCenterX, _phoneBottom),
                        atStep: 2,
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_rightPhoneCenterX, _codeTop),
                        to: Offset(_rightPhoneCenterX, _phoneBottom),
                        atStep: 2,
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_codeInset, _codeTop + 90),
                        to: Offset(_canvasSize.width - _codeInset, _codeTop + 90),
                        atStep: 3,
                        color: Palette.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.gapMd),
              Stack(
                alignment: Alignment.center,
                children: [
                  StepReveal(
                    atStep: 1,
                    until: 1,
                    child: const Text(
                      'Yesterday.',
                      style: TextStyle(color: Palette.textSecondary, fontSize: 20),
                    ),
                  ),
                  const Callout(
                    atStep: 3,
                    text: 'Today: we delete this.',
                    color: Palette.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  /// Wraps [child] in a [PhoneFrame], positioned at [left] on the canvas,
  /// and tilts it back on the X axis once the deck reaches step 2 — the
  /// "own app, tilting up to reveal what's underneath" move the slide is
  /// built around. Animated with a [TweenAnimationBuilder] (the same
  /// step-driven technique [AnimatedArrow] uses) rather than an
  /// [AnimationController], so stepping backward untilts it cleanly.
  Widget _tiltedPhone({required double left, required Widget child}) => Positioned(
        left: left,
        top: _phoneTop,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: step >= 2 ? -0.21 : 0.0),
          duration: Tokens.travel,
          curve: Tokens.curve,
          builder: (context, angle, phone) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(angle),
            child: phone,
          ),
          child: PhoneFrame(width: _phoneWidth, child: child),
        ),
      );
}

/// A stand-in for Day 1's list screen: a grid of photo tiles with no text —
/// the point is silhouette, not content.
class _ListScreenPreview extends StatelessWidget {
  const _ListScreenPreview();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Palette.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Palette.base,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        ),
      );
}

/// A stand-in for Day 1's detail screen: a full-bleed photo placeholder with
/// an author/likes row pinned to the bottom.
class _DetailScreenPreview extends StatelessWidget {
  const _DetailScreenPreview();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Palette.base,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              right: 8,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Alex', style: TextStyle(color: Palette.textPrimary, fontSize: 10)),
                  Text('128 ♥', style: TextStyle(color: Palette.textSecondary, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      );
}
