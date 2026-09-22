import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/widgets/rebuild_flash.dart';

import '../support/pump.dart';

void main() {
  testWidgets('counts a rebuild each time it builds', (tester) async {
    final tally = RebuildTally();
    final notifier = ValueNotifier(0);
    addTearDown(notifier.dispose);

    await pumpBody(
      tester,
      RebuildTallyScope(
        tally: tally,
        child: ValueListenableBuilder<int>(
          valueListenable: notifier,
          builder: (_, v, _) => RebuildFlash(id: 'node-a', child: Text('$v')),
        ),
      ),
    );
    expect(tally.countFor('node-a'), 1);

    notifier.value = 1;
    await tester.pump();
    expect(tally.countFor('node-a'), 2);
  });
}
