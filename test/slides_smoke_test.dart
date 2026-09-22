import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/slides/registry.dart';

import 'support/pump.dart';

void main() {
  group('every slide renders at every step', () {
    for (final spec in slideRegistry) {
      for (var step = 1; step <= spec.steps; step++) {
        for (final brightness in Brightness.values) {
          for (final size in const [fhd, hd]) {
            testWidgets(
              '${spec.route} step $step ${brightness.name} ${size.width.toInt()}w',
              (tester) async {
                await pumpBody(
                  tester,
                  spec.body(step),
                  step: step,
                  size: size,
                  brightness: brightness,
                );
                // A RenderFlex overflow surfaces here. This is the assertion
                // that matters: the failure mode we care about is a slide
                // breaking in front of an audience.
                expect(tester.takeException(), isNull);
              },
            );
          }
        }
      }
    }
  });

  test('routes are unique', () {
    final routes = slideRegistry.map((s) => s.route).toList();
    expect(routes.toSet().length, routes.length);
  });

  test('every slide declares at least one step', () {
    expect(slideRegistry.every((s) => s.steps >= 1), isTrue);
  });
}
