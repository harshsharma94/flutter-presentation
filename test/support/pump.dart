import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/widgets/frame_strip.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

const fhd = Size(1920, 1080);
const hd = Size(1280, 720);

/// Pumps a slide body in isolation at a fixed step. No flutter_deck ancestors
/// are required, which is the whole point of the body/wrapper split.
///
/// The tree is wrapped in [FlutterDeckTheme] (not just [MaterialApp]) because
/// several flutter_deck widgets — header, footer, code highlight, split slide
/// — call `FlutterDeckTheme.of(context)`, which asserts a non-null theme is
/// present in context.
Future<void> pumpBody(
  WidgetTester tester,
  Widget body, {
  int step = 1,
  Size size = fhd,
  Brightness brightness = Brightness.dark,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final deckTheme =
      brightness == Brightness.dark ? deckDarkTheme : deckLightTheme;
  await tester.pumpWidget(
    MaterialApp(
      theme: deckTheme.materialTheme,
      home: FlutterDeckTheme(
        data: deckTheme,
        child: Scaffold(
          body: StepScope(step: step, child: body),
        ),
      ),
    ),
  );
  // Deliberately NOT pumpAndSettle(). Some slides carry intentionally
  // continuous motion — a loading spinner that must visibly keep turning so
  // that a *frozen* spinner reads as frozen (slide 9) — and pumpAndSettle
  // waits for a steady state that such a slide never reaches, hanging the
  // gate rather than failing it. Bounded pumps advance well past
  // Tokens.travel + Tokens.fade, which is all these assertions need: they
  // check that a slide renders without throwing or overflowing, not that it
  // eventually stops moving.
  // 3s total comfortably clears the longest animation in the deck: the
  // five-node ancestor-chain traversal on slide 32, which runs
  // Tokens.travel * 5 = 2000ms.
  await tester.pump();
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

/// Finds a [FrameStrip]'s [CustomPaint] by its `ValueKey('frame-strip-painter')`
/// and casts its painter to [FrameStripPainter], the same
/// find-by-key-then-cast technique `annotate_test.dart` uses for
/// [ArrowPainter] — robust against `find.byType(CustomPaint).first`
/// resolving to a framework ink-effect [CustomPaint] instead of ours.
FrameStripPainter stripPainterOf(WidgetTester tester) => tester
    .widget<CustomPaint>(find.byKey(const ValueKey('frame-strip-painter')))
    .painter! as FrameStripPainter;
