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
/// The second lane is an **in-app browser tab**, not a browser app and not a
/// `WebView`: on Android a Chrome Custom Tab, on iOS an
/// `ASWebAuthenticationSession`. That distinction is the whole reason mobile
/// OAuth looks the way it does. The tab is a separate process the app cannot
/// read, so the password is never typed into anything the app controls, and
/// the app gets the result back through a redirect it registered rather than
/// by scraping a page.
final oauthLanes = [
  SequenceLane(id: 'app', label: 'Your app'),
  SequenceLane(id: 'tab', label: 'In-app tab'),
  SequenceLane(id: 'auth', label: 'Auth Server'),
  SequenceLane(id: 'api', label: 'API'),
];

/// The ten steps of A11, in order. Step 8 has no entry here — it is a pure
/// state change on the access [TokenPill] plus a [Callout], not a hop — and
/// step 10 carries two: the refresh call, then the replay of step 9's failed
/// request (sharing its row; see [SequenceHop.replay]). See [oauthLanes] for
/// why this is public.
final oauthHops = [
  SequenceHop(
    from: 'app',
    to: 'tab',
    label: 'open /authorize + challenge',
    atStep: 1,
  ),
  SequenceHop(from: 'tab', to: 'auth', label: 'email + password', atStep: 2),
  SequenceHop(
    from: 'auth',
    to: 'tab',
    label: '302 myapp://cb?code=xyz',
    atStep: 3,
  ),
  SequenceHop(
    from: 'tab',
    to: 'app',
    label: 'deep link · tab closes',
    atStep: 4,
  ),
  SequenceHop(
    from: 'app',
    to: 'auth',
    label: 'code + verifier · no secret',
    atStep: 5,
  ),
  SequenceHop(from: 'auth', to: 'app', label: 'tokens issued', atStep: 6),
  SequenceHop(from: 'app', to: 'api', label: 'GET /photos', atStep: 7),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos -> 401',
    atStep: 9,
    color: Palette.red,
  ),
  SequenceHop(from: 'app', to: 'auth', label: 'refresh', atStep: 10),
  SequenceHop(
    from: 'app',
    to: 'api',
    label: 'GET /photos',
    atStep: 10,
    color: Palette.green,
    replay: true,
  ),
];

const _diagramWidth = 820.0;
const _tokenColumnWidth = 190.0;

/// The "tokens issued" hop (index 5) is the sixth row (0-indexed row 5) —
/// see `SequenceDiagram._rows`. The token column aligns its pills to that
/// row's vertical centre so they read as the payload of that specific hop
/// rather than floating detached beside the diagram.
const _tokenRowCenter =
    SequenceDiagram.laneHeaderHeight +
    5 * SequenceDiagram.rowHeight +
    SequenceDiagram.rowHeight / 2;
const _tokenColumnTop = _tokenRowCenter - 32;

/// Slide 14 — `/oauth-flow` (10 steps, A11) ⭐⭐. The deck's longest
/// animation: the full OAuth2 authorization-code round trip **as a phone
/// actually performs it**, hop by hop, across four lanes.
///
/// Two details separate this from the web flow every tutorial draws, and both
/// are on the diagram deliberately:
///
/// - The login happens in an **in-app browser tab** the app cannot read, and
///   the answer comes back as a **deep link** to a redirect URI the app
///   registered. There is no page for the app to scrape and no password for
///   it to see.
/// - The code is exchanged with a **PKCE verifier, not a client secret**. A
///   shipped app is a public client: anything compiled into it can be pulled
///   back out of the binary, so it cannot hold a secret at all. Bootcampers
///   who have only seen the server-side flow will reach for one — this is
///   where to stop them.
///
/// Step 8 is the one the slide exists for — no hop, no interaction, just an
/// hour passing and the access token quietly expiring while nobody notices.
/// Step 10 replays step 9's failed request in green, proving the silent
/// refresh actually worked.
class OauthFlowBody extends StatelessWidget {
  const OauthFlowBody({required this.step, super.key});

  final int step;

  bool get _accessExpired => step == 8 || step == 9;

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
                        atStep: 6,
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
                            const Callout(atStep: 8, text: '1 hour later.'),
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
                  atStep: 1,
                  dimWhenPast: false,
                  child: Text(
                    'The tab is Chrome Custom Tabs on Android and '
                    'ASWebAuthenticationSession on iOS — never a WebView you '
                    'own. Your app never sees the password, and it holds no '
                    'client secret: a shipped binary cannot keep one.',
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
