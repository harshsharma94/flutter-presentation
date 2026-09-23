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
///
/// ## Why the [DefaultTextStyle] wrapper exists
///
/// This one is a flutter_deck bug, worked around from outside.
/// `FlutterDeckCodeHighlight` renders each *inserted* or *deleted* run of
/// characters as a `WidgetSpan` wrapping its own `Text.rich`, and builds that
/// inner `Text` with no `style` argument. A `Text` with no style resolves
/// against the ambient [DefaultTextStyle], not against the enclosing span —
/// so changed characters inherited Material's 14px body default in the
/// default font family, while every unchanged character around them stayed at
/// [deckCodeStyle]'s 24px mono. The highlighter's own token styles carry
/// colour and weight but no size or family, so they merged over the wrong
/// base and the diff came out tiny, proportional, and correctly coloured.
///
/// That is what reads as "the text animates in small and then jumps": it is
/// not a transition from small to large at all — the inserted run is drawn at
/// the wrong size for the whole animation, then snaps to the right one when
/// the morph ends and the spans go static.
///
/// Merging [deckCodeStyle] into the ambient default gives that inner `Text`
/// the size and family it should have had. `merge`, not a replacement, so the
/// theme's own colour survives for any run the highlighter leaves unstyled.
/// It costs nothing anywhere else: the file-name label and the main code body
/// both pass their style explicitly, and an explicit style wins over the
/// ambient default.
///
/// This cannot be pinned by a widget test — see the note in
/// `test/widgets/code_panel_test.dart` for why.
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
    // See "Why the DefaultTextStyle wrapper exists" above. Without it, every
    // character the morph inserts or deletes is drawn at Material's 14px
    // body default in the default font family.
    child: DefaultTextStyle.merge(
      style: deckCodeStyle,
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
    ),
  );
}
