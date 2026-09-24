import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';

/// Public so `from_json_code_highlights_test.dart` can pin the line indices
/// below against the source they are supposed to point at.
const photoClassCode = '''
class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    required this.author,
    required this.likes,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as String,
        imageUrl: json['urls']['regular'] as String,
        author: json['user']['name'] as String,
        likes: json['likes'] as int,
      );
}''';

/// Which lines each step walks, 0-indexed into [_code]. Steps 1-3 march down
/// the mapping itself, step 4 jumps back up to the `factory` keyword, step 5
/// lights the named parameters that make the call site readable.
///
/// Every entry here used to be one too high, so the `factory` callout came up
/// while the `id:` line was lit. The trap is that a `'''` string looks like it
/// starts with a newline and does not: Dart drops the newline immediately
/// after the opening delimiter, so line 0 is `class Photo {`, not a blank.
/// `from_json_code_highlights_test.dart` pins this.
const photoClassHighlights = <int, List<int>>{
  1: [9],
  2: [10],
  3: [11, 12],
  4: [8],
  5: [2, 3, 4, 5],
};

/// Slide 17 — `/from-json-code` (5 steps). The anatomy of the mapping they
/// just watched fly across slide 16, one highlighted line at a time.
class FromJsonCodeBody extends StatelessWidget {
  const FromJsonCodeBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Tokens.gapLg),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 1080,
              child: CodePanel(
                code: photoClassCode,
                fileName: 'lib/models/photo.dart',
                highlightedLines: photoClassHighlights[step] ?? const [],
              ),
            ),
            const SizedBox(height: Tokens.gapMd),
            const Callout(
              atStep: 4,
              text: "factory = a constructor that doesn't have to return a new instance.",
              color: Palette.blue,
            ),
            const SizedBox(height: Tokens.gapXs),
            const Callout(
              atStep: 5,
              text:
                  'Four Strings positionally is a bug waiting to happen. '
                  'Named parameters, from day 1.',
              color: Palette.amber,
            ),
          ],
        ),
      ),
    ),
  );
}
