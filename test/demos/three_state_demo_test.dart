import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/demos/three_state_demo.dart';

import '../support/pump.dart';

void main() {
  testWidgets('tapping error swaps the phone content', (tester) async {
    await pumpBody(tester, ThreeStateDemo());
    expect(find.byKey(const ValueKey('state-loading')), findsOneWidget);
    await tester.tap(find.text('error'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('state-error')), findsOneWidget);
  });

  testWidgets('tapping data fetches and swaps to the data state', (
    tester,
  ) async {
    await pumpBody(tester, ThreeStateDemo());
    await tester.tap(find.text('data'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('state-data')), findsOneWidget);
  });

  testWidgets('tapping loading after error swaps back', (tester) async {
    await pumpBody(tester, ThreeStateDemo());
    await tester.tap(find.text('error'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('loading'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('state-loading')), findsOneWidget);
  });
}
