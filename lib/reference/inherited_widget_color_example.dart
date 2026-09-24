// The smallest useful InheritedWidget: one colour for the whole app, changed
// from a detail screen, read by every screen. Slides 27 and 28 with nothing
// else in the way. One file on purpose: copy it whole.
//
// Run it on its own:
//   fvm flutter run -d chrome -t lib/reference/inherited_widget_color_example.dart
//
// No packages. Everything here is in the Flutter SDK. This is also exactly
// how Flutter's own Theme works: MaterialApp puts a Theme at the top, and
// Theme.of(context) is the same `of` you will see below.

import 'package:flutter/material.dart';

void main() => runApp(
  // The host goes ABOVE MaterialApp. Screens you push are siblings of `home`
  // under the Navigator, not children of it — so a scope placed inside
  // HomeScreen could not be found from DetailScreen. That is the classic bug
  // with this pattern, and the reason for this order.
  const AppColorHost(child: ColorExampleApp()),
);

/// The colours on offer. Light ones, so the text stays readable on all of them.
const appColors = <String, Color>{
  'White': Colors.white,
  'Mint': Color(0xFFD8F3E4),
  'Sky': Color(0xFFD6E9FB),
  'Peach': Color(0xFFFDE2D2),
};

// ─── 1. The scope ────────────────────────────────────────────────────────────

/// Holds the current colour at the top of the tree, where any screen can ask
/// for it — and a way to change it. This is the whole of slide 27.
///
/// It is a widget, so it is immutable: `color` is `final`. It cannot change
/// its own colour; something above it has to rebuild it with a new one. That
/// is slide 28, and [AppColorHost] below is that something.
class AppColorScope extends InheritedWidget {
  const AppColorScope({
    required this.color,
    required this.onChange,
    required super.child,
    super.key,
  });

  final Color color;
  final ValueChanged<Color> onChange;

  /// How every screen finds the scope. Calling it also *subscribes* the
  /// caller: when the colour changes, every widget that called `of` rebuilds,
  /// and no other widget does.
  static AppColorScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppColorScope>();
    assert(
      scope != null,
      'No AppColorScope above this widget. It has to sit above MaterialApp '
      '— see main().',
    );
    return scope!;
  }

  /// Flutter asks this every time the scope is rebuilt: "do the widgets that
  /// read me need to rebuild too?" Only if the colour actually changed.
  @override
  bool updateShouldNotify(AppColorScope oldWidget) => color != oldWidget.color;
}

// ─── 2. The wrapper you are forced to write ──────────────────────────────────

/// The scope cannot change its own colour, so this StatefulWidget holds it
/// and rebuilds the scope with a new one. Its only job is to call setState.
///
/// Every scope needs one of these — that boilerplate is exactly what
/// ChangeNotifier and Provider remove later (slides 29 and 30).
class AppColorHost extends StatefulWidget {
  const AppColorHost({required this.child, super.key});

  final Widget child;

  @override
  State<AppColorHost> createState() => _AppColorHostState();
}

class _AppColorHostState extends State<AppColorHost> {
  Color _color = Colors.white;

  void _change(Color color) => setState(() => _color = color);

  @override
  Widget build(BuildContext context) =>
      AppColorScope(color: _color, onChange: _change, child: widget.child);
}

// ─── 3. The app ──────────────────────────────────────────────────────────────

class ColorExampleApp extends StatelessWidget {
  const ColorExampleApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    // Reading the scope subscribes this screen. Change the colour anywhere
    // and this background follows — even while another screen is on top.
    backgroundColor: AppColorScope.of(context).color,
    appBar: AppBar(title: const Text('Home')),
    body: Center(
      child: FilledButton(
        // Notice what DetailScreen is NOT given: no colour, no callback.
        // It finds both itself.
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const DetailScreen())),
        child: const Text('Open detail'),
      ),
    ),
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppColorScope.of(context);

    return Scaffold(
      backgroundColor: scope.color,
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pick a background for the whole app, then go back.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                for (final entry in appColors.entries)
                  ChoiceChip(
                    label: Text(entry.key),
                    // This screen is subscribed too, so the tick moves.
                    selected: scope.color == entry.value,
                    onSelected: (_) => scope.onChange(entry.value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
