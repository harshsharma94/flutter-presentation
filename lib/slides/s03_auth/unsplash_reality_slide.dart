import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _headerLine = 'Authorization: Client-ID abc123';

/// Slide 15 — `/unsplash-reality` (2 steps, A13). Closes §2 Auth: after the
/// whole login-and-refresh flow, Unsplash's public API only ever checks one
/// static header. Knowing the full flow and knowing today doesn't need it are
/// the same skill.
///
/// An earlier version put a quarter-scale copy of the previous slide's
/// sequence diagram above the header line, meaning to make the contrast
/// visible. At that size it was four unreadable grey boxes — it said
/// "something complicated was here" and nothing more, so it is gone. The
/// contrast is between two adjacent slides, which is enough.
class UnsplashRealityBody extends StatelessWidget {
  const UnsplashRealityBody({required this.step, super.key});

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
            Text(
              'What Unsplash actually needs.',
              style: TextStyle(color: pal.textPrimary, fontSize: 32),
            ),
            SizedBox(height: Tokens.gapMd),
            StepReveal(
              atStep: 1,
              dimWhenPast: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Tokens.gapMd,
                  vertical: Tokens.gapSm,
                ),
                decoration: BoxDecoration(
                  color: pal.surface,
                  border: Border.all(
                    color: Palette.blue,
                    width: Tokens.strokeWidth,
                  ),
                  borderRadius: BorderRadius.circular(Tokens.radius),
                ),
                child: Text(
                  _headerLine,
                  style: TextStyle(
                    color: Palette.blue,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            SizedBox(height: Tokens.gapMd),
            Callout(
              atStep: 2,
              text: 'It is a password. Keep it out of the repo.',
              color: Palette.red,
            ),
          ],
        ),
      ),
    );
  }
}
