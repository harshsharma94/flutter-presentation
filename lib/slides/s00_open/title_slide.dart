import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';

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
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GoPay · Flutter Bootcamp',
                style: TextStyle(
                  color: Palette.blue,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: Tokens.gapSm),
              const Text(
                'Day 2 — Making It Real',
                style: TextStyle(
                  color: Palette.textPrimary,
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: Tokens.gapXl),
              const Text(
                'Coach: Harsh Sharma · Assistant coaches: Harsh, Abhas',
                style: TextStyle(color: Palette.textSecondary, fontSize: 18),
              ),
            ],
          ),
        ),
      );
}
