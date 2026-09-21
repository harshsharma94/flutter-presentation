import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/step_reveal.dart';

class CorrelationRow {
  const CorrelationRow({required this.platform, required this.concept});
  final String platform;
  final String concept;
}

/// "You already know X — in Flutter it is Y."
///
/// Green is always the familiar side, blue always the Flutter side, deck-wide.
/// Per spec §8 this renders as the final steps of a concept slide, not a slide
/// of its own — the analogy lands while the diagram is still on screen.
class CorrelationPanel extends StatelessWidget {
  const CorrelationPanel({
    required this.rows,
    required this.flutterLabel,
    this.firstStep = 1,
    super.key,
  });

  final List<CorrelationRow> rows;
  final String flutterLabel;
  final int firstStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows.length; i++)
                StepReveal(
                  atStep: firstStep + i,
                  dimWhenPast: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Tokens.gapXs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rows[i].platform,
                          style: const TextStyle(
                            color: Palette.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          rows[i].concept,
                          style: const TextStyle(
                            color: Palette.green,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: Tokens.gapLg),
        StepReveal(
          atStep: firstStep + rows.length - 1,
          dimWhenPast: false,
          child: const Icon(Icons.arrow_forward,
              color: Palette.textSecondary, size: 32),
        ),
        const SizedBox(width: Tokens.gapLg),
        Expanded(
          child: StepReveal(
            atStep: firstStep + rows.length - 1,
            dimWhenPast: false,
            child: Container(
              padding: const EdgeInsets.all(Tokens.gapMd),
              decoration: BoxDecoration(
                border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
                borderRadius: BorderRadius.circular(Tokens.radius),
              ),
              child: Text(
                flutterLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.blue, fontSize: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
