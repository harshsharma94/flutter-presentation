import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

/// A single burst of confetti, played once each time the widget mounts.
///
/// Finite by construction: a [TweenAnimationBuilder] runs 0 to 1 and stops,
/// so it settles like every other animation in the deck and the smoke test's
/// bounded pumps are never waiting on it. The particles come from a seeded
/// [math.Random], so the burst is identical every run — no flaky golden, and
/// no two rehearsals that look different.
///
/// Drawn with a painter rather than emoji or images on purpose: an emoji needs
/// a colour-emoji font that Flutter web downloads at runtime, which renders as
/// empty boxes on venue wifi that is down.
class ConfettiBurst extends StatelessWidget {
  const ConfettiBurst({super.key});

  static const _duration = Duration(milliseconds: 2800);

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _duration,
      builder: (context, t, _) =>
          CustomPaint(size: Size.infinite, painter: _ConfettiPainter(t)),
    ),
  );
}

class _Piece {
  _Piece(math.Random random)
    : angle = -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 0.9,
      speed = 0.55 + random.nextDouble() * 0.75,
      spin = (random.nextDouble() - 0.5) * 14,
      size = 9 + random.nextDouble() * 9,
      originX = 0.5 + (random.nextDouble() - 0.5) * 0.25,
      color = _colors[random.nextInt(_colors.length)];

  static const _colors = [
    Palette.blue,
    Palette.green,
    Palette.amber,
    Palette.red,
  ];

  /// Launch direction: upward, fanned about ±80°.
  final double angle;

  /// In canvas-heights per second, so the burst scales with the slide.
  final double speed;
  final double spin;
  final double size;

  /// Launch point, as a fraction of the width, near the centre.
  final double originX;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  final double t;

  static final _pieces = () {
    final random = math.Random(7);
    return List.generate(90, (_) => _Piece(random));
  }();

  /// Gravity, in canvas-heights per second squared.
  static const _gravity = 1.1;

  /// How long the burst plays, in seconds, over t 0 -> 1.
  static const _seconds = 2.8;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final seconds = t * _seconds;
    // Full strength for the first half, then fade out.
    final opacity = t < 0.5 ? 1.0 : (1 - (t - 0.5) / 0.5).clamp(0.0, 1.0);
    final paint = Paint();

    for (final piece in _pieces) {
      final vx = math.cos(piece.angle) * piece.speed;
      final vy = math.sin(piece.angle) * piece.speed;
      final x = size.width * piece.originX + vx * size.height * seconds;
      final y =
          size.height * 0.62 +
          (vy * seconds + 0.5 * _gravity * seconds * seconds) * size.height;

      paint.color = piece.color.withValues(alpha: opacity);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(piece.spin * seconds)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.55,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
