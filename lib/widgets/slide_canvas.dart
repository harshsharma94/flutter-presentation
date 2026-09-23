import 'package:flutter/material.dart';

/// Scales every slide up to fill the projector.
///
/// ## The problem this solves
///
/// Most slides in this deck lay their content out against a fixed canvas —
/// 980 by 220 for the async diagram, 760 by 660 for the widget tree — and then
/// wrap it in `FittedBox(fit: BoxFit.scaleDown)`. `scaleDown` only ever
/// shrinks: if the content already fits, it renders at its natural size. On a
/// 1920-wide projector a 980-wide diagram therefore used a little over half
/// the width and sat in a wide empty margin, which is exactly the content the
/// back row cannot read.
///
/// [SlideCanvas] wraps every slide once, in [DeckSlide], with `BoxFit.contain`
/// — which scales **up** as well as down. In practice that is a 1.2x to 1.5x
/// enlargement of everything: type, strokes, arrowheads, code, the lot, in
/// proportion, with no per-slide retuning and nothing re-laid-out.
///
/// ## Why a design floor rather than a plain fit
///
/// A bare `BoxFit.contain` would scale each slide by whatever its own content
/// happened to need, so a sparse slide would come out with enormous type and a
/// dense one with small type — the deck's apparent font size would lurch from
/// slide to slide. [_designWidth] and [_designHeight] give every slide the same
/// minimum canvas, so a slide smaller than the floor is scaled as if it were
/// exactly the floor. The result is one consistent scale across the deck, and
/// one number to turn if it needs to be bigger still.
///
/// ## Why the width is bounded and the height is not
///
/// A `FittedBox` hands its child unbounded constraints in both axes, and
/// several widgets here need a bounded width — `CorrelationPanel` and
/// `LayerSlab` use `Expanded` and `width: double.infinity` internally. The
/// [SizedBox] therefore fixes the width at the design width and leaves the
/// height free, which is the axis slides actually vary in.
///
/// The per-slide `FittedBox(scaleDown)` calls are left in place. Inside this
/// one they are no-ops — a `FittedBox` whose own constraints are unbounded
/// sizes itself to its child, so `scaleDown` resolves to a scale of 1 — but
/// they still do their original job in `slides_smoke_test.dart`, which pumps
/// slide bodies directly at 1280x720 with no canvas around them. That test
/// stays the strict gate it was.
class SlideCanvas extends StatelessWidget {
  const SlideCanvas({required this.child, super.key});

  final Widget child;

  /// The canvas every slide is laid out against and scaled from. Wider than
  /// the widest slide's natural content (1180, `/row-contract`) so nothing is
  /// squeezed, and 16:9-ish so the scale is width- and height-limited at about
  /// the same point.
  static const _designWidth = 1240.0;
  static const _designHeight = 600.0;

  /// Breathing room at the slide edge, in *scaled* pixels — applied outside
  /// the [FittedBox], so it is not magnified along with the content.
  static const _margin = 24.0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(_margin),
    child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _designWidth,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _designHeight),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
