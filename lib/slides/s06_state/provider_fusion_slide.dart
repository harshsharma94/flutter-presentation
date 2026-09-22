import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _boxW = 260.0;
const _boxH = 112.0;

/// Slide 34 — `/provider-fusion` (3 steps, A27). The two halves they now
/// understand slide together: an InheritedWidget that can't change, and a
/// ChangeNotifier that can't be reached. Provider is the pair, packaged.
class ProviderFusionBody extends StatelessWidget {
  const ProviderFusionBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final fused = step >= 2;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 760,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedAlign(
                      duration: Tokens.travel,
                      curve: Tokens.curve,
                      alignment:
                          fused ? Alignment.center : Alignment.centerLeft,
                      child: AnimatedOpacity(
                        duration: Tokens.travel,
                        opacity: fused ? 0.0 : 1.0,
                        child: const _Box(
                          title: 'InheritedWidget',
                          sub: 'reaches every descendant\nbut cannot change',
                          color: Palette.blue,
                        ),
                      ),
                    ),
                    AnimatedAlign(
                      duration: Tokens.travel,
                      curve: Tokens.curve,
                      alignment:
                          fused ? Alignment.center : Alignment.centerRight,
                      child: AnimatedOpacity(
                        duration: Tokens.travel,
                        opacity: fused ? 0.0 : 1.0,
                        child: const _Box(
                          title: 'ChangeNotifier',
                          sub: 'can change\nbut nobody can find it',
                          color: Palette.green,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: Tokens.travel,
                      curve: Tokens.curve,
                      opacity: fused ? 1.0 : 0.0,
                      child: _Box(
                        title: 'ChangeNotifierProvider',
                        sub: 'both, with the boilerplate gone',
                        color: pal.textPrimary,
                        width: 360,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapLg),
              StepReveal(
                atStep: 1,
                dimWhenPast: false,
                child: _LineCounter(lines: step >= 3 ? 6 : 38),
              ),
              SizedBox(height: Tokens.gapMd),
              Callout(
                atStep: 3,
                text: 'Same behaviour. You just stop writing the plumbing.',
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
    required this.title,
    required this.sub,
    required this.color,
    this.width = _boxW,
  });

  final String title;
  final String sub;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: _boxH),
      alignment: Alignment.center,
      padding: EdgeInsets.all(Tokens.gapXs),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: color, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                color: color, fontSize: 21, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: pal.textSecondary, fontSize: 16, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _LineCounter extends StatelessWidget {
  const _LineCounter({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: lines.toDouble(), end: lines.toDouble()),
      duration: Tokens.travel,
      curve: Tokens.curve,
      builder: (context, value, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'lines of wiring: ',
            style: TextStyle(color: pal.textSecondary, fontSize: 24),
          ),
          AnimatedDefaultTextStyle(
            duration: Tokens.travel,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 34,
              color: lines <= 10 ? Palette.green : Palette.amber,
            ),
            child: Text('$lines'),
          ),
        ],
      ),
    );
  }
}
