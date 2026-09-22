import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _stateCode = '''
bool _loading = true;
String? _error;
List<Photo> _photos = [];

Widget build(BuildContext context) {
  if (_loading) return const Spinner();
  if (_error != null) return ErrorView(_error!);
  return PhotoGrid(_photos);
}''';

/// 0-indexed, and each step highlights a *pair*: the field that holds the
/// state and the line in `build` that reads it. Seeing them light up together
/// is the whole point — three fields, three branches, one for one.
const _loadingLines = [0, 5];
const _errorLines = [1, 6];
const _dataLines = [2, 7];

/// Slide 11 — `/three-states-code` (3 steps). The answer to slide 11's empty
/// `catch`: three fields, three branches, none of them silent.
///
/// Deliberately `setState` and nothing else. An earlier version opened with a
/// `sealed class` and a `switch` over it, which is the better pattern and the
/// wrong slide: sealed classes and exhaustive pattern matching are two
/// unfamiliar ideas standing between the room and a screen that handles its
/// error state. This is the version they can type tonight, and it is the same
/// version spelled out in full in `docs/presenter-guide.md`. The sealed shape
/// earns its place later, once there is a reason for it.
///
/// The order of §1 is problem, then fix, then demo: slide 10 shows the empty
/// `catch` stranding somebody, this slide is the code that stops it, and the
/// live three-state demo follows on slide 12. Running the demo first answered
/// a question the room had not been made to ask yet.
///
/// `highlightedLines` walks loading -> error -> data, one branch per step,
/// lighting the field and its `build` line together.
class ThreeStatesCodeBody extends StatelessWidget {
  const ThreeStatesCodeBody({required this.step, super.key});

  final int step;

  List<int> get _highlightedLines => switch (step) {
    1 => _loadingLines,
    2 => _errorLines,
    _ => _dataLines,
  };

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(Tokens.gapMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Three fields. Three branches. None of them silent.',
                style: TextStyle(color: pal.textPrimary, fontSize: 29),
              ),
              SizedBox(height: Tokens.gapMd),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 560),
                child: CodePanel(
                  code: _stateCode,
                  fileName: 'lib/screens/photo_list_screen.dart',
                  highlightedLines: _highlightedLines,
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 3,
                dimWhenPast: false,
                child: SizedBox(
                  width: 620,
                  child: Text(
                    'To see the error branch for real: turn wifi off, or '
                    'point the URL at a host that does not exist. On '
                    'Android an app with no INTERNET permission fails the '
                    'same way; on macOS it is the network entitlement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 19,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
