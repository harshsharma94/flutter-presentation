import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/frame_strip.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

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

const _blockWidth = 290.0;
const _blockHeight = 40.0;

/// Centred over the [_stalledFrom]..[_stalledTo] tick range.
const _blockLeft =
    _lanesLeft +
    (_stalledFrom + _stalledTo) / 2 / _frameCount * _lanesWidth -
    _blockWidth / 2;
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

  double get _blockTop =>
      _isSuspended ? _blockTopInSecondLane : _blockTopInMainLane;

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
              // Above the canvas, not inside it: at top 0 this sat under the
              // frame strip. [StepReveal] holds its space when hidden, so
              // nothing below it moves when the heading fades at step 2.
              SizedBox(
                width: _canvasWidth,
                child: StepReveal(
                  atStep: 1,
                  until: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'One thread draws your whole UI.',
                        style: TextStyle(color: pal.textPrimary, fontSize: 26),
                      ),
                      Text(
                        'A frame every 16ms. Hold it up and nothing moves '
                        '— not even the spinner.',
                        style: TextStyle(
                          color: pal.textSecondary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              SizedBox.fromSize(
                size: _canvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                            padding: EdgeInsets.only(left: Tokens.gapSm),
                            child: Text(
                              'await — suspended',
                              style: TextStyle(
                                color: Palette.blue.withValues(
                                  alpha: Tokens.dimmed,
                                ),
                                fontSize: 17,
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
                        child: IgnorePointer(
                          child: _FetchBlock(blocked: _isBlocked),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _blockLeft,
                      top: _blockTopInMainLane + _blockHeight + Tokens.gapXs,
                      child: Callout(
                        atStep: 2,
                        text:
                            'a tight loop, a huge jsonDecode · '
                            '138 frames dropped',
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
              SizedBox(height: Tokens.gapMd),
              // [CorrelationPanel] uses `Expanded` internally, so it needs a
              // bounded width — which the enclosing [FittedBox] does not give.
              SizedBox(
                width: _canvasWidth,
                child: CorrelationPanel(
                  flutterLabel: 'await',
                  firstStep: 4,
                  stepsPerRow: 0,
                  rows: [
                    CorrelationRow(platform: 'Kotlin', concept: 'suspend'),
                    CorrelationRow(platform: 'Swift', concept: 'async/await'),
                    CorrelationRow(platform: 'Go', concept: 'goroutine'),
                    CorrelationRow(
                      platform: 'Java',
                      concept: 'CompletableFuture',
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

class _FetchBlock extends StatelessWidget {
  const _FetchBlock({required this.blocked});

  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final color = blocked ? Palette.red : Palette.blue;
    return Container(
      width: _blockWidth,
      height: _blockHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: color, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      // The label is wider than a comfortable block at full size, and a
      // clipped one reads as a bug rather than a design — so the block keeps
      // the fixed width the slide's geometry is derived from, and the text
      // shrinks to fit inside it instead of running past the border.
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Tokens.gapSm),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'work that never yields',
            style: TextStyle(
              color: color,
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// The phone's loading spinner — the single detail this whole slide stands
/// or falls on.
///
/// It **genuinely spins**, continuously, whenever the UI is alive (steps 1, 3
/// and 4), and **genuinely stops dead** on step 2 when the synchronous call
/// blocks the thread. The contrast is the entire lesson: a spinner that was
/// never moving cannot be seen to freeze, and an audience watching a static
/// icon next to the words "UI blocked" learns nothing.
///
/// This is the deck's one deliberate exception to the no-[AnimationController]
/// rule. That rule exists so *explanatory* motion stays presenter-paced and
/// reversible — and it still does here: which lane the call sits in, what the
/// frame strip shows, and every label are all derived from `step`. The
/// controller drives only ambient motion that stands for "the UI thread is
/// running", which is exactly the thing that must not be under the
/// presenter's control, because the point is that it stops on its own.
///
/// Freezing via `stop()` rather than by resetting leaves the icon caught at
/// whatever angle it had reached, which reads as seized mid-turn rather than
/// parked on a convenient mark.
class _Spinner extends StatefulWidget {
  const _Spinner({required this.step});

  final int step;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1400),
  );

  bool get _frozen => widget.step == 2;

  @override
  void initState() {
    super.initState();
    if (!_frozen) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_frozen && _controller.isAnimating) {
      _controller.stop();
    } else if (!_frozen && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return SizedBox(
      width: 28,
      height: 28,
      child: RotationTransition(
        turns: _controller,
        child: Icon(
          Icons.autorenew,
          size: 28,
          color: _frozen ? Palette.red : pal.textPrimary,
        ),
      ),
    );
  }
}
