import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

final _rows = [
  CorrelationRow(platform: 'Android', concept: 'Retrofit + OkHttp'),
  CorrelationRow(platform: 'iOS', concept: 'URLSession / Alamofire'),
  CorrelationRow(
    platform: 'Java / Spring',
    concept: 'RestTemplate / WebClient',
  ),
  CorrelationRow(platform: 'Go', concept: 'net/http'),
];

/// Slide 6 — `/http-clients` (4 steps, A5). A correlation slide in its own
/// right (per the task brief) rather than the tail of a diagram slide:
/// [CorrelationPanel]'s default one-row-per-step pacing spends exactly this
/// slide's 4 steps, landing on `Dio` at the last one.
class HttpClientsBody extends StatelessWidget {
  const HttpClientsBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The HTTP client you already have.',
                style: TextStyle(color: pal.textPrimary, fontSize: 34),
              ),
              SizedBox(height: Tokens.gapLg),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 960),
                child: CorrelationPanel(flutterLabel: 'Dio', rows: _rows),
              ),
              SizedBox(height: Tokens.gapLg),
              StepReveal(atStep: 4, dimWhenPast: false, child: _AddDioPanel()),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one command that puts Dio in the project, plus the line it writes.
/// Stated explicitly because "add the dependency" is where a third of the
/// room stalls, and a stalled room cannot follow the next slide.
class _AddDioPanel extends StatelessWidget {
  const _AddDioPanel();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      padding: EdgeInsets.all(Tokens.gapMd),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            r'$ flutter pub add dio',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: Palette.green,
              fontSize: 24,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'pubspec.yaml  →  dependencies:\n                  dio: ^5.8.0',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: pal.textSecondary,
              fontSize: 20,
              height: 1.4,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'Dio 5.x runs on Flutter 3.29.3 (Dart 3.7). No build_runner, no '
            'codegen — it is a plain package.',
            style: TextStyle(color: pal.textSecondary, fontSize: 19),
          ),
        ],
      ),
    );
  }
}
