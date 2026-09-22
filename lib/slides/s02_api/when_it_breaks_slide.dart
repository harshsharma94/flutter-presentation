import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/annotate.dart';

const _failures = [
  (
    platform: 'Android',
    error: 'SocketException: Permission denied (maybe missing INTERNET permission)',
  ),
  (
    platform: 'macOS',
    error: 'SocketException: Operation not permitted, errno = 1 '
        '(missing network.client entitlement)',
  ),
  (
    platform: 'Web',
    error: "blocked by CORS policy: no 'Access-Control-Allow-Origin' header",
  ),
];

/// Slide 14 — `/when-it-breaks` (3 steps). Three platform-specific ways the
/// same request dies before it ever reaches `catch` — a reference card for
/// the moment someone's app hangs mid-workshop, not a lesson to teach cold.
class WhenItBreaksBody extends StatelessWidget {
  const WhenItBreaksBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _failures.length; i++) ...[
                  if (i > 0) const SizedBox(height: Tokens.gapMd),
                  Callout(
                    atStep: i + 1,
                    text: '${_failures[i].platform} — ${_failures[i].error}',
                    color: Palette.red,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
