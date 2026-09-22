import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_reveal.dart';

const _json = '''
{
  "id": "bank",
  "title": "Bank Account",
  "descriptions": [
    {
      "type": "ERROR",
      "value": "Under maintenance",
      "attributes": { "color_token": "error" }
    }
  ],
  "enabled": false,
  "cta": {
    "type": "DEEP_LINK",
    "value": {
      "android": "app://payment/card",
      "ios": "app://payment/card",
      "web": "https://example.com/payment/card"
    }
  }
}''';

const _binding = '''
'error' => Palette.red
enabled: false => Opacity + ignore taps
value[platform] => launchUrl(...)''';

/// Slide 42 — `/bff-row-error` (4 steps, A36c). The disabled case, plus the
/// per-platform action map — the row the client never had to special-case.
class BffRowErrorBody extends StatelessWidget {
  const BffRowErrorBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => BffRevealBody(
    step: step,
    regionId: 'row-bank',
    anchorY: 258,
    json: _json,
    binding: _binding,
    accent: bffError,
    caption: 'Design wants a new state. Who ships?',
  );
}
