import 'package:flutter/foundation.dart';

/// A real [ChangeNotifier] — not a mock of one. Slide 31's button calls
/// [increment] and the diagram reacts to the notification, so what the
/// audience sees is the actual mechanism, not an illustration of it.
class CounterModel extends ChangeNotifier {
  int _likes = 0;

  int get likes => _likes;

  void increment() {
    _likes++;
    notifyListeners();
  }
}
