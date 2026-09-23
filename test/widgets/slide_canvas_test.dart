import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/widgets/slide_canvas.dart';

const _fhd = Size(1920, 1080);

/// Renders [content] inside a [SlideCanvas] filling a projector-sized screen
/// and returns the *global* rect of the content — global, so the canvas's
/// scale transform is included. `getSize` would report the pre-transform size
/// and measure nothing.
Future<Rect> _rendered(WidgetTester tester, Size content) async {
  tester.view
    ..physicalSize = _fhd
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: SlideCanvas(
        child: SizedBox.fromSize(
          size: content,
          child: const Placeholder(key: ValueKey('content')),
        ),
      ),
    ),
  );
  return tester.getRect(find.byKey(const ValueKey('content')));
}

void main() {
  group('SlideCanvas', () {
    testWidgets('scales content up, not just down', (tester) async {
      // A diagram at the deck's most common natural width. Before this widget
      // existed it rendered at exactly 980 on a 1920 screen, using barely half
      // the width — which is the whole complaint it answers.
      const natural = Size(980, 420);
      final rect = await _rendered(tester, natural);

      expect(rect.width, greaterThan(natural.width));
      expect(rect.width / natural.width, greaterThan(1.2));
    });

    testWidgets('scales sparse and dense slides by the same amount', (
      tester,
    ) async {
      // Both are smaller than the design floor, so both are scaled as if they
      // were exactly the floor. Without that, a sparse slide would come out
      // with enormous type and a dense one with small type, and the deck's
      // apparent font size would lurch slide to slide.
      final sparse = await _rendered(tester, const Size(400, 160));
      final dense = await _rendered(tester, const Size(1100, 520));

      expect(
        sparse.width / 400,
        closeTo(dense.width / 1100, 0.01),
        reason: 'one scale for the whole deck',
      );
    });

    testWidgets('keeps oversized content inside the screen', (tester) async {
      // Taller than the floor: the scale has to come back down, and nothing
      // may hang off the projector.
      final rect = await _rendered(tester, const Size(1600, 1400));

      expect(rect.left, greaterThanOrEqualTo(-0.5));
      expect(rect.top, greaterThanOrEqualTo(-0.5));
      expect(rect.right, lessThanOrEqualTo(_fhd.width + 0.5));
      expect(rect.bottom, lessThanOrEqualTo(_fhd.height + 0.5));
    });
  });
}
