import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/sequence_diagram.dart';

/// Kept deliberately short: `flutter test` does not load the deck's bundled
/// fonts, so `CodePanel` measures every line against a wide fallback
/// monospace face — a realistic, longer interceptor reliably wrapped and
/// blew the slide's height budget even though it renders fine with the real
/// font. Short identifiers keep every line under the fallback face's wrap
/// width at [_codeWidth] in both the test harness and on stage.
const _interceptorCode = r'''
onError(e, h) async {
  if (e.code != 401) return h.next(e);
  final t = await refresh();
  e.setAuth(t);
  await retry(e);
  h.resolve();
}''';

/// 0-indexed line ranges per step, walked one at a time — see
/// `FlutterDeckCodeHighlight.highlightedLines`. Mirrors [_hops] below:
/// detect 401 -> call refresh -> update header -> retry.
const _detectLines = [1];
const _refreshLines = [2];
const _updateHeaderLines = [3];
const _retryLines = [4, 5];

final _miniLanes = [
  SequenceLane(id: 'app', label: 'App'),
  SequenceLane(id: 'auth', label: 'Auth Server'),
  SequenceLane(id: 'api', label: 'API'),
];

/// The same four-step shape as the code beside it — slide 13's diagram,
/// zoomed to just the hops this interceptor triggers.
final _hops = [
  SequenceHop(
    from: 'app',
    to: 'api',
    label: '401',
    atStep: 1,
    color: Palette.red,
  ),
  SequenceHop(from: 'app', to: 'auth', label: 'refresh()', atStep: 2),
  SequenceHop(from: 'auth', to: 'app', label: 'new token', atStep: 3),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'retry',
    atStep: 4,
    color: Palette.green,
    replay: true,
  ),
];

const _codeWidth = 880.0;
const _miniDiagramWidth = 300.0;

final _rows = [
  CorrelationRow(platform: 'Android', concept: 'OkHttp Authenticator'),
  CorrelationRow(platform: 'iOS', concept: 'URLSession delegate'),
  CorrelationRow(platform: 'Java / Spring', concept: 'Spring filter'),
  CorrelationRow(platform: 'Go', concept: 'Go RoundTripper'),
];

/// Slide 14 — `/auth-interceptor` (4 steps, A12). The code that automates
/// slide 13's steps 7-9: a Dio `onError` interceptor that catches a 401,
/// refreshes, and retries — silently, exactly like the diagram showed.
class AuthInterceptorBody extends StatelessWidget {
  const AuthInterceptorBody({required this.step, super.key});

  final int step;

  List<int> get _highlightedLines => switch (step) {
    1 => _detectLines,
    2 => _refreshLines,
    3 => _updateHeaderLines,
    _ => _retryLines,
  };

  @override
  Widget build(BuildContext context) => Center(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.all(Tokens.gapMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: _codeWidth,
                  child: CodePanel(
                    code: _interceptorCode,
                    fileName: 'auth_interceptor.dart',
                    highlightedLines: _highlightedLines,
                  ),
                ),
                const SizedBox(width: Tokens.gapSm),
                SequenceDiagram(
                  lanes: _miniLanes,
                  hops: _hops,
                  width: _miniDiagramWidth,
                ),
              ],
            ),
            const SizedBox(height: Tokens.gapSm),
            // Width stated explicitly, matching the Row above.
            // CorrelationPanel uses Expanded internally, which needs a
            // bounded width — and the FittedBox that keeps this slide
            // inside a 720p viewport hands its child unbounded
            // constraints. Letting it inherit the Column's width worked
            // only while nothing above it was unbounded.
            SizedBox(
              width: _codeWidth + Tokens.gapSm + _miniDiagramWidth,
              child: CorrelationPanel(
                flutterLabel: 'Dio Interceptor',
                firstStep: 4,
                stepsPerRow: 0,
                rows: _rows,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
