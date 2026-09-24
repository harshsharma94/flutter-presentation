import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:flutter_bootcamp_deck/slides/s10_close/references_slide.dart';

import '../support/pump.dart';

/// Records what would have been opened, instead of opening it.
class _FakeLauncher extends UrlLauncherPlatform {
  final launched = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

/// Widget tests render every font as a stand-in whose glyphs are wider than
/// the real ones, which would make a truncation check meaningless. Load the
/// deck's actual fonts so widths are measured as the projector will draw them.
Future<void> _loadDeckFonts() async {
  final mono = FontLoader('JetBrainsMono')
    ..addFont(rootBundle.load('assets/fonts/JetBrainsMono-Regular.ttf'));
  final outfit = FontLoader('Outfit')
    ..addFont(rootBundle.load('assets/fonts/Outfit-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Outfit-SemiBold.ttf'));
  await Future.wait([mono.load(), outfit.load()]);
}

void main() {
  setUpAll(_loadDeckFonts);

  late UrlLauncherPlatform original;
  late _FakeLauncher launcher;

  setUp(() {
    original = UrlLauncherPlatform.instance;
    launcher = _FakeLauncher();
    UrlLauncherPlatform.instance = launcher;
  });
  tearDown(() => UrlLauncherPlatform.instance = original);

  // The bug: every entry was plain text with nothing behind it.
  testWidgets('tapping a reference opens its URL', (tester) async {
    await pumpBody(tester, const ReferencesBody(step: 6), step: 6);

    await tester.tap(find.text('dart.dev/codelabs/async-await'));
    await tester.pump();

    expect(launcher.launched, ['https://dart.dev/codelabs/async-await']);
  });

  testWidgets('a label that is a title still opens the right place', (
    tester,
  ) async {
    await pumpBody(tester, const ReferencesBody(step: 6), step: 6);

    await tester.tap(find.text('Flutter Widget of the Week — InheritedWidget'));
    await tester.pump();

    expect(launcher.launched, ['https://www.youtube.com/watch?v=1t-8rBCGBYw']);
  });

  // A clickable link whose text is cut off with "…" hides what it opens. Each
  // row used to be a Row of two Flexibles, which Flutter gives half the free
  // width each — so a label was capped at half the column however short its
  // note was, and most URLs were cut.
  testWidgets('no label or note is cut off', (tester) async {
    await pumpBody(tester, const ReferencesBody(step: 6), step: 6);

    final cut = <String>[
      for (final group in referenceGroups)
        for (final link in group.links)
          for (final text in [link.label, link.note])
            if (tester
                .renderObject<RenderParagraph>(
                  find
                      .descendant(
                        of: find.text(text),
                        matching: find.byType(RichText),
                      )
                      .first,
                )
                .didExceedMaxLines)
              text,
    ];

    expect(cut, isEmpty);
  });

  test('every reference has an absolute https URL', () {
    final links = [for (final group in referenceGroups) ...group.links];

    expect(links, isNotEmpty);
    for (final link in links) {
      final uri = Uri.parse(link.url);
      expect(uri.scheme, 'https', reason: link.label);
      expect(uri.host, isNotEmpty, reason: link.label);
    }
  });
}
