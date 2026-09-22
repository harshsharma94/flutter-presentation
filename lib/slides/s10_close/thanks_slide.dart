import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 51 — `/thanks` (1 step). Chrome off; the deck ends where it began.
class ThanksBody extends StatelessWidget {
  const ThanksBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thank you',
              style: TextStyle(
                color: Palette.textPrimary,
                fontSize: 88,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Tokens.gapSm),
            Text(
              'Questions — and then go break something.',
              style: TextStyle(color: Palette.textSecondary, fontSize: 26),
            ),
          ],
        ),
      );
}
