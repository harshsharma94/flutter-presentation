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

/// Slide 27 — `/inherited-limits` (2 steps, A25). The gap ChangeNotifier
/// exists to fill. Without this slide the next one looks arbitrary.
///
/// Both snippets are on screen at once, statically. See the comment in
/// `build` for why this is not a morphing [CodePanel].
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
              // Two panels side by side rather than one panel morphing from
              // the first into the second. The morph animated a near-total
              // rewrite — every line changed — which read as text scrambling
              // rather than as code changing, and gave the room nothing to
              // compare against once it finished. Side by side, the point
              // ("you had to write all of that to change one list") is
              // visible in a glance and stays visible.
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 620,
                    child: CodePanel(
                      code: _immutable,
                      fileName: 'lib/state/photo_scope.dart',
                    ),
                  ),
                  SizedBox(width: Tokens.gapMd),
                  SizedBox(
                    width: 620,
                    child: StepReveal(
                      atStep: 2,
                      dimWhenPast: false,
                      child: CodePanel(
                        code: _wrapped,
                        fileName: 'lib/state/photo_scope_host.dart',
                      ),
                    ),
                  ),
                ],
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
