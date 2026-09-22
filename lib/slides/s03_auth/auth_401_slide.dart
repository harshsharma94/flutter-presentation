import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';
import 'package:flutter_bootcamp_deck/widgets/roadmap_spine.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the phone, the API icon and the request's round trip are laid
/// out against — the same fixed-canvas-plus-`Positioned` convention as
/// `api_gap_slide.dart`, which this slide deliberately echoes: same phone,
/// same lane, same "nothing bridges them yet" shape, now with a credential
/// as the missing piece instead of a client.
const _canvasWidth = 760.0;
const _canvasHeight = 260.0;
const _canvasSize = Size(_canvasWidth, _canvasHeight);

const _phoneWidth = 110.0;
const _phoneHeight = _phoneWidth * 19.5 / 9;
const _phoneTop = 10.0;
const _laneY = _phoneTop + _phoneHeight / 2;

const _serverSize = 100.0;
const _serverLeft = _canvasWidth - _serverSize;
const _serverTop = _laneY - _serverSize / 2;

/// Where the failed round trip turns around — the literal wall.
const _gapMidX = (_phoneWidth + _serverLeft) / 2;

/// Slide 15 — `/auth-401` (3 steps, A10). Opens §3 Auth: a request with no
/// credential bounces off the API stamped 401; a key is what gets it
/// through. The key is deliberately unexplained here — slide 16 is the
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
              SizedBox(
                width: _canvasWidth,
                child: Align(
                  alignment: Alignment.topRight,
                  child: RoadmapSpine(activeNode: 1, compact: true),
                ),
              ),
              const SizedBox(height: Tokens.gapSm),
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
                    // Step 1: the request goes out and hits a wall.
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 1,
                        until: 2,
                        dimWhenPast: false,
                        child: const AnimatedArrow(
                          from: Offset(_phoneWidth, _laneY),
                          to: Offset(_gapMidX, _laneY),
                          atStep: 1,
                          dashed: true,
                          color: Palette.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _gapMidX - 14,
                      top: _laneY - 14,
                      child: const StepReveal(
                        atStep: 1,
                        until: 2,
                        dimWhenPast: false,
                        child: _ErrorPulse(),
                      ),
                    ),
                    // Step 2: it bounces back, stamped 401.
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: const AnimatedArrow(
                          from: Offset(_gapMidX, _laneY),
                          to: Offset(_phoneWidth, _laneY),
                          atStep: 2,
                          dashed: true,
                          color: Palette.red,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: _phoneTop + _phoneHeight + Tokens.gapSm,
                      child: const StepReveal(
                        atStep: 2,
                        until: 2,
                        dimWhenPast: false,
                        child: _StampBadge(),
                      ),
                    ),
                    // Step 3: a key attaches, and the request passes clean.
                    Positioned(
                      left: _phoneWidth - 8,
                      top: _laneY - 32,
                      child: const StepReveal(
                        atStep: 3,
                        dimWhenPast: false,
                        child: Icon(Icons.vpn_key, color: Palette.blue, size: 20),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: const Offset(_phoneWidth, _laneY),
                        to: const Offset(_serverLeft, _laneY),
                        atStep: 3,
                        color: Palette.blue,
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
            child: const Icon(Icons.check_circle, color: Palette.blue, size: 26),
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
        padding: const EdgeInsets.symmetric(horizontal: Tokens.gapSm, vertical: Tokens.gapXs),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.red, width: Tokens.strokeWidth),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: const Text(
          '401',
          style: TextStyle(color: Palette.red, fontSize: 16, fontWeight: FontWeight.w700),
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
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: const Icon(Icons.close, color: Palette.red, size: 28),
      );
}
