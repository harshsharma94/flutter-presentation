import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gopay_flutter_deck/theme/deck_theme.dart';
import 'package:gopay_flutter_deck/widgets/frame_strip.dart';
import 'package:gopay_flutter_deck/widgets/step_scope.dart';

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

  final deckTheme = brightness == Brightness.dark ? deckDarkTheme : deckLightTheme;
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
  await tester.pumpAndSettle();
}

/// Finds a [FrameStrip]'s [CustomPaint] by its `ValueKey('frame-strip-painter')`
/// and casts its painter to [FrameStripPainter], the same
/// find-by-key-then-cast technique `annotate_test.dart` uses for
/// [ArrowPainter] — robust against `find.byType(CustomPaint).first`
/// resolving to a framework ink-effect [CustomPaint] instead of ours.
FrameStripPainter stripPainterOf(WidgetTester tester) => tester
    .widget<CustomPaint>(find.byKey(const ValueKey('frame-strip-painter')))
    .painter! as FrameStripPainter;
