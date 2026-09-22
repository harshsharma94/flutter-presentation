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
const _canvasWidth = 980.0;
const _canvasHeight = 620.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _phoneWidth = 168.0;
const _phoneHeight = _phoneWidth * 19.5 / 9;
const _phoneTop = 10.0;

/// The two screens sit at different heights rather than shoulder to
/// shoulder. Levelled, they read as one duplicated screenshot; staggered,
/// they read as two screens of the same app — which is the point, since
/// both are fed by the one list underneath.
const _phoneStagger = 54.0;
const _leftPhoneTop = _phoneTop;
const _rightPhoneTop = _phoneTop + _phoneStagger;
const _phoneBottom = _rightPhoneTop + _phoneHeight;

const _leftPhoneCenterX = _canvasWidth * 0.26;
const _rightPhoneCenterX = _canvasWidth * 0.74;

const _codeTop = _phoneBottom + 34;
const _codeInset = 110.0;

const _hardcodedListCode = '''
List<Photo> photos = [
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
              SizedBox.fromSize(
                size: _canvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _tiltedPhone(
                      left: _leftPhoneCenterX - _phoneWidth / 2,
                      top: _leftPhoneTop,
                      child: const _ListScreenPreview(),
                    ),
                    _tiltedPhone(
                      left: _rightPhoneCenterX - _phoneWidth / 2,
                      top: _rightPhoneTop,
                      child: const _DetailScreenPreview(),
                    ),
                    Positioned(
                      left: _codeInset,
                      right: _codeInset,
                      top: _codeTop,
                      child: StepReveal(
                        atStep: 2,
                        dimWhenPast: false,
                        child: CodePanel(
                          code: _hardcodedListCode,
                          fileName: 'lib/data/product_list.dart',
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_leftPhoneCenterX, _codeTop),
                        to: Offset(
                            _leftPhoneCenterX, _leftPhoneTop + _phoneHeight),
                        atStep: 2,
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_rightPhoneCenterX, _codeTop),
                        to: Offset(
                            _rightPhoneCenterX, _rightPhoneTop + _phoneHeight),
                        atStep: 2,
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_codeInset, _codeTop + 90),
                        to: Offset(
                            _canvasSize.width - _codeInset, _codeTop + 90),
                        atStep: 3,
                        color: Palette.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              Stack(
                alignment: Alignment.center,
                children: [
                  StepReveal(
                    atStep: 1,
                    until: 1,
                    child: Text(
                      'Yesterday.',
                      style: TextStyle(color: pal.textSecondary, fontSize: 24),
                    ),
                  ),
                  Callout(
                    atStep: 3,
                    text: 'Today: we delete this.',
                    color: Palette.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps [child] in a [PhoneFrame], positioned at [left] on the canvas,
  /// and tilts it back on the X axis once the deck reaches step 2 — the
  /// "own app, tilting up to reveal what's underneath" move the slide is
  /// built around. Animated with a [TweenAnimationBuilder] (the same
  /// step-driven technique [AnimatedArrow] uses) rather than an
  /// [AnimationController], so stepping backward untilts it cleanly.
  Widget _tiltedPhone({
    required double left,
    required double top,
    required Widget child,
  }) =>
      Positioned(
        left: left,
        top: top,
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
///
/// Everything is sized off the frame's own width rather than in fixed pixels,
/// so the grid keeps its proportions whatever [_phoneWidth] is set to. It was
/// pinned to 38px tiles for a 120px frame, which left the grid stranded in a
/// corner once the phones were enlarged.
class _ListScreenPreview extends StatelessWidget {
  const _ListScreenPreview();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return ColoredBox(
      color: pal.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final gap = w * 0.05;
          final tile = (w - gap * 3) / 2;

          return Padding(
            padding: EdgeInsets.fromLTRB(gap, w * 0.16, gap, gap),
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < 6; i++)
                  Container(
                    width: tile,
                    height: tile,
                    decoration: BoxDecoration(
                      // A tint of the text colour rather than a ground
                      // colour: in light mode a surface-on-surface tile is
                      // invisible, which is what made these read as missing.
                      color: pal.textSecondary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(w * 0.04),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A stand-in for Day 1's detail screen: a full-bleed photo placeholder with
/// an author/likes row pinned to the bottom.
class _DetailScreenPreview extends StatelessWidget {
  const _DetailScreenPreview();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return ColoredBox(
          color: pal.surface,
          child: Stack(
            children: [
              // The photo placeholder, drawn as a tinted block so it reads on
              // either ground.
              Positioned(
                left: w * 0.05,
                right: w * 0.05,
                top: w * 0.16,
                height: w * 1.35,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pal.textSecondary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(w * 0.04),
                  ),
                ),
              ),
              Positioned(
                left: w * 0.05,
                right: w * 0.05,
                bottom: w * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alex',
                      style: TextStyle(
                        color: pal.textPrimary,
                        fontSize: w * 0.09,
                      ),
                    ),
                    Text(
                      '128 \u2665',
                      style: TextStyle(
                        color: pal.textSecondary,
                        fontSize: w * 0.09,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
