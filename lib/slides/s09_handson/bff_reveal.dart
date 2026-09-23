import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/payment_methods_screen.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _screenWidth = 360.0;
const _canvasWidth = 1120.0;
const _canvasHeight = 470.0;
const _jsonLeft = 470.0;

/// The shared choreography behind slides 38-40: one row of the screen, the
/// contract fragment that produced it, and the Dart property that fragment
/// drives. Only the row, the JSON and the binding change between the three
/// slides — the beats do not, which is the point: the client code is the
/// same in all three cases.
class BffRevealBody extends StatelessWidget {
  const BffRevealBody({
    required this.step,
    required this.regionId,
    required this.anchorY,
    required this.json,
    required this.binding,
    required this.accent,
    required this.caption,
    super.key,
  });

  final int step;
  final String regionId;

  /// Vertical anchor, in canvas coordinates, of the row this slide is about.
  /// Tuned against [PaymentMethodsScreen]'s own layout — if the screen's row
  /// heights change, these move with it.
  final double anchorY;

  final String json;

  /// The Dart the JSON drives, revealed last. This is the beat that answers
  /// "so what?".
  final String binding;

  final Color accent;
  final String caption;

  @override
  Widget build(BuildContext context) => Center(
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
                  highlightedRegions: step >= 1 ? {regionId} : const {},
                ),
              ),
              Positioned.fill(
                child: AnimatedArrow(
                  from: const Offset(_screenWidth + 8, 0) + Offset(0, anchorY),
                  to: Offset(_jsonLeft - 8, anchorY),
                  atStep: 2,
                  color: accent,
                ),
              ),
              Positioned(
                left: _jsonLeft,
                top: 0,
                width: _canvasWidth - _jsonLeft,
                child: StepReveal(
                  atStep: 3,
                  dimWhenPast: false,
                  slideFrom: const Offset(0.06, 0),
                  child: CodePanel(
                    code: json,
                    language: 'json',
                    fileName: 'GET /payment-methods',
                  ),
                ),
              ),
              Positioned(
                left: _jsonLeft,
                top: _canvasHeight - 150,
                width: _canvasWidth - _jsonLeft,
                child: StepReveal(
                  atStep: 4,
                  dimWhenPast: false,
                  child: CodePanel(code: binding),
                ),
              ),
              Positioned(
                left: 0,
                top: _canvasHeight - 44,
                width: _screenWidth + 60,
                child: Callout(atStep: 4, text: caption, color: accent),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// A palette alias so the three slides read as variations of one idea rather
/// than three unrelated colour choices.
const bffNormal = Palette.green;
const bffInfo = Palette.amber;
const bffError = Palette.red;
