import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

/// A strip of [frameCount] tick marks standing in for a UI's frame budget —
/// A6 (slide 9)'s central visual. Every tick is [Palette.green] ("still
/// rendering") except the ticks inside `[stalledFrom, stalledTo)`, which
/// turn [Palette.red] but only while [stalled] is true; outside that range
/// (or with [stalled] false) every tick stays green regardless.
///
/// Deliberately dumb: this widget draws a static snapshot of tick colours
/// for the ambient step, it does not itself animate or advance a "playhead"
/// over time. The illusion of the strip "stopping" and "resuming" comes from
/// the slide flipping [stalled] between steps, not from a [Timer] or
/// [AnimationController] inside here.
class FrameStrip extends StatelessWidget {
  const FrameStrip({
    required this.frameCount,
    required this.stalledFrom,
    required this.stalledTo,
    required this.stalled,
    this.height = 48,
    super.key,
  });

  final int frameCount;
  final int stalledFrom;
  final int stalledTo;
  final bool stalled;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          key: const ValueKey('frame-strip-painter'),
          size: Size.infinite,
          painter: FrameStripPainter(
            frameCount: frameCount,
            stalledFrom: stalledFrom,
            stalledTo: stalledTo,
            stalled: stalled,
          ),
        ),
      );
}

/// Tick geometry, in logical pixels. Ticks are thin vertical bars with a
/// small gap between them, evenly filling whatever width the painter is
/// given.
const _tickWidthFraction = 0.6;

/// Paints [FrameStrip]'s ticks and exposes [colorAt] publicly (the same
/// pattern [ArrowPainter] in `annotate.dart` uses) so a test can assert on
/// per-tick colour without inspecting canvas draw calls.
class FrameStripPainter extends CustomPainter {
  const FrameStripPainter({
    required this.frameCount,
    required this.stalledFrom,
    required this.stalledTo,
    required this.stalled,
  });

  final int frameCount;
  final int stalledFrom;
  final int stalledTo;
  final bool stalled;

  /// The colour tick [index] renders in: red only while [stalled] is true
  /// and [index] falls inside `[stalledFrom, stalledTo)`; green otherwise.
  Color colorAt(int index) =>
      stalled && index >= stalledFrom && index < stalledTo
          ? Palette.red
          : Palette.green;

  @override
  void paint(Canvas canvas, Size size) {
    if (frameCount <= 0) return;
    final pitch = size.width / frameCount;
    final tickWidth = pitch * _tickWidthFraction;
    for (var i = 0; i < frameCount; i++) {
      final left = i * pitch + (pitch - tickWidth) / 2;
      final rect = Rect.fromLTWH(left, 0, tickWidth, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = colorAt(i),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FrameStripPainter oldDelegate) =>
      frameCount != oldDelegate.frameCount ||
      stalledFrom != oldDelegate.stalledFrom ||
      stalledTo != oldDelegate.stalledTo ||
      stalled != oldDelegate.stalled;
}
