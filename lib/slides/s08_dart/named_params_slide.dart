import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _positional = '''
Photo('a1x9', 'https://images.unsplash.com/photo-1', 'Ansel', true);''';

const _named = '''
Photo(
  id: 'a1x9',
  imageUrl: 'https://images.unsplash.com/photo-1',
  author: 'Ansel',
  isFavourite: true,
);''';

/// Slide 41 — `/named-params` (3 steps, A33). The same `CodePanel` receives
/// named-argument code on step 3, so `animateCodeUpdate` morphs the
/// arguments into place rather than cutting to a new block.
class NamedParamsBody extends StatelessWidget {
  const NamedParamsBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 820,
                  child: CodePanel(code: step >= 3 ? _named : _positional),
                ),
                const SizedBox(height: Tokens.gapLg),
                const StepReveal(
                  atStep: 2,
                  until: 2,
                  dimWhenPast: false,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Question(),
                      SizedBox(width: Tokens.gapLg),
                      _Question(),
                      SizedBox(width: Tokens.gapLg),
                      _Question(),
                      SizedBox(width: Tokens.gapLg),
                      _Question(),
                    ],
                  ),
                ),
                const StepReveal(
                  atStep: 2,
                  until: 2,
                  dimWhenPast: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: Tokens.gapSm),
                    child: Text(
                      'Which is which? And what happens when someone swaps '
                      'two of them?',
                      style: TextStyle(color: Palette.amber, fontSize: 24),
                    ),
                  ),
                ),
                const Callout(
                  atStep: 3,
                  text: 'The compiler cannot catch a swapped String. A reader '
                      'can — if you name it.',
                  color: Palette.green,
                ),
              ],
            ),
          ),
        ),
      );
}

class _Question extends StatelessWidget {
  const _Question();

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Palette.amber, width: 1),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: const Text(
          '?',
          style: TextStyle(color: Palette.amber, fontSize: 24),
        ),
      );
}
