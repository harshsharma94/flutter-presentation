import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 19 — `/codegen-deps` (2 steps). The three packages, on their own
/// slide, before any generated code appears.
///
/// This used to be a step on the codegen slide, sharing the screen with a
/// 26-line snippet that morphed underneath it. Two things were wrong with
/// that: the transition was doing two jobs at once, and the room cannot type
/// the snippet until `pub get` has finished anyway. So the install gets its
/// own beat — the same shape slide 6 uses for Dio, which is the moment this
/// room has already learned to expect.
class CodegenDepsBody extends StatelessWidget {
  const CodegenDepsBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Three packages, then the generator.',
                style: TextStyle(color: pal.textPrimary, fontSize: 34),
              ),
              SizedBox(height: Tokens.gapLg),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Card(
                    color: Palette.green,
                    title: 'ships with your app',
                    command: r'$ flutter pub add json_annotation',
                    yaml: 'dependencies:\n  json_annotation: ^4.9.0',
                    note:
                        'The annotations themselves. Your code imports '
                        'these, so they go in the app.',
                  ),
                  SizedBox(width: Tokens.gapLg),
                  _Card(
                    color: Palette.amber,
                    title: 'runs on your machine only',
                    command:
                        r'$ flutter pub add dev:json_serializable'
                        '\n'
                        r'      dev:build_runner',
                    yaml:
                        'dev_dependencies:\n'
                        '  json_serializable: ^6.9.0\n'
                        '  build_runner: ^2.4.13',
                    note:
                        'The generator and the thing that runs it. '
                        'Note the dev: prefix — they never reach the phone.',
                  ),
                ],
              ),
              SizedBox(height: Tokens.gapLg),
              AnimatedOpacity(
                duration: Tokens.fade,
                opacity: step >= 2 ? 1.0 : 0.0,
                child: SizedBox(
                  width: 1100,
                  child: Text(
                    'Wait for pub get to finish before the next slide — the '
                    'annotations will not resolve until it has, and the whole '
                    'file is on that slide for them to type.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 21,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One dependency group. The split is the lesson: which of these ends up in
/// the shipped binary is the thing people get wrong, and `dev:` is the whole
/// difference.
class _Card extends StatelessWidget {
  const _Card({
    required this.color,
    required this.title,
    required this.command,
    required this.yaml,
    required this.note,
  });

  final Color color;
  final String title;
  final String command;
  final String yaml;
  final String note;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return SizedBox(
      width: 620,
      child: Container(
        padding: EdgeInsets.all(Tokens.gapMd),
        decoration: BoxDecoration(
          color: pal.surface,
          border: Border.all(color: color, width: Tokens.strokeWidth),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Tokens.gapSm),
            Text(
              command,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: Palette.green,
                fontSize: 20,
                height: 1.4,
              ),
            ),
            SizedBox(height: Tokens.gapSm),
            Text(
              yaml,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: pal.textSecondary,
                fontSize: 19,
                height: 1.4,
              ),
            ),
            SizedBox(height: Tokens.gapSm),
            Text(
              note,
              style: TextStyle(
                color: pal.textSecondary,
                fontSize: 19,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
