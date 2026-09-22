import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_reveal.dart';

const _json = '''
{
  "id": "wallet",
  "title": "Wallet",
  "descriptions": [
    { "type": "DEFAULT", "value": "Balance: 500.000" }
  ],
  "cta": { "type": "radio_button", "value": "true" },
  "enabled": true
}''';

const _binding = '''
// cta.type decides the widget, not the row's identity
RowCta.radio => const Icon(Icons.radio_button_unchecked)''';

/// Slide 40 — `/bff-row-plain` (4 steps, A36a). The ordinary case, so the
/// two that follow read as the same machinery with different data.
class BffRowPlainBody extends StatelessWidget {
  const BffRowPlainBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => BffRevealBody(
    step: step,
    regionId: 'row-wallet',
    anchorY: 118,
    json: _json,
    binding: _binding,
    accent: bffNormal,
    caption: 'The server named the control. The client just rendered it.',
  );
}
