import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Counts how many times each instrumented widget has actually been rebuilt.
///
/// This is the honesty mechanism behind slide 33: the numbers come from
/// Flutter genuinely calling `build`, not from a script that plays a
/// pre-decided animation.
class RebuildTally extends ChangeNotifier {
  final _counts = <String, int>{};
  var _notifyScheduled = false;

  int countFor(String id) => _counts[id] ?? 0;

  int get total => _counts.values.fold(0, (sum, n) => sum + n);

  void reset() {
    _counts.clear();
    _scheduleNotify();
  }

  /// Called from inside a [RebuildFlash.build]. Mutating a [ChangeNotifier]
  /// during build would throw if it notified synchronously, so the notify is
  /// deferred to after the frame.
  void record(String id) {
    _counts[id] = (_counts[id] ?? 0) + 1;
    _scheduleNotify();
  }

  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (hasListeners) notifyListeners();
    });
  }
}

class RebuildTallyScope extends InheritedWidget {
  const RebuildTallyScope({
    required this.tally,
    required super.child,
    super.key,
  });

  final RebuildTally tally;

  static RebuildTally of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RebuildTallyScope>();
    assert(scope != null, 'RebuildFlash needs a RebuildTallyScope ancestor.');
    return scope!.tally;
  }

  @override
  bool updateShouldNotify(RebuildTallyScope oldWidget) =>
      tally != oldWidget.tally;
}

/// Flashes [Palette.blue] whenever Flutter rebuilds it — the flash is
/// triggered from inside `build`, so it fires if and only if a rebuild
/// genuinely happened.
class RebuildFlash extends StatelessWidget {
  const RebuildFlash({required this.id, required this.child, super.key});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tally = RebuildTallyScope.of(context);
    tally.record(id);
    final count = tally.countFor(id);

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              // Re-keyed on the count so each rebuild restarts the decay
              // rather than resuming a finished one.
              key: ValueKey('$id-$count'),
              tween: Tween(begin: 1.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, t, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: Palette.blue.withValues(alpha: 0.45 * t),
                  borderRadius: BorderRadius.circular(Tokens.radius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
