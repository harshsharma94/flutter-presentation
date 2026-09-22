import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Slide 28 — `/testability` (3 steps, A21). Data slides out, a fake slides
/// in, and **Domain does not move**. If the Domain slab shifts by a pixel
/// the animation is lying about what swapping an implementation costs, so
/// it is laid out in a fixed-width slot that never changes size.
class TestabilityBody extends StatelessWidget {
  const TestabilityBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final swapped = step >= 2;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LayerSlab(
                    name: 'Domain',
                    subtitle: 'unchanged',
                    width: 300,
                    bands: [rulesBand],
                  ),
                  const SizedBox(width: Tokens.gapLg),
                  // Fixed slot: both the real and the fake occupy exactly
                  // this box, so nothing to its left can shift.
                  SizedBox(
                    width: 320,
                    height: 108,
                    child: Stack(
                      children: [
                        AnimatedSlide(
                          duration: Tokens.travel,
                          curve: Tokens.curve,
                          offset: swapped ? const Offset(0, -1.6) : Offset.zero,
                          child: const LayerSlab(
                            name: 'PhotoRepository',
                            subtitle: 'real Dio',
                            width: 320,
                            bands: [networkBand],
                          ),
                        ),
                        AnimatedSlide(
                          duration: Tokens.travel,
                          curve: Tokens.curve,
                          offset: swapped ? Offset.zero : const Offset(0, 1.6),
                          child: const LayerSlab(
                            name: 'FakePhotoRepository',
                            subtitle: 'a list in memory',
                            width: 320,
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
              const SizedBox(height: Tokens.gapLg),
              StepReveal(
                atStep: 1,
                dimWhenPast: false,
                child: _Timer(millis: swapped ? '3ms' : '2400ms', fast: swapped),
              ),
              const SizedBox(height: Tokens.gapMd),
              const StepReveal(
                atStep: 3,
                dimWhenPast: false,
                child: Text(
                  'Domain never moved. That is the whole return on the rule.',
                  style: TextStyle(color: Palette.textSecondary, fontSize: 18),
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
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'one domain test: ',
            style: TextStyle(color: Palette.textSecondary, fontSize: 20),
          ),
          AnimatedDefaultTextStyle(
            duration: Tokens.travel,
            curve: Tokens.curve,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 28,
              color: fast ? Palette.green : Palette.amber,
            ),
            child: Text(millis),
          ),
        ],
      );
}
