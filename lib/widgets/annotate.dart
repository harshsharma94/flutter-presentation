/// The drawing layer for diagram slides: arrows that draw themselves,
/// dashed boxes that outline a region, and small callout labels.
///
/// Everything here is step-driven — an element is either not-yet-arrived,
/// mid-draw, or fully drawn, derived purely from the ambient [StepScope].
/// There is no [AnimationController] and no timer, so stepping backward
/// simply re-targets the animation toward 0 with no retained state.
library;

import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

/// Draws a straight or curved arrow from [from] to [to] as the deck steps
/// forward to [atStep]. Fully drawn once the step has arrived; empty before
/// it. Coordinates are relative to the ancestor that sizes this widget
/// (typically a [Stack] via `Positioned.fill`).
class AnimatedArrow extends StatelessWidget {
  const AnimatedArrow({
    required this.from,
    required this.to,
    required this.atStep,
    this.color = Palette.textSecondary,
    this.curved = false,
    this.dashed = false,
    super.key,
  });

  final Offset from;
  final Offset to;
  final int atStep;
  final Color color;
  final bool curved;

  /// Draws the line as a dash pattern (reusing [DashedBox]'s segmenting)
  /// instead of a solid stroke — for a line that reads as "attempted" or
  /// "in progress" rather than resolved. A4 (slide 6, `/api-gap`) uses this
  /// for the first, failed crossing attempt, then a plain solid
  /// [AnimatedArrow] for the completed one.
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final arrived = StepScope.of(context) >= atStep;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: arrived ? 1.0 : 0.0),
      duration: Tokens.travel,
      curve: Tokens.curve,
      builder: (context, progress, child) => CustomPaint(
        key: const ValueKey('arrow-painter'),
        size: Size.infinite,
        painter: ArrowPainter(
          from: from,
          to: to,
          progress: progress,
          color: color,
          curved: curved,
          dashed: dashed,
        ),
      ),
    );
  }
}

/// How far the quadratic bézier's control point bows away from the straight
/// line between [ArrowPainter.from] and [ArrowPainter.to], for curved arrows.
const _curveBow = 40.0;

/// Arrowhead geometry, in logical pixels / radians.
const _headLength = 12.0;
const _headAngle = 0.5;

/// Once the drawn line reaches this fraction of its length, the arrowhead
/// appears. Below it, a half-drawn arrow has no floating head.
const _headThreshold = 0.95;

/// Paints [ArrowPainter.progress] (0 to 1) of the path from [from] to [to],
/// clipped with [PathMetric.extractPath] so the line *draws* rather than
/// fades in. The arrowhead only appears once the line is essentially
/// complete, so a half-drawn arrow never shows a floating head.
class ArrowPainter extends CustomPainter {
  ArrowPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.color,
    this.curved = false,
    this.dashed = false,
  });

  final Offset from;
  final Offset to;
  final double progress;
  final Color color;
  final bool curved;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final path = Path()..moveTo(from.dx, from.dy);
    if (curved) {
      final control = _controlPoint();
      path.quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
    } else {
      path.lineTo(to.dx, to.dy);
    }

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = Tokens.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final end = (metric.length * progress).clamp(0.0, metric.length);
    final drawn = metric.extractPath(0, end);
    canvas.drawPath(dashed ? _dashPath(drawn) : drawn, linePaint);

    if (progress > _headThreshold) {
      _paintArrowhead(canvas, metric, linePaint);
    }
  }

  Offset _controlPoint() {
    final delta = to - from;
    if (delta.distance == 0) return from;
    final normal = Offset(-delta.dy, delta.dx) / delta.distance;
    return Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2) + normal * _curveBow;
  }

  void _paintArrowhead(Canvas canvas, PathMetric metric, Paint linePaint) {
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;

    final tip = tangent.position;
    final direction = tangent.angle;
    final left = tip - Offset.fromDirection(direction - _headAngle, _headLength);
    final right = tip - Offset.fromDirection(direction + _headAngle, _headLength);

    canvas.drawPath(
      Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      dashed != oldDelegate.dashed;
}

/// The dash pattern for [DashedBox]'s border.
const _dashWidth = 6.0;
const _dashGap = 4.0;

/// Outlines [child] with a dashed rounded-rectangle border once [atStep]
/// arrives. Used to call out an existing region of a diagram or screenshot
/// without touching its layout.
class DashedBox extends StatelessWidget {
  const DashedBox({
    required this.atStep,
    required this.child,
    this.color = Palette.textSecondary,
    super.key,
  });

  final int atStep;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => StepReveal(
        atStep: atStep,
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(color: color),
          child: child,
        ),
      );
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(Tokens.radius),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = Tokens.strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(_dashPath(Path()..addRRect(rrect)), paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Splits [source] into alternating drawn/skipped segments of
/// [_dashWidth]/[_dashGap] along its length, using [PathMetric.extractPath]
/// per segment.
Path _dashPath(Path source) {
  final dashed = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    var draw = true;
    while (distance < metric.length) {
      final next = (distance + (draw ? _dashWidth : _dashGap)).clamp(0.0, metric.length);
      if (draw) {
        dashed.addPath(metric.extractPath(distance, next), Offset.zero);
      }
      distance = next;
      draw = !draw;
    }
  }
  return dashed;
}

/// [Callout]'s border is deliberately thinner than [Tokens.strokeWidth] —
/// it labels a point rather than framing a region.
const _calloutBorderWidth = 1.0;
const _calloutFontSize = 16.0;

/// A small rounded label with a [color] border, for a short annotation
/// pointing at a specific value or line rather than a whole region.
class Callout extends StatelessWidget {
  const Callout({
    required this.atStep,
    required this.text,
    this.color = Palette.textSecondary,
    super.key,
  });

  final int atStep;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => StepReveal(
        atStep: atStep,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Tokens.gapSm,
            vertical: Tokens.gapXs,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: _calloutBorderWidth),
            borderRadius: BorderRadius.circular(Tokens.radius),
          ),
          child: Text(text, style: TextStyle(color: color, fontSize: _calloutFontSize)),
        ),
      );
}
