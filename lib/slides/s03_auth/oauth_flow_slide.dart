import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/sequence_diagram.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Public (not file-private) because `/unsplash-reality` reuses this exact
/// configuration for its "the whole flow, shrunk" beat — the point there only
/// lands if it is visibly the same diagram, not a redrawn approximation of it.
///
/// Three lanes, no browser. A real mobile login has a fourth actor — a system
/// browser tab the app cannot read — and that is genuinely how OAuth works on
/// a phone, but it is a second unfamiliar idea stacked on the one this slide
/// is actually for. The lesson here is the *token lifecycle*: prove who you
/// are once, get a short-lived credential and a long-lived one, and never ask
/// the user again. A phone-and-OTP login carries that whole shape with
/// nothing to explain.
final oauthLanes = [
  SequenceLane(id: 'app', label: 'Your app'),
  SequenceLane(id: 'auth', label: 'Auth Server'),
  SequenceLane(id: 'api', label: 'API'),
];

/// The eight steps of A11, in order. Step 6 has no entry here — it is a pure
/// state change on the access [TokenPill] plus a [Callout], not a hop — and
/// step 8 carries two: the refresh call, then the replay of step 7's failed
/// request (sharing its row; see [SequenceHop.replay]). See [oauthLanes] for
/// why this is public.
final oauthHops = [
  SequenceHop(from: 'app', to: 'auth', label: 'phone number', atStep: 1),
  SequenceHop(from: 'auth', to: 'app', label: 'OTP sent', atStep: 2),
  SequenceHop(from: 'app', to: 'auth', label: 'phone + OTP', atStep: 3),
  SequenceHop(from: 'auth', to: 'app', label: 'tokens issued', atStep: 4),
  SequenceHop(from: 'app', to: 'api', label: 'GET /photos', atStep: 5),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos -> 401',
    atStep: 7,
    color: Palette.red,
  ),
  SequenceHop(from: 'app', to: 'auth', label: 'refresh', atStep: 8),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos',
    atStep: 8,
    color: Palette.green,
    replay: true,
  ),
];

const _diagramWidth = 820.0;
const _tokenColumnWidth = 190.0;

/// The "tokens issued" hop (index 3) is the fourth row (0-indexed row 3) —
/// see `SequenceDiagram._rows`. The token column aligns its pills to that
/// row's vertical centre so they read as the payload of that specific hop
/// rather than floating detached beside the diagram.
const _tokenRowCenter =
    SequenceDiagram.laneHeaderHeight +
    3 * SequenceDiagram.rowHeight +
    SequenceDiagram.rowHeight / 2;
const _tokenColumnTop = _tokenRowCenter - 32;

/// Slide 14 — `/oauth-flow` (8 steps, A11) ⭐⭐. The deck's longest
/// animation: one login, and then the hour afterwards.
///
/// Step 6 is the one the slide exists for — no hop, no interaction, just an
/// hour passing and the access token quietly expiring while nobody notices.
/// Step 8 replays step 7's failed request in green, proving the silent
/// refresh actually worked, and that is the whole argument: the user logged
/// in once, this morning, and has not been asked since.
///
/// Deliberately *not* on this slide: the browser hop, PKCE, and the client
/// secret a shipped app must not hold. All three are real and all three are
/// the wrong lesson for a room meeting refresh tokens for the first time —
/// see [oauthLanes].
class OauthFlowBody extends StatelessWidget {
  const OauthFlowBody({required this.step, super.key});

  final int step;

  bool get _accessExpired => step == 6 || step == 7;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Tokens.gapLg,
            vertical: Tokens.gapMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SequenceDiagram(
                    lanes: oauthLanes,
                    hops: oauthHops,
                    width: _diagramWidth,
                  ),
                  const SizedBox(width: Tokens.gapLg),
                  SizedBox(
                    width: _tokenColumnWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: _tokenColumnTop),
                      child: StepReveal(
                        atStep: 4,
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
                            TokenPill(
                              key: ValueKey('pill-refresh'),
                              label: 'eyJhbG...',
                              widthFactor: 0.9,
                              color: Palette.green,
                              expired: false,
                            ),
                            const SizedBox(height: Tokens.gapMd),
                            const Callout(atStep: 6, text: '1 hour later.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Tokens.gapMd),
              SizedBox(
                width: _diagramWidth,
                child: StepReveal(
                  atStep: 8,
                  dimWhenPast: false,
                  child: Text(
                    'Same request, redrawn in green. New token, no login '
                    'screen, and the user never knew any of this happened.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Palette.green,
                      fontSize: 19,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Tokens.gapSm),
              SizedBox(
                width: _diagramWidth,
                child: StepReveal(
                  atStep: 4,
                  until: 7,
                  dimWhenPast: false,
                  child: Text(
                    'Two tokens, two jobs. The short one proves who you are '
                    'on every request. The long one buys a new short one, '
                    'quietly, so nobody is ever asked to log in twice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pal.textSecondary,
                      fontSize: 18,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
