import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';

const _switchCode = '''
sealed class ApiResult {}

switch (result) {
  case Loading():
    return Spinner();
  case ApiError(:final message):
    return ErrorView(message);
  case Data(:final photos):
    return PhotoGrid(photos);
}''';

/// 0-indexed line ranges per branch, walked one step at a time — see
/// `FlutterDeckCodeHighlight.highlightedLines`.
const _loadingLines = [3, 4];
const _errorLines = [5, 6];
const _dataLines = [7, 8];

/// Slide 12 — `/three-states-code` (3 steps). The `switch` over a sealed
/// result type that slide 10's demo runs for real; `highlightedLines` walks
/// loading → error → data, one branch per step.
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
                'One result. Three branches.',
                style: TextStyle(color: pal.textPrimary, fontSize: 29),
              ),
              SizedBox(height: Tokens.gapMd),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 560),
                child: CodePanel(
                  code: _switchCode,
                  fileName: 'photo_view.dart',
                  highlightedLines: _highlightedLines,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
