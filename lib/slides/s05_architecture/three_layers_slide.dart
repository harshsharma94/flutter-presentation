import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Step at which each layer's bands have finished arriving. The bands are
/// the exact `Band` values slide 20 tangled together — sorting them is the
/// whole animation.
final _presentation = [uiBand, uiBand2];
final _domain = [rulesBand, rulesBand2];
final _data = [networkBand, networkBand2, parseBand];

/// Slide 21 — `/three-layers` (3 steps, A19). Everyone in the room has
/// already built this, under three different names; then the Flutter one.
///
/// An earlier version spent four taps filling the slabs band by band and
/// three more revealing the platform names one at a time — seven beats to
/// arrive somewhere the audience was already standing. The interesting
/// comparison is all three platforms at once against the one set of names
/// this deck will use, so that is what it is now.
class ThreeLayersBody extends StatelessWidget {
  const ThreeLayersBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 980,
                child: CorrelationPanel(
                  flutterLabel: 'Presentation\nDomain\nData',
                  firstStep: 1,
                  stepsPerRow: 0,
                  flutterStep: 2,
                  rows: [
                    CorrelationRow(
                      platform: 'Android',
                      concept: 'MVVM + UseCase',
                    ),
                    CorrelationRow(platform: 'iOS', concept: 'MVVM / VIPER'),
                    CorrelationRow(
                      platform: 'Java/Spring',
                      concept: 'Controller -> Service -> Repository',
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapLg),
              StepReveal(
                atStep: 2,
                dimWhenPast: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayerSlab(
                      name: 'Presentation',
                      subtitle: 'widgets, state',
                      width: 300,
                      bands: _presentation,
                    ),
                    SizedBox(width: Tokens.gapMd),
                    LayerSlab(
                      name: 'Domain',
                      subtitle: 'rules, no Flutter imports',
                      width: 320,
                      bands: _domain,
                    ),
                    SizedBox(width: Tokens.gapMd),
                    LayerSlab(
                      name: 'Data',
                      subtitle: 'Dio, JSON, cache',
                      width: 320,
                      bands: _data,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 3,
                dimWhenPast: false,
                child: Text(
                  'Same bands as the last slide. Same code. Three files that '
                  'can each be read — and tested — on their own.',
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
