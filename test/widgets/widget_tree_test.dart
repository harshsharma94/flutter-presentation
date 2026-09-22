import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/widget_tree.dart';

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

  // Regression coverage for the A24 finding: the traversal pulse must light
  // the ancestor-chain *edges*, not just the node borders, or the audience
  // has no connecting cue that a single pulse is travelling up the tree.
  //
  // TreeEdgePainter is public specifically so these tests can find it via
  // its ValueKey('tree-edges'), cast to it, and inspect `pathIds` /
  // `edgeProgress` directly — the same pattern annotate_test.dart uses for
  // ArrowPainter.progress, and far more robust than asserting on the exact
  // sequence of canvas draw calls (which is an implementation detail of
  // traversal order, not a public contract).
  TreeEdgePainter edgePainter(WidgetTester tester) => tester
      .widget<CustomPaint>(find.byKey(const ValueKey('tree-edges')))
      .painter! as TreeEdgePainter;

  testWidgets('no traversal means no path and no lit edges', (tester) async {
    await pumpBody(tester, const WidgetTreeView(root: demoTree));
    final painter = edgePainter(tester);
    expect(painter.pathIds, isEmpty);
    expect(painter.edgeProgress('tile-2', 'like-2'), 0.0);
  });

  testWidgets(
      'settled traversal fully lights every edge on the ancestor path',
      (tester) async {
    await pumpBody(
      tester,
      const WidgetTreeView(root: demoTree, traversalTo: 'like-2'),
    );
    // pumpBody settles the animation, so progress has reached 1.0 and every
    // edge on the like-2 -> tile-2 -> photo-grid -> home-screen -> photo-app
    // chain should be fully lit - both the one nearest the target and the
    // one nearest the root, which is exactly the "one continuous movement"
    // property the A24 finding was about: no edge is left behind.
    final painter = edgePainter(tester);
    expect(
      painter.pathIds,
      ['photo-app', 'home-screen', 'photo-grid', 'tile-2', 'like-2'],
    );
    expect(painter.edgeProgress('tile-2', 'like-2'), 1.0);
    expect(painter.edgeProgress('photo-grid', 'tile-2'), 1.0);
    expect(painter.edgeProgress('home-screen', 'photo-grid'), 1.0);
    expect(painter.edgeProgress('photo-app', 'home-screen'), 1.0);
    // The untouched tile-1/like-1 branch never lit, even once traversal
    // settles - only the ancestor chain to the target does.
    expect(painter.edgeProgress('photo-grid', 'tile-1'), 0.0);
    expect(painter.edgeProgress('tile-1', 'like-1'), 0.0);
  });

  // Direct, deterministic coverage of the staggering formula itself, built
  // by constructing TreeEdgePainter with a controlled `progress` rather than
  // pumping a real animation partway through - `positions` is irrelevant to
  // `edgeProgress`, so an empty map is fine here.
  const path = ['photo-app', 'home-screen', 'photo-grid', 'tile-2', 'like-2'];

  test('the edge nearest the target lights well before the edge nearest '
      'the root, for the same overall progress', () {
    const painter = TreeEdgePainter(
      root: demoTree,
      positions: {},
      pathIds: path,
      progress: 0.5,
    );
    // Halfway through the overall animation, the edge leading into the
    // target is already fully lit...
    expect(painter.edgeProgress('tile-2', 'like-2'), 1.0);
    // ...while the edge leading into the root - the far end of the chain -
    // has not started lighting at all yet. This gap is what makes the pulse
    // read as travelling, not simultaneous.
    expect(painter.edgeProgress('photo-app', 'home-screen'), 0.0);
  });

  test('an edge off the traversal path never lights, at any progress', () {
    const painter = TreeEdgePainter(
      root: demoTree,
      positions: {},
      pathIds: path,
      progress: 1.0,
    );
    expect(painter.edgeProgress('photo-grid', 'tile-1'), 0.0);
    expect(painter.edgeProgress('tile-1', 'like-1'), 0.0);
  });

  test('with no active traversal, no edge ever lights', () {
    const painter = TreeEdgePainter(
      root: demoTree,
      positions: {},
      pathIds: [],
      progress: 1.0,
    );
    expect(painter.edgeProgress('tile-2', 'like-2'), 0.0);
  });

  // The tests above feed edgeProgress a hand-picked `progress` value, which
  // only proves the formula is internally monotonic - it cannot catch a bug
  // in how real elapsed time maps to that value (exactly the bug an earlier
  // version of this fix had: curving the rescaled *global* progress instead
  // of curving *within* each edge's own local window desynced every
  // interior edge from the node it leads into by hundreds of milliseconds,
  // while every hand-fed-progress test above kept passing). This test pumps
  // real durations instead, the same way `annotate_test.dart` proves
  // `AnimatedArrow` reaches progress 1.0 "once its step arrives" rather than
  // asserting on the tween's shape directly.
  //
  // WidgetTreeView needs no StepScope/FlutterDeckTheme ancestor (it reads no
  // ambient step; callers decide what to pass), so this uses a minimal
  // MaterialApp/Scaffold harness rather than pumpBody, which unconditionally
  // calls pumpAndSettle - incompatible with checking a specific instant
  // mid-animation.
  testWidgets(
      'edge (photo-grid -> tile-2) reaches full brightness exactly when '
      "photo-grid's own border finishes arriving, not before", (tester) async {
    tester.view
      ..physicalSize = const Size(1920, 1080)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WidgetTreeView(root: demoTree, traversalTo: 'like-2'),
        ),
      ),
    );

    // path = [photo-app, home-screen, photo-grid, tile-2, like-2], length 5.
    // photo-grid is distance 2 from the target (like-2); its own AnimatedContainer
    // border duration is Tokens.travel * (2 + 1) = 1200ms, so it finishes
    // arriving at real time 1200ms. The photo-grid -> tile-2 edge's window is
    // [Tokens.travel * 2, Tokens.travel * 3] = [800ms, 1200ms], so it should
    // still be short of fully lit 1ms before that instant, and exactly lit
    // at it.
    await tester.pump(Tokens.travel * 3 - const Duration(milliseconds: 1));
    expect(
      edgePainter(tester).edgeProgress('photo-grid', 'tile-2'),
      lessThan(1.0),
    );

    await tester.pump(const Duration(milliseconds: 1));
    expect(edgePainter(tester).edgeProgress('photo-grid', 'tile-2'), 1.0);
  });
}
