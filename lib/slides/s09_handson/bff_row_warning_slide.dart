import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_reveal.dart';

const _json = '''
{
  "id": "instalments",
  "title": "Pay Later Instalments",
  "descriptions": [
    {
      "type": "INFO",
      "value": "Limit 500.000",
      "attributes": { "color_token": "warning" }
    }
  ],
  "cta": {
    "type": "info",
    "dialog": {
      "title": "Instalment limit",
      "description": "You have exceeded the limit for this month"
    }
  }
}''';

const _binding = '''
// color_token decides the colour; the client owns no if/else per row
'warning' => Palette.amber
RowCta.info => showDialog(...)''';

/// Slide 44 — `/bff-row-warning` (4 steps, A36b). Same row widget, a
/// different tone and a different trailing action — both chosen by the
/// response.
class BffRowWarningBody extends StatelessWidget {
  const BffRowWarningBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => BffRevealBody(
    step: step,
    regionId: 'row-instalments',
    anchorY: 218,
    json: _json,
    binding: _binding,
    accent: bffInfo,
    caption: 'A new tone shipped without an app release.',
  );
}
