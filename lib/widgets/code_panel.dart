import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Deck-wide defaults for code. `animateCodeUpdate` is what makes A16's
/// character-morph work — changing [code] between steps cross-fades the diff.
class CodePanel extends StatelessWidget {
  const CodePanel({
    required this.code,
    this.language = 'dart',
    this.fileName,
    this.highlightedLines = const [],
    super.key,
  });

  final String code;
  final String language;
  final String? fileName;
  final List<int> highlightedLines;

  @override
  Widget build(BuildContext context) => FlutterDeckCodeHighlightTheme(
    data: FlutterDeckCodeHighlightTheme.of(context)
        .copyWith(textStyle: deckCodeStyle),
    child: FlutterDeckCodeHighlight(
      code: code,
      language: language,
      fileName: fileName,
      highlightedLines: highlightedLines,
      animateCodeUpdate: true,
      codeUpdateDuration: Tokens.travel,
    ),
  );
}
