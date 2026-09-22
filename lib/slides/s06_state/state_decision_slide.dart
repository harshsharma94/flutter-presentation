import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

final _rows = [
  (
    tool: 'setState',
    when: 'local and ephemeral',
    example: 'a toggle, a text field, one animation',
    color: null,
  ),
  (
    tool: 'InheritedWidget',
    when: 'read-only config, down the tree',
    example: 'theme, locale, the signed-in user',
    color: Palette.blue,
  ),
  (
    tool: 'ChangeNotifier + Provider',
    when: 'shared and mutable',
    example: 'the photo list both screens read',
    color: Palette.green,
  ),
];

/// Slide 34 — `/state-decision` (4 steps, A29). The whole of §5, as a table
/// they can hold in their head.
class StateDecisionBody extends StatelessWidget {
  const StateDecisionBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _rows.length; i++)
                StepReveal(
                  atStep: i + 1,
                  dimWhenPast: false,
                  slideFrom: Offset(-0.05, 0),
                  child: _Row(
                    tool: _rows[i].tool,
                    when: _rows[i].when,
                    example: _rows[i].example,
                    color: _rows[i].color ?? pal.textSecondary,
                  ),
                ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 4,
                dimWhenPast: false,
                child: Text(
                  'Bloc / Riverpod exist for when this starts to hurt. '
                  'Not before.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.tool,
    required this.when,
    required this.example,
    required this.color,
  });

  final String tool;
  final String when;
  final String example;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: Tokens.gapMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 340,
            child: Text(
              tool,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: color,
                fontSize: 27,
              ),
            ),
          ),
          SizedBox(
            width: 360,
            child: Text(
              when,
              style: TextStyle(color: pal.textPrimary, fontSize: 26),
            ),
          ),
          SizedBox(
            width: 340,
            child: Text(
              example,
              style: TextStyle(color: pal.textSecondary, fontSize: 21),
            ),
          ),
        ],
      ),
    );
  }
}
