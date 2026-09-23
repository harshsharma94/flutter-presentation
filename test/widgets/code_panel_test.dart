import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';

import '../support/pump.dart';

const _short = 'final a = 1;';
const _tall = '''
final a = 1;
final b = 2;
final c = 3;
final d = 4;
final e = 5;''';

/// Measures the panel as a slide's `FittedBox` would: the size of the box the
/// panel occupies, which is what `FittedBox` divides by to pick its scale.
Future<Size> _measure(
  WidgetTester tester,
  String code, {
  List<String> sizedFor = const [],
}) async {
  await pumpBody(
    tester,
    Center(
      child: UnconstrainedBox(
        child: CodePanel(code: code, sizedFor: sizedFor),
      ),
    ),
  );
  return tester.getSize(find.byType(CodePanel));
}

void main() {
  group('CodePanel', () {
    testWidgets('changes size with its code when nothing is reserved', (
      tester,
    ) async {
      final short = await _measure(tester, _short);
      final tall = await _measure(tester, _tall);

      // Not a defect in itself — it is why `sizedFor` is needed for any panel
      // inside a FittedBox, which rescales when its child's size changes.
      expect(tall.height, greaterThan(short.height));
    });

    testWidgets('holds one size across every variant it is sized for', (
      tester,
    ) async {
      const variants = [_short, _tall];
      final showingShort = await _measure(tester, _short, sizedFor: variants);
      final showingTall = await _measure(tester, _tall, sizedFor: variants);

      // The guarantee the morph animation rests on: the enclosing FittedBox
      // computes one scale and keeps it for the whole transition.
      expect(showingShort, showingTall);
    });

    testWidgets('reserves the largest variant, not the current one', (
      tester,
    ) async {
      final tallAlone = await _measure(tester, _tall);
      final shortReserved = await _measure(
        tester,
        _short,
        sizedFor: const [_short, _tall],
      );

      expect(shortReserved.height, tallAlone.height);
    });
  });
}
