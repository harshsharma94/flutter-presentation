import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';

const _rows = [
  CorrelationRow(platform: 'Android', concept: 'Retrofit + OkHttp'),
  CorrelationRow(platform: 'iOS', concept: 'URLSession / Alamofire'),
  CorrelationRow(
      platform: 'Java / Spring', concept: 'RestTemplate / WebClient'),
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
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The HTTP client you already have.',
                style: TextStyle(color: Palette.textPrimary, fontSize: 34),
              ),
              const SizedBox(height: Tokens.gapLg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: const CorrelationPanel(flutterLabel: 'Dio', rows: _rows),
              ),
            ],
          ),
        ),
      );
}
