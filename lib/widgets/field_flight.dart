import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

/// One JSON key travelling a curved path and landing as a named argument.
///
/// Returns a [Stack], so place it as a `Positioned.fill` child of the slide's
/// own canvas stack — that way [from]/[to] share the canvas coordinate space
/// with everything else on the slide.
class FieldFlight extends StatelessWidget {
  const FieldFlight({
    required this.jsonKey,
    required this.jsonValue,
    required this.dartParam,
    required this.atStep,
    required this.from,
    required this.to,
    this.color = Palette.blue,
    super.key,
  });

  /// The key as it reads in the raw JSON, used only for the arrow's identity
  /// in debugging — the visible source line is rendered by the slide.
  final String jsonKey;

  /// The Dart accessor expression this key becomes, e.g. `json['urls']['regular']`.
  final String jsonValue;

  /// The named parameter it lands on, e.g. `imageUrl`.
  final String dartParam;

  final int atStep;
  final Offset from;
  final Offset to;
  final Color color;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedArrow(
              from: from,
              to: to,
              atStep: atStep,
              curved: true,
              color: color,
            ),
          ),
          Positioned(
            left: to.dx,
            top: to.dy - _chipHeight / 2,
            child: StepReveal(
              atStep: atStep,
              slideFrom: const Offset(-0.12, 0),
              dimWhenPast: false,
              child: SizedBox(
                height: _chipHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 20,
                        height: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: '$dartParam: ',
                          style: TextStyle(color: color),
                        ),
                        TextSpan(
                          text: '$jsonValue,',
                          style: const TextStyle(color: Palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

const _chipHeight = 24.0;

/// A raw JSON source line that stays bright until the step that consumes it,
/// then drops to [Tokens.dimmed] — "this key has been spent".
class JsonSourceLine extends StatelessWidget {
  const JsonSourceLine({
    required this.text,
    this.consumedAt,
    this.indent = 0,
    super.key,
  });

  final String text;
  final int? consumedAt;
  final int indent;

  @override
  Widget build(BuildContext context) {
    final step = StepScope.of(context);
    final spent = consumedAt != null && step >= consumedAt!;

    return AnimatedOpacity(
      duration: Tokens.fade,
      curve: Tokens.curve,
      opacity: spent ? Tokens.dimmed : 1.0,
      child: Padding(
        padding: EdgeInsets.only(left: indent * 16.0),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 20,
            height: 1.0,
            color: Palette.textPrimary,
          ),
        ),
      ),
    );
  }
}
