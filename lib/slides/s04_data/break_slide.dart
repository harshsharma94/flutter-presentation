import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 23 — `/break` (1 step). Nothing else on it on purpose.
class BreakBody extends StatelessWidget {
  const BreakBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Break.',
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: 100,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Tokens.gapSm),
          Text(
            'Back in 15.',
            style: TextStyle(color: pal.textSecondary, fontSize: 34),
          ),
        ],
      ),
    );
  }
}
