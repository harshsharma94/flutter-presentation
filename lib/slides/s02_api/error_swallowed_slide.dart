import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _tryCatchCode = '''
try {
  final res = await dio.get(url);
  setState(() => _photos = res.data);
} catch (e) {}''';

/// 0-indexed — the empty `catch (e) {}` block, per
/// `FlutterDeckCodeHighlight.highlightedLines`.
const _catchLine = [3];

const _codeWidth = 520.0;
const _phoneWidth = 110.0;

/// How long the clock climbs from 5s to 30s. Deliberately not one of the
/// deck's shared `Tokens.fade`/`Tokens.travel` values — those describe a UI
/// element settling into place; this describes real wall-clock seconds
/// passing while a person stares at a spinner, which has to read as several
/// seconds, not an instant snap. Still a finite, step-derived
/// `TweenAnimationBuilder`, so it settles at "30s" and reverses correctly if
/// the presenter steps back — see [_ClockText]. The spinner itself is a
/// separate, deliberately non-finite case; see [_Spinner]'s own rationale.
const _waitDuration = Duration(seconds: 4);

/// Slide 11 — `/error-swallowed` (3 steps, A9). The section's emotional
/// beat: an empty `catch` block, then the spinner that never resolves, then
/// the person who gave up waiting on it.
class ErrorSwallowedBody extends StatelessWidget {
  const ErrorSwallowedBody({required this.step, super.key});

  final int step;

  bool get _waiting => step >= 2;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
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
                    child: CodePanel(
                      code: _tryCatchCode,
                      fileName: 'lib/screens/photo_list_screen.dart',
                      highlightedLines: _catchLine,
                    ),
                  ),
                ),
                SizedBox(width: Tokens.gapLg),
                StepReveal(
                  atStep: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhoneFrame(
                        width: _phoneWidth,
                        child: Center(child: _Spinner(waiting: _waiting)),
                      ),
                      SizedBox(height: Tokens.gapSm),
                      _ClockText(waiting: _waiting),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Tokens.gapLg),
            StepReveal(
              atStep: 3,
              dimWhenPast: false,
              child: Icon(Icons.touch_app, color: pal.textSecondary, size: 32),
            ),
            SizedBox(height: Tokens.gapSm),
            Callout(
              atStep: 3,
              text: "They didn't file a bug. They left.",
              color: Palette.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// The wait spinner — the deck's second deliberate exception to the
/// no-`AnimationController` rule, matching the precedent set on slide 9: a
/// genuinely repeating [AnimationController], not a finite illusion.
///
/// An earlier version of this widget used a [TweenAnimationBuilder] tweening
/// toward a large-but-finite rotation target, so it would visibly spin for a
/// few seconds and then quietly stop. That is wrong for exactly the reason
/// this slide exists: the whole argument is that the spinner *never*
/// resolves. If the presenter follows the speaker notes and holds this beat
/// for longer than the tween's duration — which is the point, not an edge
/// case — the audience would watch it go still while the coach keeps
/// talking about a request that supposedly never stopped, undercutting the
/// slide's own punchline.
///
/// So, as with slide 9's spinner: this is *ambient* motion standing for "the
/// request is still out there," which must not be presenter-controlled or
/// finite, because the point is that it does not stop on its own. Every
/// other detail on this slide — which elements are visible, the clock text,
/// the callout — stays a pure function of `step`; only this icon's rotation
/// runs on its own clock, and it starts turning once [waiting] flips true
/// and never stops. `test/support/pump.dart`'s bounded pumps (not
/// `pumpAndSettle`) are what make this compatible with the smoke test — see
/// that file's own rationale, established for slide 9.
class _Spinner extends StatefulWidget {
  const _Spinner({required this.waiting});

  final bool waiting;

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
    if (widget.waiting) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.waiting && !_controller.isAnimating) {
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

    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.autorenew, size: 28, color: pal.textSecondary),
    );
  }
}

/// "5s" ticking up to "30s" — the same finite-target technique as [_Spinner],
/// animating a number instead of an angle, off the same [_waitDuration] so
/// the two read as one continuous wait.
class _ClockText extends StatelessWidget {
  const _ClockText({required this.waiting});

  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 5.0, end: waiting ? 30.0 : 5.0),
      duration: _waitDuration,
      curve: Tokens.curve,
      builder: (context, seconds, child) => Text(
        '${seconds.round()}s',
        style: TextStyle(
          color: pal.textSecondary,
          fontFamily: 'JetBrainsMono',
          fontSize: 22,
        ),
      ),
    );
  }
}
