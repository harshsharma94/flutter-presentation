import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// A static "LIVE" indicator: a solid red dot next to red, letter-spaced
/// text. Deliberately not animated — a pulsing element on the near-empty
/// [LiveSlideBody] would pull the audience's eye back to the screen exactly
/// when it should be on the presenter's IDE.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Palette.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Tokens.gapSm),
          Text(
            'LIVE',
            style: TextStyle(
              color: Palette.red,
              fontSize: 24,
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
  const LiveSlideBody({
    required this.goal,
    this.constraint,
    this.hints = const [],
    this.hintsAtStep = 2,
    super.key,
  });

  final String goal;

  /// A single rule that bounds the exercise, shown under the goal. Keep it to
  /// one line — it is a fence, not an instruction.
  final String? constraint;

  /// Revealed on [hintsAtStep], so the room gets a genuine attempt first.
  final List<String> hints;
  final int hintsAtStep;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LiveBadge(),
          SizedBox(height: Tokens.gapLg),
          Text(
            goal,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: 54,
              height: 1.25,
            ),
          ),
          if (constraint != null) ...[
            SizedBox(height: Tokens.gapMd),
            Text(
              constraint!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Palette.amber, fontSize: 26),
            ),
          ],
          if (hints.isNotEmpty) ...[
            SizedBox(height: Tokens.gapLg),
            StepReveal(
              atStep: hintsAtStep,
              dimWhenPast: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: Tokens.gapXs),
                    child: Text(
                      'Hint',
                      style: TextStyle(
                        color: Palette.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  for (final hint in hints)
                    Padding(
                      padding: EdgeInsets.only(bottom: Tokens.gapXs),
                      child: Text(
                        hint,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          color: pal.textSecondary,
                          fontSize: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
