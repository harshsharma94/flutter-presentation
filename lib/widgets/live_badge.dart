import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Palette.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Tokens.gapSm),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Palette.red,
              fontSize: 20,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

/// The body of a live-coding handoff slide. Deliberately almost empty — the
/// audience looks at the IDE, not the screen. The script is in speaker notes.
class LiveSlideBody extends StatelessWidget {
  const LiveSlideBody({required this.goal, super.key});

  final String goal;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LiveBadge(),
            const SizedBox(height: Tokens.gapLg),
            Text(
              goal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Palette.textPrimary,
                fontSize: 48,
                height: 1.25,
              ),
            ),
          ],
        ),
      );
}
