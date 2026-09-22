import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/demos/rebuild_scope_demo.dart';

import '../support/pump.dart';

/// The decision gate for A28: the slide is only honest if the flash region
/// genuinely differs between watch-at-root and Consumer-at-leaf. This asserts
/// the property the audience is asked to see.
void main() {
  testWidgets('Consumer rebuilds far less of the tree than watch',
      (tester) async {
    await pumpBody(tester, RebuildScopeDemo());
    await tester.pump();

    Future<int> buildsPerTick() async {
      final before = _totalFrom(tester);
      await tester.tap(find.byKey(const ValueKey('rebuild-increment')));
      // Two frames: one for the rebuild itself, one for the post-frame
      // notify that refreshes the readout.
      await tester.pump();
      await tester.pump();
      return _totalFrom(tester) - before;
    }

    final watchBuilds = await buildsPerTick();

    await tester.tap(find.text('Consumer (leaf)'));
    await tester.pump();
    await tester.pump();
    final consumerBuilds = await buildsPerTick();

    expect(watchBuilds, greaterThan(consumerBuilds));
    expect(consumerBuilds, 1);
  });
}

int _totalFrom(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.textContaining('widget builds since'))
      .first
      .data!;
  return int.parse(text.split(': ').last);
}
