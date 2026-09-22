import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/frame_strip.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the two lanes, the phone and the two floating work blocks
/// are laid out against — the same fixed-canvas-plus-`Positioned` convention
/// every other diagram slide in this deck uses, so every coordinate below
/// agrees with what actually renders.
const _canvasWidth = 980.0;
const _canvasHeight = 230.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _lanesLeft = 0.0;
const _lanesWidth = 800.0;

const _mainLaneTop = 36.0;
const _laneHeight = 36.0;
const _mainLaneBottom = _mainLaneTop + _laneHeight;

const _secondLaneTop = 132.0;

const _phoneWidth = 100.0;
const _phoneLeft = _canvasWidth - _phoneWidth;

const _frameCount = 60;

double _tickX(num tick) => _lanesLeft + tick / _frameCount * _lanesWidth;

const _blockWidth = 250.0;
const _blockHeight = 40.0;

/// The waiting request sits on the second lane, early in the strip; the
/// synchronous decode sits on the main lane, later, over the ticks
/// [FrameStrip] paints red while [AsyncAwaitBody._blocked] holds.
const _waitTick = 18;
const _stalledFrom = 34;
const _stalledTo = 48;
const _stalledCentreTick = (_stalledFrom + _stalledTo) / 2;

final _waitBlockLeft = _tickX(_waitTick) - _blockWidth / 2;
final _waitBlockCentreX = _tickX(_waitTick);
final _cpuBlockLeft = _tickX(_stalledCentreTick) - _blockWidth / 2;

/// Slide 9 — `/async-await` (5 steps, A6) ⭐ PROTECTED. One of four slides in
/// the deck where the animation *is* the explanation rather than an
/// illustration of one — see the file-level rationale on [_Spinner] for the
/// single detail that makes or breaks it.
///
/// The slide exists to correct the mental model most of the room arrives
/// with, which is that `await` moves work off the UI thread. It does not.
/// Dart runs one isolate on one thread with one event loop, and `await` is
/// not a thread-switch — it is a way of registering what happens next.
///
/// So the two cases are drawn as two different things, on purpose:
///
/// - **Waiting** (step 2) never occupied the thread in the first place. The
///   socket is the OS's problem; the isolate is free the entire time. This is
///   why a network call cannot block the UI in Flutter with *or* without
///   `await`, and the strip keeps flowing green to prove it.
/// - **Computing** (step 4) genuinely does occupy the thread, and `await`
///   changes nothing about that. Only moving it to another isolate does.
///
/// Step 3 is then what `await` actually buys: the continuation, written in a
/// straight line, with `try`/`catch` that works — the same machinery as
/// `.then()`, spelled better.
class AsyncAwaitBody extends StatelessWidget {
  const AsyncAwaitBody({required this.step, super.key});

  final int step;

