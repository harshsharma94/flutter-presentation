import 'package:flutter/widgets.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/step_scope.dart';

/// Reveals [child] at [atStep], dims it once the deck has moved past, and
/// optionally hides it again after [until].
///
/// This is the deck's only animation primitive. Because visibility is derived
/// purely from the ambient step, every animation is presenter-paced and
/// reversible — stepping backward re-hides things correctly with no state.
///
/// `until`'s interaction with dimming has two idioms:
/// - `until` alone: the child dims to [Tokens.dimmed] once the deck moves
///   past [atStep], then hides once the step passes [until].
/// - `until` with `dimWhenPast: false`: the child stays at full opacity for
///   its whole `[atStep, until]` window, then hides.
class StepReveal extends StatelessWidget {
  const StepReveal({
    required this.atStep,
    required this.child,
    this.until,
    this.slideFrom = const Offset(0, 0.04),
    this.dimWhenPast = true,
    super.key,
  });

  final int atStep;
  final int? until;
  final Widget child;
  final Offset slideFrom;
  final bool dimWhenPast;

  @override
  Widget build(BuildContext context) {
    final step = StepScope.of(context);
    final past = until != null && step > until!;
    final arrived = step >= atStep;

    final opacity = !arrived || past
        ? 0.0
        : (dimWhenPast && step > atStep ? Tokens.dimmed : 1.0);

    return AnimatedSlide(
      duration: Tokens.travel,
      curve: Tokens.curve,
      offset: arrived && !past ? Offset.zero : slideFrom,
      child: AnimatedOpacity(
        duration: Tokens.fade,
        curve: Tokens.curve,
        opacity: opacity,
        child: IgnorePointer(ignoring: opacity == 0, child: child),
      ),
    );
  }
}
