import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/rebuild_scope_demo.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 35 — `/watch-read-consumer` (1 step, A28). Live and interactive,
/// not step-driven: hand over the keyboard. The flash region is the lesson.
class WatchReadConsumerBody extends StatelessWidget {
  const WatchReadConsumerBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapMd),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Same notifier. Three readers. Watch what rebuilds.',
                style: TextStyle(color: pal.textPrimary, fontSize: 29),
              ),
              SizedBox(height: Tokens.gapMd),
              RebuildScopeDemo(),
            ],
          ),
        ),
      ),
    );
  }
}
