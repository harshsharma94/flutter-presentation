import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/layer_slab.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Step at which each layer's bands have finished arriving. The bands are
/// the exact `Band` values slide 24 tangled together — sorting them is the
/// whole animation.
final _presentation = [uiBand, uiBand2];
final _domain = [rulesBand, rulesBand2];
final _data = [networkBand, networkBand2, parseBand];

/// Slide 25 — `/three-layers` (8 steps, A19). The same bands, sorted. Steps
/// 6-8 name what each layer is already called on the platforms they know.
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
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepReveal(
                    atStep: 1,
                    dimWhenPast: false,
                    slideFrom: Offset(0, -0.15),
                    child: LayerSlab(
                      name: 'Presentation',
                      subtitle: 'widgets, state',
                      width: 300,
                      bands: step >= 2 ? _presentation : const [],
                    ),
                  ),
                  SizedBox(width: Tokens.gapMd),
                  StepReveal(
                    atStep: 1,
                    dimWhenPast: false,
                    child: LayerSlab(
                      name: 'Domain',
                      subtitle: 'rules, no Flutter imports',
                      width: 320,
                      bands: step >= 3 ? _domain : const [],
                    ),
                  ),
                  SizedBox(width: Tokens.gapMd),
                  StepReveal(
                    atStep: 1,
                    dimWhenPast: false,
                    slideFrom: Offset(0, 0.15),
                    child: LayerSlab(
                      name: 'Data',
                      subtitle: 'Dio, JSON, cache',
                      width: 320,
                      bands: step >= 4 ? _data : const [],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 5,
                dimWhenPast: false,
                child: Text(
                  'Same code. Same bands. Three files that can each be '
                  'read — and tested — on their own.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 22),
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              SizedBox(
                width: 900,
                child: CorrelationPanel(
                  flutterLabel: 'Presentation / Domain / Data',
                  firstStep: 6,
                  rows: [
                    CorrelationRow(
                        platform: 'Android', concept: 'MVVM + UseCase'),
                    CorrelationRow(platform: 'iOS', concept: 'MVVM / VIPER'),
                    CorrelationRow(
                      platform: 'Java/Spring',
                      concept: 'Controller → Service → Repository',
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
