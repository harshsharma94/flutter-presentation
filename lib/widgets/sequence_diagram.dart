/// A reusable step-driven sequence diagram: fixed vertical "lanes" (actors)
/// and a stack of horizontal "hops" (messages) between them, one per row.
///
/// Built for slide 14's eight-step login-and-refresh flow (`/oauth-flow`)
/// and reused, shrunk to a footnote, on slide 15 — getting the lane/row
/// geometry right once is worth it. Every hop is gated by [StepReveal], so the whole diagram is
/// presenter-paced and reverses cleanly like every other primitive in this
/// deck: no [AnimationController], no timer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// One vertical actor lane — e.g. `App`, `Browser`, `Auth Server`, `API`.
class SequenceLane {
  SequenceLane({required this.id, required this.label});

  /// Stable id [SequenceHop.from]/[SequenceHop.to] refer to. Not shown.
  final String id;
  final String label;
}

/// One message between two lanes, revealed at [atStep].
///
/// When [from] equals [to] the hop is a same-lane event — something an
/// actor does to itself, with nothing crossing — and renders as a small
/// badge rather than an arrow. No linked slide uses one today: the login
/// flow that once had `user logs in` happening inside a browser lane now
/// has no browser lane at all.
///
/// [replay] marks a hop that redraws an *earlier* hop's exact line — slide
/// 14 step 8's successful retry redraws step 7's failed request in green.
/// A replay hop shares its row with the most recent earlier hop that has
/// the same [from]/[to] pair, so it lands on the same line rather than
/// opening a new one.
class SequenceHop {
  SequenceHop({
    required this.from,
    required this.to,
    required this.label,
    required this.atStep,
    this.color,
    this.replay = false,
  });

  final String from;
  final String to;
  final String label;
  final int atStep;

  /// Defaults to [pal.textSecondary] — ordinary connective annotation.
  /// Pass [Palette.red] / [Palette.green] only for an actual error or a
  /// replayed success, per the deck's semantic palette.
  final Color? color;
  final bool replay;
}

/// Lays [lanes] out as evenly spaced columns and stacks [hops] one per row,
/// each drawn with [AnimatedArrow] (or, for a same-lane hop, a small badge)
/// once the ambient step reaches [SequenceHop.atStep]. Earlier hops dim to
/// [Tokens.dimmed] automatically — that is [StepReveal]'s default
/// `dimWhenPast` behaviour, not bespoke logic — so the current hop always
/// reads as the one in motion.
class SequenceDiagram extends StatelessWidget {
  const SequenceDiagram({
    required this.lanes,
    required this.hops,
    this.width = 860,
    super.key,
  });

  final List<SequenceLane> lanes;
  final List<SequenceHop> hops;
  final double width;

  /// Height of the lane-header row at the top of the diagram.
  static const laneHeaderHeight = 34.0;

  /// Vertical space each hop row occupies. Exposed so a caller that needs
  /// to align extra content (slide 14's token pills) with a specific hop
  /// can compute that row's y-offset the same way this widget does.
  static const rowHeight = 36.0;

  static const _laneBoxHeight = 26.0;

  /// Wide enough for a two-word actor name — `In-app tab` used to
  /// ellipsis at the old 120.
  static const _laneLabelWidth = 170.0;
  static const _labelBoxWidth = 220.0;
  static const _arrowLaneY = 22.0;
  static const _arrowLaneHeight = 14.0;

  /// The row index of every hop, in list order — except a [SequenceHop.replay]
  /// hop, which reuses the row of the most recent earlier hop sharing its
  /// from/to pair (see [SequenceHop.replay]).
  List<int> get _rows {
    final rows = <int>[];
    var next = 0;
    for (var i = 0; i < hops.length; i++) {
      final hop = hops[i];
      var reused = -1;
      if (hop.replay) {
        for (var j = i - 1; j >= 0; j--) {
          if (hops[j].from == hop.from && hops[j].to == hop.to) {
            reused = rows[j];
            break;
          }
        }
      }
      rows.add(reused >= 0 ? reused : next++);
    }
    return rows;
  }

  int get _rowCount =>
      hops.isEmpty ? 0 : _rows.reduce((a, b) => a > b ? a : b) + 1;

  /// Total pixel height this diagram renders at, for a caller sizing its
  /// own layout around it (e.g. a [SizedBox] ancestor).
  double get height => laneHeaderHeight + rowHeight * _rowCount;

  double _laneCenterX(int index) => width * (index + 0.5) / lanes.length;

