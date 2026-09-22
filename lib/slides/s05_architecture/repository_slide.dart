import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _canvasWidth = 860.0;
const _canvasHeight = 290.0;

const _callerX = 0.0;
const _doorX = 300.0;
const _sourceX = 600.0;
const _laneY = 90.0;
const _boxW = 210.0;
const _boxH = 96.0;

/// Slide 26 — `/repository` (3 steps, A22). One door, two sources. The
/// caller knocks the same way whichever one answers — that is the entire
/// pattern, and the reason slide 25's swap was free.
class RepositoryBody extends StatelessWidget {
  const RepositoryBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final offline = step >= 3;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _callerX,
                      top: _laneY,
                      child: _Box(
                        label: 'HomeScreen',
                        sub: 'repo.getPhotos()',
                        color: Palette.blue,
                      ),
                    ),
                    Positioned(
                      left: _doorX,
                      top: _laneY,
                      child: _Box(
                        label: 'PhotoRepository',
                        sub: 'one method, one return type',
                        color: pal.textPrimary,
                      ),
                    ),
                    Positioned(
                      left: _sourceX,
                      top: _laneY - 70,
                      child: _Box(
                        label: 'Unsplash API',
                        sub: offline ? 'unreachable' : 'Dio',
                        color: offline ? Palette.red : Palette.green,
                        faded: offline,
                      ),
                    ),
                    Positioned(
                      left: _sourceX,
                      top: _laneY + 70,
                      child: _Box(
                        label: 'Local cache',
                        sub: 'last good response',
                        color: offline ? Palette.green : pal.textSecondary,
                        faded: !offline,
                      ),
                    ),
                    // The knock. Identical on both steps — deliberately the
                    // same arrow, never redrawn in another colour.
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(_boxW, _laneY + _boxH / 2),
                        to: Offset(_doorX, _laneY + _boxH / 2),
                        atStep: 1,
                        color: Palette.blue,
                      ),
                    ),
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(_doorX + _boxW, _laneY + _boxH / 2),
                          to: Offset(_sourceX, _laneY - 70 + _boxH / 2),
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
                          from: Offset(_doorX + _boxW, _laneY + _boxH / 2),
                          to: Offset(_sourceX, _laneY + 70 + _boxH / 2),
                          atStep: 3,
                          curved: true,
                          color: Palette.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Callout(
                atStep: 3,
                text: 'The network dropped. HomeScreen never found out.',
                color: Palette.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.label,
    required this.sub,
    required this.color,
    this.faded = false,
  });

  final String label;
  final String sub;
  final Color color;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return AnimatedOpacity(
      duration: Tokens.travel,
      curve: Tokens.curve,
      opacity: faded ? Tokens.dimmed : 1.0,
      child: AnimatedContainer(
        duration: Tokens.travel,
        curve: Tokens.curve,
        width: _boxW,
        height: _boxH,
        padding: EdgeInsets.symmetric(horizontal: Tokens.gapSm),
        decoration: BoxDecoration(
          color: pal.surface,
          border: Border.all(color: color, width: Tokens.strokeWidth),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: pal.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
