import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/slides/s03_auth/oauth_flow_slide.dart' show oauthHops, oauthLanes;
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/annotate.dart';
import 'package:gopay_flutter_deck/widgets/sequence_diagram.dart';
import 'package:gopay_flutter_deck/widgets/step_reveal.dart';

/// Slide 16's diagram footprint at full scale — same width it renders with
/// there, and the same 8-row height its 9 hops resolve to (one row shared by
/// the step-8/step-9 replay pair). Needed so [Transform.scale] shrinks it
/// rather than the layout reserving its full, unscaled box.
const _fullDiagramWidth = 820.0;
const _fullDiagramHeight = 322.0;
const _scale = 0.25;

const _headerLine = 'Authorization: Client-ID abc123';

/// Slide 18 — `/unsplash-reality` (2 steps, A13). Closes §3 Auth: the whole
/// OAuth2 machinery just taught, shrunk to a footnote, because Unsplash's
/// public API only ever checks one static header. Knowing the full flow and
/// knowing today doesn't need it are the same skill.
class UnsplashRealityBody extends StatelessWidget {
  const UnsplashRealityBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What Unsplash actually needs.',
                style: TextStyle(color: Palette.textPrimary, fontSize: 26),
              ),
              const SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 1,
                dimWhenPast: false,
                child: SizedBox(
                  width: _fullDiagramWidth * _scale,
                  height: _fullDiagramHeight * _scale,
                  child: OverflowBox(
                    maxWidth: _fullDiagramWidth,
                    maxHeight: _fullDiagramHeight,
                    child: Opacity(
                      opacity: Tokens.dimmed,
                      child: Transform.scale(
                        scale: _scale,
                        alignment: Alignment.topLeft,
                        child: const SequenceDiagram(
                          lanes: oauthLanes,
                          hops: oauthHops,
                          width: _fullDiagramWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 1,
                dimWhenPast: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tokens.gapMd,
                    vertical: Tokens.gapSm,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.surface,
                    border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
                    borderRadius: BorderRadius.circular(Tokens.radius),
                  ),
                  child: const Text(
                    _headerLine,
                    style: TextStyle(
                      color: Palette.blue,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Tokens.gapMd),
              const Callout(
                atStep: 2,
                text: '--dart-define. Never in git.',
                color: Palette.red,
              ),
            ],
          ),
        ),
      );
}