  int _laneIndex(String id) => lanes.indexWhere((lane) => lane.id == id);

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final rows = _rows;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Faint static lifelines — always present, purely structural, not
          // information that needs step-gating.
          for (var i = 0; i < lanes.length; i++)
            Positioned(
              left: _laneCenterX(i),
              top: laneHeaderHeight,
              bottom: 0,
              child: Container(
                width: 1,
                color: pal.textSecondary.withValues(alpha: 0.15),
              ),
            ),
          for (var i = 0; i < lanes.length; i++)
            Positioned(
              left: _laneCenterX(i) - _laneLabelWidth / 2,
              top: 0,
              width: _laneLabelWidth,
              height: _laneBoxHeight,
              child: _LaneHeader(label: lanes[i].label),
            ),
          for (var i = 0; i < hops.length; i++)
            _HopRow(
              hop: hops[i],
              rowTop: laneHeaderHeight + rows[i] * rowHeight,
              fromX: _laneCenterX(_laneIndex(hops[i].from)),
              toX: _laneCenterX(_laneIndex(hops[i].to)),
              labelBoxWidth: _labelBoxWidth,
              arrowLaneY: _arrowLaneY,
              arrowLaneHeight: _arrowLaneHeight,
            ),
        ],
      ),
    );
  }
}

class _LaneHeader extends StatelessWidget {
  const _LaneHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: Tokens.gapXs),
      decoration: BoxDecoration(
        border: Border.all(color: pal.textSecondary, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: pal.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// One hop's full row: either a crossing arrow with a label above it, or —
/// for a same-lane hop — a small badge. Wrapped in [StepReveal] so it slides
/// and fades in at [SequenceHop.atStep] and dims once the deck moves past it.
class _HopRow extends StatelessWidget {
  const _HopRow({
    required this.hop,
    required this.rowTop,
    required this.fromX,
    required this.toX,
    required this.labelBoxWidth,
    required this.arrowLaneY,
    required this.arrowLaneHeight,
  });

  final SequenceHop hop;
  final double rowTop;
  final double fromX;
  final double toX;
  final double labelBoxWidth;
  final double arrowLaneY;
  final double arrowLaneHeight;

  bool get _isSelf => hop.from == hop.to;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final color = hop.color ?? pal.textSecondary;

    return Positioned(
      left: 0,
      right: 0,
      top: rowTop,
      height: SequenceDiagram.rowHeight,
      child: StepReveal(
        atStep: hop.atStep,
        child: Stack(
          clipBehavior: Clip.none,
          children: _isSelf
              ? [_SelfBadge(x: fromX, label: hop.label, color: color)]
              : [
                  // A replay redraws a line that already carries a label, so
                  // it draws no second one — two labels centred on the same
                  // row rendered on top of each other and both became
                  // unreadable. The green arrow over the red one is the
                  // message; the hop's own label survives in the diff.
                  if (!hop.replay)
                    Positioned(
                      left: ((fromX + toX) / 2 - labelBoxWidth / 2).clamp(
                        0.0,
                        double.infinity,
                      ),
                      top: 0,
                      width: labelBoxWidth,
                      child: Text(
                        hop.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: arrowLaneY,
                    height: arrowLaneHeight,
                    child: AnimatedArrow(
                      from: Offset(fromX, arrowLaneHeight / 2),
                      to: Offset(toX, arrowLaneHeight / 2),
                      atStep: hop.atStep,
                      color: color,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

/// A same-lane hop's badge: an actor acting on itself, with nothing
/// crossing between lanes.
/// Returns a [Positioned] directly, so it must sit inside a [Stack] — see
/// its use in [_HopRow.build].
class _SelfBadge extends StatelessWidget {
  const _SelfBadge({required this.x, required this.label, required this.color});

  final double x;
  final String label;
  final Color color;

  static const _width = 140.0;

  @override
  Widget build(BuildContext context) => Positioned(
    left: x - _width / 2,
    top: 0,
    width: _width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: color, size: 18),
        SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 15),
        ),
      ],
    ),
  );
}

/// One token, rendered as a pill whose *width* — not a caption — carries its
/// lifetime: a short-lived access token draws narrow, a long-lived refresh
/// token draws wide. [expired] collapses it toward zero width and greys it,
/// for slide 14 step 6's silent, unattended expiry.
class TokenPill extends StatelessWidget {
  const TokenPill({
    required this.label,
    required this.widthFactor,
    required this.color,
    required this.expired,
    super.key,
  });

  final String label;

  /// Fraction (0-1) of [_maxWidth] this pill draws at while not [expired].
  final double widthFactor;
  final Color color;
  final bool expired;

  static const _maxWidth = 170.0;
  static const _minWidth = 20.0;
  static const _height = 30.0;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final displayColor = expired ? pal.textSecondary : color;
    final displayWidth = expired
        ? _minWidth
        : (_maxWidth * widthFactor).clamp(_minWidth, _maxWidth);

    return AnimatedContainer(
      duration: Tokens.travel,
      curve: Tokens.curve,
      width: displayWidth,
      height: _height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: expired ? 0.12 : 0.15),
        border: Border.all(color: displayColor, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(_height / 2),
      ),
      child: AnimatedOpacity(
        duration: Tokens.fade,
        curve: Tokens.curve,
        opacity: expired ? 0.0 : 1.0,
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: displayColor,
            fontSize: 17,
            fontFamily: 'JetBrainsMono',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
