import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';

const _bffJson = '''
{
  "title": "Wallet",
  "descriptions": [{ "type": "DEFAULT", "value": "Balance: 500.000" }],
  "cta": { "type": "radio_button" }
}''';

const _bareJson = '''
{ "id": "wallet", "type": "wallet", "balance": 500000 }''';

const _bffClient = '''
switch (row.cta.type) {
  'radio_button' => Radio(...),
  'info'         => InfoButton(...),
  _              => const SizedBox.shrink(),
}''';

const _bareClient = '''
if (row.type == 'wallet') {
  title = 'Wallet';
  subtitle = 'Balance: \${format(row.balance)}';
  trailing = const Radio(...);
} else if (row.type == 'paylater') {
  title = 'Pay Later';
  subtitle = row.dueDate == null ? '' : 'Due on \${row.dueDate}';
  trailing = const Radio(...);
} else if (row.type == 'instalments') {
  // …and the colour rule, and the dialog copy, and…
}''';

/// Slide 43 — `/bff-vs-nonbff` (4 steps, A37). Identical UI, two contracts.
/// The difference is not elegance — it is who has to ship to change a
/// string. *Cut candidate.*
class BffVsNonBffBody extends StatelessWidget {
  const BffVsNonBffBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Tokens.gapMd),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Side(
                  label: 'BFF — the server decides presentation',
                  color: Palette.green,
                  json: _bffJson,
                  client: _bffClient,
                  showClient: step >= 2,
                  lines: 'client rules: 3',
                  showLines: step >= 3,
                ),
                const SizedBox(width: Tokens.gapLg),
                _Side(
                  label: 'Raw resource — the client decides everything',
                  color: Palette.amber,
                  json: _bareJson,
                  client: _bareClient,
                  showClient: step >= 2,
                  lines: step >= 4
                      ? 'client rules: 41 and climbing'
                      : 'client rules: 31',
                  showLines: step >= 3,
                ),
              ],
            ),
            const SizedBox(height: Tokens.gapMd),
            const Callout(
              atStep: 4,
              text:
                  'New payment type — left: nothing to change. '
                  'Right: an app release. Ships in 1 day vs 6 weeks.',
              color: Palette.red,
            ),
          ],
        ),
      ),
    ),
  );
}

class _Side extends StatelessWidget {
  const _Side({
    required this.label,
    required this.color,
    required this.json,
    required this.client,
    required this.showClient,
    required this.lines,
    required this.showLines,
  });

  final String label;
  final Color color;
  final String json;
  final String client;
  final bool showClient;
  final String lines;
  final bool showLines;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 520,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Tokens.gapXs),
        CodePanel(code: json, language: 'json'),
        const SizedBox(height: Tokens.gapSm),
        if (showClient) CodePanel(code: client),
        const SizedBox(height: Tokens.gapXs),
        if (showLines)
          Text(
            lines,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: color,
              fontSize: 20,
            ),
          ),
      ],
    ),
  );
}
