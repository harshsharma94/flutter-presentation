import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the phone, the API icon and the request's round trip are laid
/// out against — the same fixed-canvas-plus-`Positioned` convention as
/// `api_gap_slide.dart`, which this slide deliberately echoes: same phone,
/// same lane, same "nothing bridges them yet" shape, now with a credential
/// as the missing piece instead of a client.
const _canvasWidth = 760.0;
const _canvasHeight = 260.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _phoneWidth = 150.0;
const _phoneHeight = _phoneWidth * 19.5 / 9;
const _phoneTop = 10.0;
const _laneY = _phoneTop + _phoneHeight / 2;

const _serverSize = 100.0;
const _serverLeft = _canvasWidth - _serverSize;
const _serverTop = _laneY - _serverSize / 2;

/// Outbound and return traffic ride separate lanes, the way a sequence
/// diagram reads. Drawing both on one lane stacked two opposing arrowheads
/// on the same pixels, which read as a single confused line.
const _outboundY = _laneY - 24;
const _returnY = _laneY + 24;

/// Where the request leaves the phone and where it meets the server. The
/// request *does* reach the server — a 401 is the server's answer, not a
/// wall the request never gets to. Stopping the arrow short would teach the
/// wrong mental model.
const _phoneEdgeX = _phoneWidth + 8;
const _serverEdgeX = _serverLeft - 8;

/// Where the rejection stamp sits: at the server, because the server is what
/// rejected it.
const _stampX = _serverLeft - 70;

/// Slide 14 — `/auth-401` (3 steps, A10). Opens §2 Auth: a request with no
/// credential bounces off the API stamped 401; a key is what gets it
/// through. The key is deliberately unexplained here — slide 15 is the
/// whole mechanism behind getting one and keeping it valid.
class Auth401Body extends StatelessWidget {
  const Auth401Body({required this.step, super.key});

  final int step;

  bool get _granted => step >= 3;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.fromSize(
                size: _canvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: _phoneTop,
                      child: PhoneFrame(
                        width: _phoneWidth,
                        child: _PhoneScreen(granted: _granted),
                      ),
                    ),
                    Positioned(
                      left: _serverLeft,
                      top: _serverTop,
                      child: Icon(
                        Icons.dns_outlined,
                        size: _serverSize,
                        color: _granted ? Palette.blue : Palette.textSecondary,
                      ),
                    ),
                    // Step 1: the request reaches the server, carrying no
                    // credential.
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 1,
                        until: 2,
                        dimWhenPast: false,
                        child: const AnimatedArrow(
                          from: Offset(_phoneEdgeX, _outboundY),
                          to: Offset(_serverEdgeX, _outboundY),
                          atStep: 1,
                          dashed: true,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _phoneEdgeX + 12,
                      top: _outboundY - 30,
                      child: const StepReveal(
                        atStep: 1,
                        until: 2,
                        dimWhenPast: false,
                        child: _LaneLabel(
                          text: 'GET /photos   (no Authorization header)',
                          color: Palette.textSecondary,
                        ),
                      ),
                    ),
                    // Step 2: the server rejects it and says so.
                    Positioned(
                      left: _stampX,
                      top: _laneY - 14,
                      child: const StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: _ErrorPulse(),
                      ),
                    ),
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: const AnimatedArrow(
                          from: Offset(_serverEdgeX, _returnY),
                          to: Offset(_phoneEdgeX, _returnY),
                          atStep: 2,
                          color: Palette.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _phoneEdgeX + 12,
                      top: _returnY + 12,
                      child: const StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: _StampBadge(),
                      ),
                    ),
                    // Step 3: a key attaches, and the request passes clean.
                    Positioned(
                      left: _phoneEdgeX + 12,
                      top: _outboundY - 34,
                      child: const StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: _LaneLabel(
                          text: 'Authorization: Client-ID …',
                          color: Palette.blue,
                          icon: Icons.vpn_key,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: const Offset(_phoneEdgeX, _outboundY),
                        to: const Offset(_serverEdgeX, _outboundY),
                        atStep: 3,
                        color: Palette.blue,
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: const Offset(_serverEdgeX, _returnY),
                        to: const Offset(_phoneEdgeX, _returnY),
                        atStep: 3,
                        color: Palette.green,
                      ),
                    ),
                    Positioned(
                      left: _phoneEdgeX + 12,
                      top: _returnY + 12,
                      child: const StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: _LaneLabel(text: '200 OK', color: Palette.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

/// The phone's screen: blank while the request keeps bouncing, a check once
/// [granted] — a plain `AnimatedContainer`/`AnimatedOpacity` cross-fade, no
/// [AnimationController], matching every other slide's transient state.
class _PhoneScreen extends StatelessWidget {
  const _PhoneScreen({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: Tokens.travel,
        curve: Tokens.curve,
        color: granted ? Palette.blue.withValues(alpha: 0.12) : Palette.surface,
        child: Center(
          child: AnimatedOpacity(
            duration: Tokens.fade,
            curve: Tokens.curve,
            opacity: granted ? 1.0 : 0.0,
            child:
                const Icon(Icons.check_circle, color: Palette.blue, size: 26),
          ),
        ),
      );
}

/// A small red "401" badge, styled like `Callout` but built locally: this
/// slide clears it fully at step 3 (`until: 2`, applied by the caller), and
/// `Callout` has no `until` parameter to route that through.
class _StampBadge extends StatelessWidget {
  const _StampBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Tokens.gapSm, vertical: Tokens.gapXs),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.red, width: Tokens.strokeWidth),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: const Text(
          '401',
          style: TextStyle(
              color: Palette.red, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      );
}

/// A small "×" that scales in once, matching `api_gap_slide.dart`'s
/// `_ErrorPulse` — duplicated locally rather than shared, since both are
/// file-private and neither is otherwise reused.
class _ErrorPulse extends StatelessWidget {
  const _ErrorPulse();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1.0),
        duration: Tokens.fade,
        curve: Tokens.curve,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: const Icon(Icons.close, color: Palette.red, size: 28),
      );
}

/// A small label riding beside a traffic lane, so each arrow says what it
/// carries instead of relying on colour alone.
class _LaneLabel extends StatelessWidget {
  const _LaneLabel({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      );
}
