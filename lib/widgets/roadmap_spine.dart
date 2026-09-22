import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// The day's five-node roadmap — API · Auth · Data · Architecture · State —
/// built full-size on slide 3 (`/roadmap`) and reused in [compact] form as
/// the section-opening chip on the slides that open each section: 5, 12,
/// 16, 22, 28, 36, 39, 41, 42 and 48.
///
/// [activeNode] is 0-5: 0 means no node has started yet (every node reads as
/// upcoming); node `n` (1-5) renders lit in [Palette.blue]; nodes before it
/// stay lit at [Tokens.dimmed] as a reminder of what is already covered;
/// nodes after it are [pal.textSecondary] (not yet reached). Colour
/// transitions are animated so a step-driven caller (slide 3, advancing
/// [activeNode] by one per step) gets a smooth hand-off between nodes with
/// no [AnimationController] involved.
class RoadmapSpine extends StatelessWidget {
  const RoadmapSpine({
    required this.activeNode,
    this.compact = false,
    super.key,
  });

  final int activeNode;
  final bool compact;

  static const _labels = ['API', 'Auth', 'Data', 'Architecture', 'State'];

  Color _dotColor(int node, DeckColors pal) {
    if (node < activeNode) return Palette.blue.withValues(alpha: Tokens.dimmed);
    if (node == activeNode) return Palette.blue;
    return pal.textSecondary;
  }

  Color _connectorColor(int beforeNode, DeckColors pal) =>
      beforeNode <= activeNode
      ? Palette.blue.withValues(alpha: Tokens.dimmed)
      : pal.textSecondary;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final dotSize = compact ? 10.0 : 28.0;
    final connectorLength = compact ? 20.0 : 56.0;
    final connectorWidth = compact ? 2.0 : Tokens.strokeWidth;
    final fontSize = compact ? 10.0 : 18.0;
    final labelGap = compact ? Tokens.gapXs / 2 : Tokens.gapXs;
    final itemGap = compact ? Tokens.gapXs : Tokens.gapMd;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var node = 1; node <= _labels.length; node++) ...[
          if (node > 1) ...[
            SizedBox(width: itemGap / 2),
            AnimatedContainer(
              duration: Tokens.travel,
              curve: Tokens.curve,
              width: connectorLength,
              height: connectorWidth,
              color: _connectorColor(node - 1, pal),
            ),
            SizedBox(width: itemGap / 2),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: Tokens.travel,
                curve: Tokens.curve,
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: _dotColor(node, pal),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: labelGap),
              AnimatedDefaultTextStyle(
                duration: Tokens.travel,
                curve: Tokens.curve,
                style: TextStyle(
                  color: _dotColor(node, pal),
                  fontSize: fontSize,
                ),
                child: Text(_labels[node - 1]),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
