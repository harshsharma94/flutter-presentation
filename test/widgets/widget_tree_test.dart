import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gopay_flutter_deck/widgets/widget_tree.dart';

import '../support/pump.dart';

void main() {
  testWidgets('renders every node label', (tester) async {
    await pumpBody(tester, const WidgetTreeView(root: demoTree));
    expect(find.text('PhotoApp'), findsOneWidget);
    expect(find.text('PhotoTile'), findsWidgets);
  });

  testWidgets('shows parameters threaded through a node', (tester) async {
    await pumpBody(
      tester,
      const WidgetTreeView(root: demoTree, showParams: true),
    );
    expect(find.textContaining('photos'), findsWidgets);
  });

  testWidgets('flashing nodes are highlighted', (tester) async {
    await pumpBody(
      tester,
      const WidgetTreeView(root: demoTree, flashing: {'tile-1'}),
    );
    expect(find.byKey(const ValueKey('flash-tile-1')), findsOneWidget);
  });

  // The nine slides across §6 reuse this exact tree and rely on its node
  // positions never jumping between slides — see the library doc's
  // determinism guarantee. These two tests protect that invariant directly,
  // rather than trusting it stays true as the widget evolves.
  const trackedIds = [
    'photo-app',
    'home-screen',
    'photo-grid',
    'tile-1',
    'tile-2',
    'like-1',
    'like-2',
  ];

  Map<String, double> dxByNode(WidgetTester tester) => {
        for (final id in trackedIds)
          id: tester.getTopLeft(find.byKey(ValueKey('flash-$id'))).dx,
      };

  Map<String, double> dyByNode(WidgetTester tester) => {
        for (final id in trackedIds)
          id: tester.getTopLeft(find.byKey(ValueKey('flash-$id'))).dy,
      };

  testWidgets('showParams moves no node', (tester) async {
    await pumpBody(tester, const WidgetTreeView(root: demoTree));
    final beforeX = dxByNode(tester);
    final beforeY = dyByNode(tester);

    await pumpBody(
      tester,
      const WidgetTreeView(root: demoTree, showParams: true),
    );
    expect(dxByNode(tester), beforeX);
    expect(dyByNode(tester), beforeY);
  });

  testWidgets('flashing, subscribed and traversalTo move no node',
      (tester) async {
    await pumpBody(tester, const WidgetTreeView(root: demoTree));
    final beforeX = dxByNode(tester);
    final beforeY = dyByNode(tester);

    await pumpBody(
      tester,
      const WidgetTreeView(
        root: demoTree,
        flashing: {'tile-1'},
        subscribed: {'like-1', 'like-2'},
        traversalTo: 'like-2',
      ),
    );
    expect(dxByNode(tester), beforeX);
    expect(dyByNode(tester), beforeY);
  });

  test('treeNodePositions is a pure function of (root, size)', () {
    const size = Size(640, 560);
    final first = treeNodePositions(demoTree, size);
    final second = treeNodePositions(demoTree, size);

    expect(first, second);
    expect(first.keys.toSet(), trackedIds.toSet());
  });
}
