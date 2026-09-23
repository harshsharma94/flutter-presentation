import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _slabWidth = 250.0;

/// Width of the gap between two slabs — the box each arrow is painted into,
/// so an arrow starts on one slab's edge and ends on the next one's.
const _gapWidth = 110.0;
const _arrowLaneHeight = 22.0;

/// Slide 22 — `/dependency-rule` (4 steps, A20). Arrows point inward, toward
/// Domain. Step 3 flips one, and Domain stops being testable on its own.
///
/// The arrows live in [_ArrowGap] boxes *between* the slabs, vertically
/// centred on them, rather than in a free-floating lane above the row. An
/// earlier version drew them in a strip over the top of the slabs, where they
/// touched nothing and read as decoration rather than as dependencies.
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
              SizedBox(height: Tokens.gapLg),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LayerSlab(
                    name: 'Presentation',
                    width: _slabWidth,
                    bands: [uiBand],
                  ),
                  // Presentation -> Domain. Always inward.
                  _ArrowGap(
                    children: [
                      AnimatedArrow(
                        from: Offset(0, _arrowLaneHeight / 2),
                        to: Offset(_gapWidth, _arrowLaneHeight / 2),
                        atStep: 2,
                        color: Palette.green,
                      ),
                    ],
                  ),
                  LayerSlab(
                    name: 'Domain',
                    width: _slabWidth,
                    onFire: broken,
                    bands: [rulesBand],
                  ),
                  _ArrowGap(
                    children: [
                      // Data -> Domain, until step 3 flips it the wrong way.
                      StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(_gapWidth, _arrowLaneHeight / 2),
                          to: Offset(0, _arrowLaneHeight / 2),
                          atStep: 2,
                          color: Palette.green,
                        ),
                      ),
                      StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(0, _arrowLaneHeight / 2),
                          to: Offset(_gapWidth, _arrowLaneHeight / 2),
                          atStep: 3,
                          color: Palette.red,
                        ),
                      ),
                    ],
                  ),
                  LayerSlab(
                    name: 'Data',
                    width: _slabWidth,
                    bands: [networkBand],
                  ),
                ],
              ),
              SizedBox(height: Tokens.gapMd),
              Callout(
                atStep: 3,
                text: "import 'package:dio/dio.dart'; — inside Domain",
                color: Palette.red,
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

/// A fixed box in the gap between two slabs, holding the arrow (or arrows)
/// that cross it. Sized rather than stretched so the arrow endpoints are
/// exactly the two slab edges, whatever the slabs' intrinsic height is.
class _ArrowGap extends StatelessWidget {
  const _ArrowGap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _gapWidth,
    height: _arrowLaneHeight,
    child: Stack(
      clipBehavior: Clip.none,
      children: [for (final child in children) Positioned.fill(child: child)],
    ),
  );
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
              fontSize: 18,
              color: pal.textSecondary,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'SocketException: Failed host lookup: api.unsplash.com',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              color: Palette.red,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'To test one business rule you now need a network.',
            style: TextStyle(color: pal.textSecondary, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
