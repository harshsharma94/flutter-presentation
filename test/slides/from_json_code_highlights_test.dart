import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/from_json_code_slide.dart';

/// What the presenter narrates at each step, and the text that must actually
/// be lit while they say it.
const _expected = <int, List<String>>{
  1: ["id: json['id']"],
  2: ["imageUrl: json['urls']['regular']"],
  3: ["author: json['user']['name']", "likes: json['likes']"],
  4: ['factory Photo.fromJson'],
  5: [
    'required this.id',
    'required this.imageUrl',
    'required this.author',
    'required this.likes',
  ],
};

void main() {
  final lines = photoClassCode.split('\n');

  group('slide 17 highlights', () {
    // The bug this pins: a `'''` string looks like it begins with a newline
    // and does not — Dart drops the newline straight after the opening
    // delimiter. Counting a phantom blank line 0 shifted every index by one,
    // so the "factory" callout appeared while the `id:` line was lit.
    test('line 0 is the first line of code, not a blank', () {
      expect(lines.first, 'class Photo {');
    });

    test('every step lights exactly what the presenter is describing', () {
      for (final entry in _expected.entries) {
        final indices = photoClassHighlights[entry.key];
        expect(
          indices,
          isNotNull,
          reason: 'step ${entry.key} has no highlight',
        );
        expect(
          indices!.length,
          entry.value.length,
          reason: 'step ${entry.key} highlights the wrong number of lines',
        );
        for (var i = 0; i < indices.length; i++) {
          expect(
            lines[indices[i]],
            contains(entry.value[i]),
            reason:
                'step ${entry.key}: line ${indices[i]} is '
                '"${lines[indices[i]].trim()}", expected it to carry '
                '"${entry.value[i]}"',
          );
        }
      }
    });

    test('no step points past the end of the snippet', () {
      for (final indices in photoClassHighlights.values) {
        for (final i in indices) {
          expect(i, lessThan(lines.length));
        }
      }
    });
  });
}
