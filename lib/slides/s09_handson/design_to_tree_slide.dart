import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/payment_methods_screen.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Which region the step outlines, and the widget name that flies into the
/// tree when it does. Read top to bottom, this is the skill the slide is
/// teaching: a design is a hierarchy, and you can see it before you type it.
const _beats = [
  (region: 'header', name: 'Scaffold > AppBar', indent: 0),
  (region: 'section-title', name: 'Column', indent: 1),
  (region: 'section-title', name: 'SectionHeader', indent: 2),
  (region: 'row-wallet', name: 'ListView.builder', indent: 2),
  (region: 'row-wallet', name: 'PaymentRow', indent: 3),
  (
    region: 'row-instalments',
    name: 'Row[Icon, Column[Title, Subtitle], Trailing]',
    indent: 4
  ),
  (region: 'cta', name: 'FilledButton', indent: 1),
];

/// Slide 44 — `/design-to-tree` (7 steps, A35). A design on the left, a
/// widget tree assembling itself on the right, one tap at a time.
class DesignToTreeBody extends StatelessWidget {
  const DesignToTreeBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final lit = <String>{
      if (step >= 1 && step <= _beats.length) _beats[step - 1].region,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.gapMd),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaymentMethodsScreen(highlightedRegions: lit),
              const SizedBox(width: Tokens.gapLg),
              SizedBox(
                width: 700,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Read it as a hierarchy before you type it.',
                      style:
                          TextStyle(color: Palette.textPrimary, fontSize: 22),
                    ),
                    const SizedBox(height: Tokens.gapMd),
                    for (var i = 0; i < _beats.length; i++)
                      StepReveal(
                        atStep: i + 1,
                        dimWhenPast: false,
                        slideFrom: const Offset(0.12, 0),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: _beats[i].indent * 22.0,
                            bottom: Tokens.gapXs,
                          ),
                          child: _TreeLine(name: _beats[i].name),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TreeLine extends StatelessWidget {
  const _TreeLine({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '└ ',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: Palette.textSecondary,
              fontSize: 15,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Tokens.gapXs,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Palette.blue, width: 1),
                borderRadius: BorderRadius.circular(Tokens.gapXs),
              ),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: Palette.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
}
