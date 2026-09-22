import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';

import '../support/pump.dart';

void main() {
  final panel = CorrelationPanel(
    flutterLabel: 'Dio',
    rows: [
      CorrelationRow(platform: 'Android', concept: 'Retrofit + OkHttp'),
      CorrelationRow(platform: 'iOS', concept: 'URLSession'),
    ],
  );

  testWidgets('reveals one row per step', (tester) async {
    await pumpBody(tester, panel, step: 1);
    expect(find.text('Retrofit + OkHttp'), findsOneWidget);
    expect(find.text('Dio'), findsOneWidget);
  });

  testWidgets('known-platform side uses the green accent', (tester) async {
    await pumpBody(tester, panel, step: 3);
    final text = tester.widget<Text>(find.text('Retrofit + OkHttp'));
    expect(text.style?.color, Palette.green);
  });
}
