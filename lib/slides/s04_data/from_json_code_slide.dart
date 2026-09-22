import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';

const _code = '''
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

/// Which lines each step walks. Steps 1-3 march down the mapping itself,
/// step 4 jumps back up to the `factory` keyword, step 5 lights the named
/// parameters that make the call site readable.
const _highlights = <int, List<int>>{
  1: [10],
  2: [11],
  3: [12, 13],
  4: [9],
  5: [3, 4, 5, 6],
};

/// Slide 20 — `/from-json-code` (5 steps). The anatomy of the mapping they
/// just watched fly across slide 19, one highlighted line at a time.
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
                  width: 760,
                  child: CodePanel(
                    code: _code,
                    fileName: 'lib/models/photo.dart',
                    highlightedLines: _highlights[step] ?? const [],
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
                  text: 'Four Strings positionally is a bug waiting to happen — slide 42.',
                  color: Palette.amber,
                ),
              ],
            ),
          ),
        ),
      );
}
