import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/oauth_flow_slide.dart'
    show oauthHops, oauthLanes;
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/sequence_diagram.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// The OAuth slide's diagram footprint at full scale — same width it renders
/// with there, and the same 7-row height its 8 hops resolve to (one row
/// shared by the 401/replay pair). Needed so the shrunk copy reserves only
/// the space it actually paints.
const _fullDiagramWidth = 820.0;
const _fullDiagramHeight = 286.0;
const _scale = 0.25;

const _headerLine = 'Authorization: Client-ID abc123';

/// Slide 15 — `/unsplash-reality` (2 steps, A13). Closes §2 Auth: the whole
/// OAuth2 machinery just taught, shrunk to a footnote, because Unsplash's
/// public API only ever checks one static header. Knowing the full flow and
/// knowing today doesn't need it are the same skill.
class UnsplashRealityBody extends StatelessWidget {
  const UnsplashRealityBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What Unsplash actually needs.',
              style: TextStyle(color: pal.textPrimary, fontSize: 32),
            ),
            SizedBox(height: Tokens.gapMd),
            StepReveal(
              atStep: 1,
              dimWhenPast: false,
              // ClipRect, and a top-left-aligned [OverflowBox], because the
              // default centre alignment hands the full-size diagram a box a
              // quarter its size and then centres it — which pushed the
              // scaled copy up and left, out of its own footprint and across
              // the slide.
              child: ClipRect(
                child: SizedBox(
                  width: _fullDiagramWidth * _scale,
                  height: _fullDiagramHeight * _scale,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    maxWidth: _fullDiagramWidth,
                    maxHeight: _fullDiagramHeight,
                    child: Opacity(
                      opacity: Tokens.dimmed,
                      child: Transform.scale(
                        scale: _scale,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: _fullDiagramWidth,
                          height: _fullDiagramHeight,
                          child: SequenceDiagram(
                            lanes: oauthLanes,
                            hops: oauthHops,
                            width: _fullDiagramWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Tokens.gapMd),
            StepReveal(
              atStep: 1,
              dimWhenPast: false,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Tokens.gapMd,
                  vertical: Tokens.gapSm,
                ),
                decoration: BoxDecoration(
                  color: pal.surface,
                  border: Border.all(
                    color: Palette.blue,
                    width: Tokens.strokeWidth,
                  ),
                  borderRadius: BorderRadius.circular(Tokens.radius),
                ),
                child: Text(
                  _headerLine,
                  style: TextStyle(
                    color: Palette.blue,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            SizedBox(height: Tokens.gapMd),
            Callout(
              atStep: 2,
              text: 'It is a password. Keep it out of the repo.',
              color: Palette.red,
            ),
          ],
        ),
      ),
    );
  }
}
