import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';

import '../support/pump.dart';

void main() {
  testWidgets('arrow has zero progress before its step', (tester) async {
    await pumpBody(
      tester,
      const AnimatedArrow(from: Offset(0, 0), to: Offset(100, 100), atStep: 2),
      step: 1,
    );
    // find.byType(CustomPaint).first can resolve to a framework CustomPaint
    // (Scaffold/Material ink effects) with a null painter rather than ours,
    // so this locates AnimatedArrow's CustomPaint by its ValueKey instead.
    final painter =
        tester
                .widget<CustomPaint>(
                  find.byKey(const ValueKey('arrow-painter')),
                )
                .painter!
            as ArrowPainter;
    expect(painter.progress, 0.0);
  });

  testWidgets('arrow is fully drawn once its step arrives', (tester) async {
    await pumpBody(
      tester,
      const AnimatedArrow(from: Offset(0, 0), to: Offset(100, 100), atStep: 2),
      step: 2,
    );
    final painter =
        tester
                .widget<CustomPaint>(
                  find.byKey(const ValueKey('arrow-painter')),
                )
                .painter!
            as ArrowPainter;
    expect(painter.progress, 1.0);
  });

  testWidgets('dashed box renders its child', (tester) async {
    await pumpBody(
      tester,
      const DashedBox(atStep: 1, child: Text('region')),
      step: 1,
    );
    expect(find.text('region'), findsOneWidget);
  });

  testWidgets('callout hides before its step and shows once it arrives', (
    tester,
  ) async {
    await pumpBody(tester, const Callout(atStep: 2, text: 'note'), step: 1);
    final hiddenOpacity = tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.text('note'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(hiddenOpacity, 0.0);

    await pumpBody(tester, const Callout(atStep: 2, text: 'note'), step: 2);
    expect(find.text('note'), findsOneWidget);
    final visibleOpacity = tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.text('note'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(visibleOpacity, 1.0);
  });
}
