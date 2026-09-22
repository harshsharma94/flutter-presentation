import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

Widget _harness(int step) => MaterialApp(
      home: StepScope(
        step: step,
        child: const StepReveal(atStep: 2, child: Text('hello')),
      ),
    );

double _opacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.ancestor(
      of: find.text('hello'),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity;

void main() {
  testWidgets('hidden before its step', (tester) async {
    await tester.pumpWidget(_harness(1));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 0.0);
  });

  testWidgets('fully visible on its step', (tester) async {
    await tester.pumpWidget(_harness(2));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1.0);
  });

  testWidgets('dims rather than disappears after its step', (tester) async {
    await tester.pumpWidget(_harness(3));
    await tester.pumpAndSettle();
    expect(_opacity(tester), Tokens.dimmed);
  });

  testWidgets('until hides it again', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const StepScope(
        step: 4,
        child: StepReveal(atStep: 2, until: 3, child: Text('hello')),
      ),
    ));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 0.0);
  });

  testWidgets('StepScope.of throws a useful error when missing',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StepReveal(atStep: 1, child: Text('hello')),
    ));
    expect(tester.takeException(), isA<FlutterError>());
  });
}
