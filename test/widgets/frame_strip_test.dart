import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/widgets/frame_strip.dart';

import '../support/pump.dart';

void main() {
  testWidgets('all ticks flow green when not stalled', (tester) async {
    await pumpBody(
      tester,
      const FrameStrip(
          frameCount: 60, stalled: false, stalledFrom: 20, stalledTo: 45),
    );
    final painter = stripPainterOf(tester);
    expect(painter.stalled, isFalse);
    expect(painter.colorAt(30), Palette.green);
  });

  testWidgets('stalled range turns red', (tester) async {
    await pumpBody(
      tester,
      const FrameStrip(
          frameCount: 60, stalled: true, stalledFrom: 20, stalledTo: 45),
    );
    final painter = stripPainterOf(tester);
    expect(painter.colorAt(30), Palette.red);
    expect(painter.colorAt(10), Palette.green);
  });
}
