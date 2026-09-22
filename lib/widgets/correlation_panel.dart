import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

class CorrelationRow {
  CorrelationRow({required this.platform, required this.concept});
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
    this.stepsPerRow = 1,
    super.key,
  });

  final List<CorrelationRow> rows;
  final String flutterLabel;
  final int firstStep;

  /// How many steps separate one row's reveal from the next. The default of
  /// 1 is the usual "one row per step, arrow lands with the last row"
  /// choreography (slide 6). Pass 0 to reveal every row — and the arrow and
  /// [flutterLabel] box — together on a single step, for a slide that only
  /// has one step left in its budget to spend on the correlation (slide 9's
  /// closing beat).
  final int stepsPerRow;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
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
                  atStep: firstStep + i * stepsPerRow,
                  dimWhenPast: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Tokens.gapXs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rows[i].platform,
                          style: TextStyle(
                            color: pal.textSecondary,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          rows[i].concept,
                          style: TextStyle(
                            color: Palette.green,
                            fontSize: 29,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: Tokens.gapLg),
        StepReveal(
          atStep: firstStep + (rows.length - 1) * stepsPerRow,
          dimWhenPast: false,
          child: Icon(Icons.arrow_forward, color: pal.textSecondary, size: 32),
        ),
        SizedBox(width: Tokens.gapLg),
        Expanded(
          child: StepReveal(
            atStep: firstStep + (rows.length - 1) * stepsPerRow,
            dimWhenPast: false,
            child: Container(
              padding: EdgeInsets.all(Tokens.gapMd),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Palette.blue, width: Tokens.strokeWidth),
                borderRadius: BorderRadius.circular(Tokens.radius),
              ),
              child: Text(
                flutterLabel,
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.blue, fontSize: 36),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