  /// Only the synchronous-decode step stalls the thread. Waiting never does.
  bool get _blocked => step == 4;

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
                        'One thread. One event loop. Your whole app.',
                        style: TextStyle(color: pal.textPrimary, fontSize: 26),
                      ),
                      Text(
                        'A frame every 16ms. Hold that thread up and nothing '
                        'moves — not even the spinner.',
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
                        stalled: _blocked,
                        height: _laneHeight,
                      ),
                    ),
                    Positioned(
                      left: _lanesLeft,
                      top: _mainLaneTop - 22,
                      child: Text(
                        'UI isolate — the one thread that draws',
                        style: TextStyle(
                          color: pal.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _lanesLeft,
                      top: _secondLaneTop,
                      width: _lanesWidth,
                      height: _laneHeight,
                      child: DashedBox(
                        atStep: 2,
                        color: Palette.blue,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: Tokens.gapSm),
                            child: Text(
                              'the socket — the OS, not your thread',
                              style: TextStyle(
                                color: Palette.blue.withValues(
                                  alpha: Tokens.dimmed,
                                ),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // `await`: the continuation coming back up to the one
                    // thread that can touch the UI. Not a hand-off *to*
                    // another thread — there isn't one.
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_waitBlockCentreX, _secondLaneTop),
                        to: Offset(_waitBlockCentreX, _mainLaneBottom),
                        atStep: 3,
                        color: Palette.green,
                      ),
                    ),
                    Positioned(
                      left: _waitBlockCentreX + Tokens.gapSm,
                      top: (_mainLaneBottom + _secondLaneTop) / 2 - 14,
                      child: StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: Text(
                          'await',
                          style: TextStyle(
                            color: Palette.green,
                            fontFamily: 'JetBrainsMono',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _waitBlockLeft,
                      top: _secondLaneTop - _blockHeight - Tokens.gapXs,
                      child: StepReveal(
                        atStep: 2,
                        dimWhenPast: false,
                        child: _WorkBlock(
                          label: 'dio.get(url)',
                          color: Palette.blue,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _cpuBlockLeft,
                      top: _mainLaneTop + (_laneHeight - _blockHeight) / 2,
                      child: StepReveal(
                        atStep: 4,
                        dimWhenPast: false,
                        child: _WorkBlock(
                          label: 'jsonDecode(20 MB)',
                          color: Palette.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _phoneLeft,
                      top: 0,
                      child: PhoneFrame(
                        width: _phoneWidth,
                        child: Center(child: _Spinner(frozen: _blocked)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              _StepNote(step: step),
              SizedBox(height: Tokens.gapMd),
              // [CorrelationPanel] uses `Expanded` internally, so it needs a
              // bounded width — which the enclosing [FittedBox] does not give.
              SizedBox(
                width: _canvasWidth,
                child: CorrelationPanel(
                  flutterLabel: 'await',
                  firstStep: 5,
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
              SizedBox(height: Tokens.gapSm),
              SizedBox(
                width: _canvasWidth,
                child: StepReveal(
                  atStep: 5,
                  dimWhenPast: false,
                  child: Text(
                    'Close, but not the same: Kotlin can hand a suspend '
                    'function to Dispatchers.IO, and a goroutine can land on '
                    'another core. Dart has neither. await never moves work '
                    '— Isolate.run does.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Palette.amber,
                      fontSize: 19,
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

/// The one-line commentary under the diagram. Three mutually exclusive notes
/// sharing a fixed-height box, so the panel below never shifts as the
/// presenter steps: [StepReveal] with `until` set to the same step hides each
/// again as the next arrives.
class _StepNote extends StatelessWidget {
  const _StepNote({required this.step});

  final int step;

  static const _height = 58.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _canvasWidth,
    height: _height,
    child: Stack(
      children: [
        _note(
          atStep: 2,
          color: Palette.blue,
          text:
              'Waiting is free. Dart has no blocking HTTP call — while '
              'the socket works, nothing of yours is running, so the '
              'frames keep coming. With await or without it.',
        ),
        _note(
          atStep: 3,
          color: Palette.green,
          text:
              'So what is await for? Getting told. It is .then() with '
              'the callback unwrapped — the next line runs when the '
              'answer lands, and try/catch finally works.',
        ),
        _note(
          atStep: 4,
          color: Palette.red,
          text:
              'This one really does block: it is your code, on your '
              'thread, never yielding. await cannot help — there is no '
              'other thread to await on. Isolate.run(...) is the fix.',
        ),
      ],
    ),
  );

  Widget _note({
    required int atStep,
    required Color color,
    required String text,
  }) => Positioned.fill(
    child: StepReveal(
      atStep: atStep,
      until: atStep,
      dimWhenPast: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 20, height: 1.35),
        ),
      ),
    ),
  );
}

/// One unit of work, on whichever lane it belongs to. The label is wider than
/// a comfortable block at full size, and a clipped one reads as a bug rather
/// than a design — so the block keeps the fixed width the slide's geometry is
/// derived from, and the text shrinks to fit inside it.
class _WorkBlock extends StatelessWidget {
  const _WorkBlock({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: _blockWidth,
      height: _blockHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: color, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Tokens.gapSm),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
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
/// It **genuinely spins**, continuously, whenever the UI is alive, and
/// **genuinely stops dead** on the one step where synchronous work occupies
/// the thread. The contrast is the entire lesson: a spinner that was never
/// moving cannot be seen to freeze, and an audience watching a static icon
/// next to the words "UI blocked" learns nothing. That it keeps turning
/// through the *network* step is just as much of the lesson — that is the
/// half the room does not expect.
///
/// This is the deck's one deliberate exception to the no-[AnimationController]
/// rule. That rule exists so *explanatory* motion stays presenter-paced and
/// reversible — and it still does here: which lane the work sits in, what the
/// frame strip shows, and every label are all derived from `step`. The
/// controller drives only ambient motion that stands for "the UI thread is
/// running", which is exactly the thing that must not be under the
/// presenter's control, because the point is that it stops on its own.
///
/// Freezing via `stop()` rather than by resetting leaves the icon caught at
/// whatever angle it had reached, which reads as seized mid-turn rather than
/// parked on a convenient mark.
class _Spinner extends StatefulWidget {
  const _Spinner({required this.frozen});

  final bool frozen;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.frozen) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.frozen && _controller.isAnimating) {
      _controller.stop();
    } else if (!widget.frozen && !_controller.isAnimating) {
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
          color: widget.frozen ? Palette.red : pal.textPrimary,
        ),
      ),
    );
  }
}
