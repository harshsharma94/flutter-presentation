import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/sequence_diagram.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

import '../support/pump.dart';

final _lanes = [
  SequenceLane(id: 'app', label: 'App'),
  SequenceLane(id: 'browser', label: 'Browser'),
  SequenceLane(id: 'auth', label: 'Auth Server'),
  SequenceLane(id: 'api', label: 'API'),
];

/// The same nine hops slide 15 (`/oauth-flow`) renders, so this widget test
/// exercises `SequenceDiagram` against its real configuration rather than a
/// toy one. Self-contained — reads `step` from the ambient `StepScope` the
/// way a slide body would, plus the two `TokenPill`s slide 15 positions
/// alongside the diagram, so `pill-access` is reachable the same way it is
/// on the real slide.
final _hops = [
  SequenceHop(from: 'app', to: 'browser', label: 'open /authorize', atStep: 1),
  SequenceHop(from: 'browser', to: 'browser', label: 'user logs in', atStep: 2),
  SequenceHop(from: 'auth', to: 'app', label: 'code', atStep: 3),
  SequenceHop(
    from: 'app',
    to: 'auth',
    label: 'exchange code + secret',
    atStep: 4,
  ),
  SequenceHop(from: 'auth', to: 'app', label: 'tokens issued', atStep: 5),
  SequenceHop(from: 'app', to: 'api', label: 'GET /photos', atStep: 6),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos -> 401',
    atStep: 8,
    color: Palette.red,
  ),
  SequenceHop(from: 'app', to: 'auth', label: 'refresh', atStep: 9),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos',
    atStep: 9,
    color: Palette.green,
    replay: true,
  ),
];

class _OAuthFixture extends StatelessWidget {
  const _OAuthFixture();

  @override
  Widget build(BuildContext context) {
    final step = StepScope.of(context);
    final expired = step == 7 || step == 8;
    return Stack(
      children: [
        SequenceDiagram(lanes: _lanes, hops: _hops),
        TokenPill(
          key: const ValueKey('pill-access'),
          label: 'abc123',
          widthFactor: 0.35,
          color: Palette.blue,
          expired: expired,
        ),
        TokenPill(
          key: ValueKey('pill-refresh'),
          label: 'eyJhbG...',
          widthFactor: 0.9,
          color: Palette.green,
          expired: false,
        ),
      ],
    );
  }
}

void main() {
  // AnimatedArrow carries a fixed ValueKey('arrow-painter'), so with nine
  // hops stacked on one diagram it cannot be selected by key — this is the
  // predicate + `.at(i)` technique the deck's multi-arrow slides use
  // (see test/widgets/annotate_test.dart's single-arrow key lookup, and
  // structure_slide.dart / api_gap_slide.dart for the multi-arrow case).
  Finder arrowsFinder() => find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is ArrowPainter,
  );

  ArrowPainter painterAt(WidgetTester tester, int i) =>
      tester.widget<CustomPaint>(arrowsFinder().at(i)).painter! as ArrowPainter;

  testWidgets('renders one arrow per crossing hop (self-event excluded)', (
    tester,
  ) async {
    await pumpBody(tester, const _OAuthFixture(), step: 9);
    // 9 hops, one of which (step 2, "user logs in") is same-lane and draws
    // a badge instead of an arrow: 8 arrows.
    expect(arrowsFinder(), findsNWidgets(8));
  });

  testWidgets('only hops that have arrived are drawn', (tester) async {
    await pumpBody(tester, const _OAuthFixture(), step: 3);
    // Arrow 0 is "open /authorize" (atStep 1) — arrived.
    expect(painterAt(tester, 0).progress, 1.0);
    // Arrow 2 is "exchange code + secret" (atStep 4) — not yet.
    expect(painterAt(tester, 2).progress, 0.0);
  });

  testWidgets('the replayed request draws in green once refreshed', (
    tester,
  ) async {
    await pumpBody(tester, const _OAuthFixture(), step: 9);
    // Arrow 7 is the replayed GET /photos (atStep 9, replay: true).
    final painter = painterAt(tester, 7);
    expect(painter.progress, 1.0);
    expect(painter.color, Palette.green);
  });

  testWidgets('expired token pill collapses', (tester) async {
    await pumpBody(tester, const _OAuthFixture(), step: 7);
    final pill = tester.widget<TokenPill>(
      find.byKey(const ValueKey('pill-access')),
    );
    expect(pill.expired, isTrue);
  });

  testWidgets('token pill is not expired before step 7', (tester) async {
    await pumpBody(tester, const _OAuthFixture(), step: 5);
    final pill = tester.widget<TokenPill>(
      find.byKey(const ValueKey('pill-access')),
    );
    expect(pill.expired, isFalse);
  });
}
