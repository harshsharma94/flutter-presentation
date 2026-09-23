import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Deck-wide defaults for code. `animateCodeUpdate` is what makes the
/// character-morph work — changing [code] between steps cross-fades the diff.
///
/// ## Why [sizedFor] exists
///
/// A morphing panel changes size on every frame of the morph: lines are added
/// and removed, the longest line grows and shrinks. On its own that is fine.
/// Inside a `FittedBox(fit: scaleDown)` — which nearly every code slide in
/// this deck uses to survive a 720p projector — it is not: the FittedBox
/// recomputes its scale from the child's *current* size, so the type visibly
/// shrinks, wobbles and then snaps back out as the morph settles. It reads as
/// a rendering fault rather than as code changing.
///
/// [sizedFor] fixes it by reserving one box big enough for every variant the
/// panel will ever show. Each variant is laid out once, invisibly (an
/// `Opacity` of zero skips painting entirely, so this costs layout and
/// nothing else), and the [Stack] takes the size of the largest. The visible,
/// animating panel then morphs inside a box that never moves, so the
/// enclosing FittedBox picks one scale and keeps it.
///
/// Pass every string the panel can be given, including the current one:
///
/// ```dart
/// CodePanel(code: step >= 2 ? _after : _before, sizedFor: [_before, _after])
/// ```
class CodePanel extends StatelessWidget {
  const CodePanel({
    required this.code,
    this.language = 'dart',
    this.fileName,
    this.highlightedLines = const [],
    this.sizedFor = const [],
    super.key,
  });

  final String code;
  final String language;
  final String? fileName;
  final List<int> highlightedLines;

  /// Every variant [code] can take across this slide's steps. Empty for a
  /// panel whose code never changes — there is nothing to reserve.
  final List<String> sizedFor;

  Widget _highlight(String source, {required bool animate}) =>
      FlutterDeckCodeHighlight(
        code: source,
        language: language,
        fileName: fileName,
        highlightedLines: animate ? highlightedLines : const [],
        animateCodeUpdate: animate,
        codeUpdateDuration: Tokens.travel,
      );

  @override
  Widget build(BuildContext context) => FlutterDeckCodeHighlightTheme(
    data: FlutterDeckCodeHighlightTheme.of(context)
        .copyWith(textStyle: deckCodeStyle),
    child: sizedFor.isEmpty
        ? _highlight(code, animate: true)
        : Stack(
            alignment: Alignment.topLeft,
            children: [
              for (final variant in sizedFor)
                Opacity(
                  opacity: 0,
                  child: IgnorePointer(
                    child: _highlight(variant, animate: false),
                  ),
                ),
              _highlight(code, animate: true),
            ],
          ),
  );
}
