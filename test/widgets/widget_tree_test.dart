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
}
