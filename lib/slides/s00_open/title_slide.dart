import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 1 — `/title`, the deck's opening slide (1 step, `chrome: false`).
///
/// Visually stands in for `FlutterDeckSlide.title`'s layout, but is built
/// from plain widgets rather than calling that template directly:
/// `SlideSpec.body` must render with no flutter_deck ancestors (see that
/// class's doc), while `FlutterDeckSlide.title` reads `context.flutterDeck`,
/// which only exists inside a running `FlutterDeckApp`. Replicating the
/// look here keeps this slide testable the same way as every other slide.
class TitleBody extends StatelessWidget {
  const TitleBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter Bootcamp',
              style: TextStyle(
                color: Palette.blue,
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: Tokens.gapSm),
            Text(
              'Day 2 — Making It Real',
              style: TextStyle(
                color: pal.textPrimary,
                fontSize: 58,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            SizedBox(height: Tokens.gapXl),
            Text(
              'Coach: Harsh Sharma · Assistant coaches: Harsh, Abhas',
              style: TextStyle(color: pal.textSecondary, fontSize: 22),
            ),
            SizedBox(height: Tokens.gapLg),
            // The room's first instruction, and it has to be true: an
            // earlier version said `.` opened a theme picker. It does not —
            // `.` is bound to toggleNavigationDrawer in flutter_deck's
            // default shortcuts, and the theme lives behind the
            // more_vert ("⋮") button on the floating controls bar. Anyone
            // who tried it found that out before the deck had said
            // anything else, which is an expensive way to start.
            _Hints(),
          ],
        ),
      ),
    );
  }
}

/// The two controls worth knowing before slide 2, each stated as the thing
/// you actually press. Everything else on the controls bar — marker,
/// fullscreen, presenter view — can wait until somebody asks.
class _Hints extends StatelessWidget {
  const _Hints();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      _Hint(
        trigger: 'Press  .',
        text: 'opens the index — every slide, jump anywhere.',
      ),
      SizedBox(height: Tokens.gapSm),
      _Hint(
        trigger: '⋮  bottom bar',
        text: 'dark or light — we find your lack of contrast disturbing.',
      ),
    ],
  );
}

class _Hint extends StatelessWidget {
  const _Hint({required this.trigger, required this.text});

  /// The literal thing to press, drawn as a key cap.
  final String trigger;
  final String text;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: Tokens.gapSm, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Palette.green, width: Tokens.strokeWidth),
            borderRadius: BorderRadius.circular(Tokens.radius),
          ),
          child: Text(
            trigger,
            style: TextStyle(
              color: Palette.green,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: Tokens.gapSm),
        // Flexible: the title slide has no FittedBox and its padding is
        // gapXl, so at 1280 the longer hint runs off the right edge.
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: pal.textSecondary, fontSize: 21),
          ),
        ),
      ],
    );
  }
}
