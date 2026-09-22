import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _tasks = [
  'Wire your list and detail screens to the real API.',
  'Handle loading and error states — both screens.',
  'Move the Dio call behind a repository, provide it with MultiProvider.',
];

/// Slide 49 — `/assignment` (3 steps). Tonight's homework, one line per step.
class AssignmentBody extends StatelessWidget {
  const AssignmentBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tonight',
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Tokens.gapLg),
                for (var i = 0; i < _tasks.length; i++)
                  StepReveal(
                    atStep: i + 1,
                    dimWhenPast: false,
                    slideFrom: const Offset(-0.04, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Tokens.gapMd),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}.',
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: Palette.blue,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(width: Tokens.gapSm),
                          SizedBox(
                            width: 780,
                            child: Text(
                              _tasks[i],
                              style: const TextStyle(
                                color: Palette.textPrimary,
                                fontSize: 26,
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
