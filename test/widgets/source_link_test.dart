import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/slides/registry.dart';
import 'package:flutter_bootcamp_deck/widgets/source_link.dart';

import '../support/pump.dart';

void main() {
  group('SourceLink', () {
    test('points at the file on GitHub, not at the slide', () {
      const link = SourceLink(
        path: 'lib/reference/change_notifier_example.dart',
      );

      expect(
        link.url.toString(),
        'https://github.com/harshsharma94/flutter-presentation/blob/main/'
        'lib/reference/change_notifier_example.dart',
      );
    });

    testWidgets('names the file it opens', (tester) async {
      await pumpBody(
        tester,
        const Center(
          child: SourceLink(
            path: 'lib/reference/inherited_widget_example.dart',
          ),
        ),
      );

      expect(
        find.textContaining('inherited_widget_example.dart'),
        findsOneWidget,
      );
    });
  });

  // A link that 404s in front of a room is worse than no link. Every path a
  // slide advertises must exist, and must be a reference file rather than a
  // slide's own animation code.
  test('every slide source exists and is a reference file', () {
    final sources = [
      for (final spec in slideRegistry)
        if (spec.source != null) (spec.route, spec.source!),
    ];

    expect(sources, isNotEmpty);
    for (final (route, path) in sources) {
      expect(File(path).existsSync(), isTrue, reason: '$route -> $path');
      expect(path, startsWith('lib/reference/'), reason: route);
    }
  });
}
