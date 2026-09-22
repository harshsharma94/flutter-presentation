import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/widgets/live_badge.dart';

/// Slide 37 — `/live-convert-provider` (1 step).
class LiveConvertProviderBody extends StatelessWidget {
  const LiveConvertProviderBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => LiveSlideBody(
        goal: 'Convert both screens to Provider.',
      );
}
