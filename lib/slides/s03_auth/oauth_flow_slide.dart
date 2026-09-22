import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';
import 'package:gopay_flutter_deck/widgets/annotate.dart';
import 'package:gopay_flutter_deck/widgets/sequence_diagram.dart';
import 'package:gopay_flutter_deck/widgets/step_reveal.dart';

/// Public (not file-private) because slide 18 (`/unsplash-reality`) reuses
/// this exact configuration for its "the whole flow, shrunk" beat — the
/// point there only lands if it is visibly the same diagram, not a redrawn
/// approximation of it.
const oauthLanes = [
  SequenceLane(id: 'app', label: 'App'),
  SequenceLane(id: 'browser', label: 'Browser'),
  SequenceLane(id: 'auth', label: 'Auth Server'),
  SequenceLane(id: 'api', label: 'API'),
];

/// The nine steps of A11, in order. Step 7 has no entry here — it is a pure
/// state change on the access [TokenPill] plus a [Callout], not a hop — and
/// step 9 carries two: the refresh call, then the replay of step 8's failed
/// request (sharing its row; see [SequenceHop.replay]). See [oauthLanes] for
/// why this is public.
const oauthHops = [
  SequenceHop(from: 'app', to: 'browser', label: 'open /authorize', atStep: 1),
  SequenceHop(from: 'browser', to: 'browser', label: 'user logs in', atStep: 2),
  SequenceHop(from: 'auth', to: 'app', label: 'code', atStep: 3),
  SequenceHop(from: 'app', to: 'auth', label: 'exchange code + secret', atStep: 4),
  SequenceHop(from: 'auth', to: 'app', label: 'tokens issued', atStep: 5),
  SequenceHop(from: 'app', to: 'api', label: 'GET /photos', atStep: 6),
  SequenceHop(from: 'app', to: 'api', label: 'GET /photos -> 401', atStep: 8, color: Palette.red),
  SequenceHop(from: 'app', to: 'auth', label: 'refresh', atStep: 9),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos',
    atStep: 9,
    color: Palette.green,
    replay: true,
  ),
];

const _diagramWidth = 820.0;
const _tokenColumnWidth = 190.0;

/// The "tokens issued" hop (index 4) is the fifth row (0-indexed row 4) —
/// see `SequenceDiagram._rows`. The token column aligns its pills to that
/// row's vertical centre so they read as the payload of that specific hop
/// rather than floating detached beside the diagram.
const _tokenRowCenter =
    SequenceDiagram.laneHeaderHeight + 4 * SequenceDiagram.rowHeight + SequenceDiagram.rowHeight / 2;
const _tokenColumnTop = _tokenRowCenter - 32;

/// Slide 16 — `/oauth-flow` (9 steps, A11) ⭐⭐. The deck's longest
/// animation: the full OAuth2 authorization-code round trip, hop by hop,
/// across four lanes. Step 7 is the one the slide exists for — no hop, no
/// interaction, just an hour passing and the access token quietly expiring
/// while nobody notices. Step 9 replays step 8's failed request in green,
/// proving the silent refresh actually worked.
class OauthFlowBody extends StatelessWidget {
  const OauthFlowBody({required this.step, super.key});

  final int step;

  bool get _accessExpired => step == 7 || step == 8;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.gapLg, vertical: Tokens.gapMd),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SequenceDiagram(lanes: oauthLanes, hops: oauthHops, width: _diagramWidth),
              const SizedBox(width: Tokens.gapLg),
              SizedBox(
                width: _tokenColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: _tokenColumnTop),
                  child: StepReveal(
                    atStep: 5,
                    dimWhenPast: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TokenPill(
                          key: const ValueKey('pill-access'),
                          label: 'abc123',
                          widthFactor: 0.35,
                          color: Palette.blue,
                          expired: _accessExpired,
                        ),
                        const SizedBox(height: Tokens.gapXs),
                        const TokenPill(
                          key: ValueKey('pill-refresh'),
                          label: 'eyJhbG...',
                          widthFactor: 0.9,
                          color: Palette.green,
                          expired: false,
                        ),
                        const SizedBox(height: Tokens.gapMd),
                        const Callout(atStep: 7, text: '1 hour later.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
