import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _canvasWidth = 880.0;
const _canvasHeight = 200.0;

const _slabWidth = 250.0;
const _slabY = 40.0;
const _arrowY = 24.0;

double _slabLeft(int i) => i * (_slabWidth + Tokens.gapLg);

/// Slide 24 — `/dependency-rule` (4 steps, A20). Arrows point inward, toward
/// Domain. Step 3 flips one, and Domain stops being testable on its own.
class DependencyRuleBody extends StatelessWidget {
  const DependencyRuleBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final broken = step >= 3;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The one rule: dependencies point inward.',
                style: TextStyle(color: pal.textPrimary, fontSize: 29),
              ),
              SizedBox(height: Tokens.gapMd),
              SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _slabLeft(0),
                      top: _slabY,
                      child: LayerSlab(
                        name: 'Presentation',
                        width: _slabWidth,
                        bands: [uiBand],
                      ),
                    ),
                    Positioned(
                      left: _slabLeft(1),
                      top: _slabY,
                      child: LayerSlab(
                        name: 'Domain',
                        width: _slabWidth,
                        onFire: broken,
                        bands: [rulesBand],
                      ),
                    ),
                    Positioned(
                      left: _slabLeft(2),
                      top: _slabY,
                      child: LayerSlab(
                        name: 'Data',
                        width: _slabWidth,
                        bands: [networkBand],
                      ),
                    ),
                    // Presentation → Domain. Always inward.
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_slabLeft(0) + _slabWidth * 0.7, _arrowY),
                        to: Offset(_slabLeft(1) + _slabWidth * 0.3, _arrowY),
                        atStep: 2,
                        curved: true,
                        color: Palette.green,
                      ),
                    ),
                    // Data → Domain, until step 3 flips it the wrong way.
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(
                            _slabLeft(2) + _slabWidth * 0.3,
                            _arrowY,
                          ),
                          to: Offset(_slabLeft(1) + _slabWidth * 0.7, _arrowY),
                          atStep: 2,
                          curved: true,
                          color: Palette.green,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(
                            _slabLeft(1) + _slabWidth * 0.7,
                            _arrowY,
                          ),
                          to: Offset(_slabLeft(2) + _slabWidth * 0.3, _arrowY),
                          atStep: 3,
                          curved: true,
                          color: Palette.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _slabLeft(1) + _slabWidth * 0.5,
                      top: 150,
                      child: Callout(
                        atStep: 3,
                        text: "import 'package:dio/dio.dart'; — inside Domain",
                        color: Palette.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(atStep: 4, dimWhenPast: false, child: _TestPanel()),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestPanel extends StatelessWidget {
  const _TestPanel();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: 700,
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: pal.base,
        border: Border.all(color: Palette.red, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'test/domain/featured_test.dart',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              color: pal.textSecondary,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'SocketException: Failed host lookup: api.unsplash.com',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 18,
              color: Palette.red,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'To test one business rule you now need a network.',
            style: TextStyle(color: pal.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
