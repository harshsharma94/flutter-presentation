import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/payment_methods_screen.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _screenWidth = 360.0;
const _canvasWidth = 1180.0;
const _canvasHeight = 560.0;
const _panelLeft = 470.0;
const _panelWidth = _canvasWidth - _panelLeft;

/// The row this slide is about, and where its right edge sits inside
/// [PaymentMethodsScreen] — tuned against that screen's own layout, so if its
/// row heights change these move with it.
const _regionId = 'row-wallet';
const _anchorY = 118.0;

/// Two ways a server can answer for the *same* row.
const _describedJson = '''
{
  "title": "Wallet",
  "descriptions": [
    { "type": "DEFAULT", "value": "Balance: 500.000" }
  ],
  "cta": { "type": "radio_button" }
}''';

const _rawJson = '''
{ "id": "wallet", "type": "wallet", "balance": 500000 }''';

/// Slide 38 — `/row-contract` (4 steps, A36). One row of a real screen, and
/// the two shapes the response behind it can take.
///
/// This replaces three near-identical slides that walked the ordinary row,
/// the warning row and the disabled row in turn. They shared every beat by
/// design — "the client code is the same in all three cases" — which meant
/// taps two and three taught nothing taps one had not, and the section spent
/// twelve taps making one point. One row is enough to show the mapping; the
/// comparison is what is actually worth the screen time, so the fourth slide
/// (the two contracts side by side) folds in here instead of following.
///
/// The names for the two shapes are deliberately descriptive rather than the
/// industry term for the left-hand one: that term, and the argument about
/// when to choose it, belong to day 3. What a Day 2 audience needs is only
/// that the response shape is a *choice*, and that it decides who has to ship
/// to change a word on screen.
class RowContractBody extends StatelessWidget {
  const RowContractBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.gapMd),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: _canvasWidth,
            height: _canvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: PaymentMethodsScreen(
                    width: _screenWidth,
                    highlightedRegions: step >= 1
                        ? const {_regionId}
                        : const {},
                  ),
                ),
                Positioned.fill(
                  child: AnimatedArrow(
                    from: const Offset(_screenWidth + 8, _anchorY),
                    to: const Offset(_panelLeft - 8, _anchorY),
                    atStep: 2,
                    color: pal.textSecondary,
                  ),
                ),
                Positioned(
                  left: _panelLeft,
                  top: 0,
                  width: _panelWidth,
                  child: StepReveal(
                    atStep: 3,
                    dimWhenPast: false,
                    slideFrom: const Offset(0.06, 0),
                    child: _Shape(
                      label: 'The response describes the row',
                      color: Palette.green,
                      json: _describedJson,
                      consequence:
                          'Every word on that row came from the server. New '
                          'copy, a new tone, a fourth payment method — the '
                          'response changes and the app does not.',
                      showConsequence: step >= 4,
                    ),
                  ),
                ),
                Positioned(
                  left: _panelLeft,
                  top: 290,
                  width: _panelWidth,
                  child: StepReveal(
                    atStep: 4,
                    dimWhenPast: false,
                    slideFrom: const Offset(0.06, 0),
                    child: _Shape(
                      label: 'The response sends the raw fields',
                      color: Palette.amber,
                      json: _rawJson,
                      consequence:
                          'The client owns the words, the formatting and the '
                          'control. Same new copy — and now somebody ships a '
                          'release for it.',
                      showConsequence: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One response shape: its name, the JSON, and what it costs to change
/// something. The consequence line is what makes the pair an argument rather
/// than two snippets.
class _Shape extends StatelessWidget {
  const _Shape({
    required this.label,
    required this.color,
    required this.json,
    required this.consequence,
    required this.showConsequence,
  });

  final String label;
  final Color color;
  final String json;
  final String consequence;
  final bool showConsequence;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: Tokens.gapXs),
      CodePanel(code: json, language: 'json', fileName: 'GET /payment-methods'),
      if (showConsequence) ...[
        const SizedBox(height: Tokens.gapXs),
        Text(
          consequence,
          style: TextStyle(color: color, fontSize: 20, height: 1.35),
        ),
      ],
    ],
  );
}
