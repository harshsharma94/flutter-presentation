import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Which bands have landed in the file by each step. They arrive interleaved
/// on purpose — that is what a real god file looks like, not four tidy
/// blocks.
final _arrivals = <int, List<Band>>{
  1: [uiBand, networkBand],
  2: [parseBand, uiBand2],
  3: [rulesBand, networkBand2, rulesBand2],
};

/// Slide 22 — `/god-file` (4 steps, A18). One widget file that grew four
/// concerns. The bands here are the same `Band` values slide 23 sorts, so
/// the next slide reads as *these* bands moving.
class GodFileBody extends StatelessWidget {
  const GodFileBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final bands = <Band>[
      for (var s = 1; s <= step && s <= 3; s++) ..._arrivals[s]!,
    ];

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'home_screen.dart',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: pal.textSecondary,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              AnimatedContainer(
                duration: Tokens.travel,
                curve: Tokens.curve,
                width: 560,
                padding: EdgeInsets.all(Tokens.gapSm),
                decoration: BoxDecoration(
                  color: pal.surface,
                  border: Border.all(
                    color: step >= 4 ? Palette.red : pal.textSecondary,
                    width: Tokens.strokeWidth,
                  ),
                  borderRadius: BorderRadius.circular(Tokens.radius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final band in bands) ...[
                      BandRow(band: band),
                      SizedBox(height: 6),
                    ],
                    if (bands.isEmpty) SizedBox(height: 40),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 4,
                dimWhenPast: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bug_report_outlined,
                      color: Palette.red,
                      size: 32,
                    ),
                    SizedBox(width: Tokens.gapSm),
                    Callout(
                      atStep: 4,
                      text: 'Where do you even look?',
                      color: Palette.red,
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
