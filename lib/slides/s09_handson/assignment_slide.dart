import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _tasks = [
  'Wire your list and detail screens to the real API.',
  'Handle loading and error states — both screens.',
  'Move the Dio call behind a repository, provide it with MultiProvider.',
];

/// Slide 44 — `/assignment` (3 steps). Tonight's homework, one line per step.
class AssignmentBody extends StatelessWidget {
  const AssignmentBody({required this.step, super.key});

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
              Text(
                'Tonight',
                style: TextStyle(
                  color: pal.textPrimary,
                  fontSize: 49,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Tokens.gapLg),
              for (var i = 0; i < _tasks.length; i++)
                StepReveal(
                  atStep: i + 1,
                  dimWhenPast: false,
                  slideFrom: Offset(-0.04, 0),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: Tokens.gapMd),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}.',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            color: Palette.blue,
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(width: Tokens.gapSm),
                        SizedBox(
                          width: 780,
                          child: Text(
                            _tasks[i],
                            style: TextStyle(
                              color: pal.textPrimary,
                              fontSize: 32,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
