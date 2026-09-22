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
            SizedBox(height: Tokens.gapMd),
            // Doubles as the room's first instruction: the navigation
            // drawer (`.`) is where the theme toggle lives, and they will
            // need the drawer again to jump sections.
            Text(
              'Dark side or light side? Press  .  and choose — '
              'we find your lack of contrast disturbing.',
              style: TextStyle(
                color: Palette.green,
                fontSize: 21,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
