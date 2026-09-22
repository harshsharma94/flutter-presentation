import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _immutable = '''
class PhotoScope extends InheritedWidget {
  PhotoScope({required this.photos, required super.child});

  final List<Photo> photos;   // final. always final.
}''';

const _wrapped = '''
class _PhotoScopeHostState extends State<PhotoScopeHost> {
  List<Photo> _photos = const [];

  void update(List<Photo> next) => setState(() => _photos = next);

  @override
  Widget build(BuildContext context) =>
      PhotoScope(photos: _photos, child: widget.child);
}''';

/// Slide 31 — `/inherited-limits` (2 steps, A25). The gap ChangeNotifier
/// exists to fill. Without this slide the next one looks arbitrary.
class InheritedLimitsBody extends StatelessWidget {
  const InheritedLimitsBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 760,
                child: CodePanel(
                  code: step >= 2 ? _wrapped : _immutable,
                  fileName: 'lib/state/photo_scope.dart',
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              Callout(
                atStep: 1,
                text: "It's immutable. Something else has to rebuild it.",
                color: Palette.amber,
              ),
              SizedBox(height: Tokens.gapSm),
              StepReveal(
                atStep: 2,
                dimWhenPast: false,
                child: Text(
                  'So you write a StatefulWidget wrapper whose only job is '
                  'to call setState. Every scope needs one.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
