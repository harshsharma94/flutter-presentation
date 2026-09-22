import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 24 — `/break` (1 step). Nothing else on it on purpose.
class BreakBody extends StatelessWidget {
  const BreakBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Break.',
              style: TextStyle(
                color: Palette.textPrimary,
                fontSize: 96,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Tokens.gapSm),
            Text(
              'Back in 15.',
              style: TextStyle(color: Palette.textSecondary, fontSize: 28),
            ),
          ],
        ),
      );
}
