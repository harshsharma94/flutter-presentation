import 'package:flutter/widgets.dart';

/// Carries the current slide step down the tree so [StepReveal] and friends
/// do not have to thread it through every constructor.
///
/// Slide bodies provide this; they take `step` as a plain `int`, which is what
/// lets the smoke test pump any slide without a flutter_deck ancestor.
class StepScope extends InheritedWidget {
  const StepScope({required this.step, required super.child, super.key});

  final int step;

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StepScope>();
    if (scope == null) {
      throw FlutterError(
        'StepScope.of() called with a context that has no StepScope ancestor.\n'
        'Slide bodies must wrap their content in StepScope(step: step, ...).',
      );
    }
    return scope.step;
  }

  @override
  bool updateShouldNotify(StepScope oldWidget) => step != oldWidget.step;
}
