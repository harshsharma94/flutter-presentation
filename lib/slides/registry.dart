import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/slides/slide_spec.dart';

/// The ordered list of every slide in the deck. This is the single source of
/// truth: `main.dart` builds the deck from it and `slides_smoke_test.dart`
/// iterates it, so a slide cannot exist without being covered by the gate.
///
/// Grouped by section so cutting a slide is a one-line deletion (spec §14).
final List<SlideSpec> slideRegistry = [
  // §0 Open
  SlideSpec(
    route: '/title',
    section: 'GoPay · Flutter Bootcamp',
    title: 'Day 2 — Making It Real',
    body: (step) => const Center(child: Text('GoPay · Flutter Bootcamp')),
  ),
];
