import 'package:flutter_test/flutter_test.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/widgets/frame_strip.dart';

import '../support/pump.dart';

void main() {
  testWidgets('all ticks flow green when not stalled', (tester) async {
    await pumpBody(
      tester,
      const FrameStrip(frameCount: 60, stalled: false, stalledFrom: 20, stalledTo: 45),
    );
    final painter = stripPainterOf(tester);
    expect(painter.stalled, isFalse);
    expect(painter.colorAt(30), Palette.green);
  });

  testWidgets('stalled range turns red', (tester) async {
    await pumpBody(
      tester,
      const FrameStrip(frameCount: 60, stalled: true, stalledFrom: 20, stalledTo: 45),
    );
    final painter = stripPainterOf(tester);
    expect(painter.colorAt(30), Palette.red);
    expect(painter.colorAt(10), Palette.green);
  });
}
