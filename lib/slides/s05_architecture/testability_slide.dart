import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Slide 24 — `/testability` (3 steps, A21). Data slides out, a fake slides
/// in, and **Domain does not move**. If the Domain slab shifts by a pixel
/// the animation is lying about what swapping an implementation costs, so
/// it is laid out in a fixed-width slot that never changes size.
class TestabilityBody extends StatelessWidget {
  const TestabilityBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final swapped = step >= 2;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayerSlab(
                    name: 'Domain',
                    subtitle: 'unchanged',
                    width: 300,
                    bands: [rulesBand],
                  ),
                  SizedBox(width: Tokens.gapLg),
                  // Fixed slot: both the real and the fake occupy exactly
                  // this box, so nothing to its left can shift.
                  SizedBox(
                    width: 360,
                    height: 150,
                    child: Stack(
                      children: [
                        AnimatedSlide(
                          duration: Tokens.travel,
                          curve: Tokens.curve,
                          offset: swapped ? Offset(0, -1.6) : Offset.zero,
                          child: LayerSlab(
                            name: 'PhotoRepository',
                            subtitle: 'real Dio',
                            width: 360,
                            bands: [networkBand],
                          ),
                        ),
                        AnimatedSlide(
                          duration: Tokens.travel,
                          curve: Tokens.curve,
                          offset: swapped ? Offset.zero : Offset(0, 1.6),
                          child: LayerSlab(
                            name: 'FakePhotoRepository',
                            subtitle: 'a list in memory',
                            width: 360,
                            bands: [
                              Band(
                                label: 'return const [Photo(...)];',
                                color: Palette.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Tokens.gapLg),
              StepReveal(
                atStep: 1,
                dimWhenPast: false,
                child: _Timer(
                  millis: swapped ? '3ms' : '2400ms',
                  fast: swapped,
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 3,
                dimWhenPast: false,
                child: Text(
                  'Domain never moved. That is the whole return on the rule.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Timer extends StatelessWidget {
  const _Timer({required this.millis, required this.fast});

  final String millis;
  final bool fast;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'one domain test: ',
          style: TextStyle(color: pal.textSecondary, fontSize: 24),
        ),
        AnimatedDefaultTextStyle(
          duration: Tokens.travel,
          curve: Tokens.curve,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 34,
            color: fast ? Palette.green : Palette.amber,
          ),
          child: Text(millis),
        ),
      ],
    );
  }
}
