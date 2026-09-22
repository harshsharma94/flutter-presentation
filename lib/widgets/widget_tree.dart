/// The shared widget tree for §6 (slides 31-38): the same tree, built once,
/// that the audience watches evolve across nine consecutive slides — first
/// drowning in prop-drilled parameters, then shedding them as an
/// `InheritedWidget` arrives, then pulsing with `ChangeNotifier` listeners,
/// then collapsing into `Provider`.
///
/// The visual continuity across those slides is the whole pedagogical
/// device, so [WidgetTreeView] lays nodes out **deterministically from
/// [WidgetTreeView.root]** — a node's position depends only on the tree's
/// shape (depth -> vertical band, index within that depth -> horizontal
/// slot), never on [WidgetTreeView.flashing], [WidgetTreeView.subscribed],
/// [WidgetTreeView.traversalTo] or [WidgetTreeView.showParams]. That
/// computation is [treeNodePositions] — a pure function of `(root, size)`,
/// exported so a slide composing something *outside* the tree (A26's model
/// box, sitting beside the tree it belongs to) can place it and draw
/// connectors that land on the right nodes, sharing this widget's own
/// coordinate space rather than guessing at it.
///
/// Nodes render as [Positioned] boxes inside a [Stack] anchored at those
/// computed points, with parent-child edges painted by a [CustomPainter]
/// layered beneath them — so toggling any flag never moves a node (the
/// position map does not take flags as input at all), and the result still
/// reads as a tree rather than a stack of boxes.
///
/// All motion here is implicit — [AnimatedContainer]/[TweenAnimationBuilder]
/// reacting to changed `flashing`/`subscribed`/`traversalTo` inputs — so
/// there is no `AnimationController` and no timer, and stepping the
/// presentation backward simply re-targets each animation, which reverses
/// it correctly. A24's traversal pulse lights both the ancestor nodes *and*
/// the edges connecting them, timed to land together, so it reads as one
/// movement travelling up the chain rather than a sequence of independent
/// node flashes — see [WidgetTreeView]'s own doc for exactly how.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// One node of the shared tree. Immutable and const-constructible so
/// [demoTree] can be declared once, as a single `const` value, and reused
/// unchanged across all nine slides — nothing about a node ever mutates;
/// which nodes are currently flashing, subscribed or on the traversal path
/// is supplied per-render via [WidgetTreeView]'s own parameters instead.
class TreeNode {
  const TreeNode({
    required this.id,
    required this.label,
    this.children = const [],
    this.params = const [],
    this.flashing = false,
    this.subscribed = false,
  });

  /// Stable identity used to target this node from
  /// [WidgetTreeView.flashing], [WidgetTreeView.subscribed] and
  /// [WidgetTreeView.traversalTo], and as the key into [treeNodePositions]'s
  /// result.
  final String id;

  final String label;
  final List<TreeNode> children;

  /// Parameter names threaded through this node's constructor. A23 shows
  /// these accumulating on middle nodes that never use them ("doesn't care,
  /// still has to carry it"); A24 shows them falling away. Only rendered
  /// when [WidgetTreeView.showParams] is true.
  final List<String> params;

  /// This node's own resting flashing/subscribed state, unioned with
  /// [WidgetTreeView.flashing]/[WidgetTreeView.subscribed] at render time.
  /// [demoTree] leaves both false on every node — a slide changes which
  /// nodes are lit by passing a new set to [WidgetTreeView], not by
  /// mutating the tree.
  final bool flashing;
  final bool subscribed;
}

/// The canonical 5-level tree reused across slides 31-38:
/// `PhotoApp -> HomeScreen -> PhotoGrid -> PhotoTile x2 -> LikeButton`.
///
/// `photos` (and the `onLike` callback threaded back up) is the state A23
/// drags down through `HomeScreen` and `PhotoGrid` even though neither
/// widget uses it directly, and which A24 lets those middle nodes shed.
const demoTree = TreeNode(
  id: 'photo-app',
  label: 'PhotoApp',
  children: [
    TreeNode(
      id: 'home-screen',
      label: 'HomeScreen',
      params: ['photos', 'onLike'],
      children: [
        TreeNode(
          id: 'photo-grid',
          label: 'PhotoGrid',
          params: ['photos', 'onLike'],
          children: [
            TreeNode(
              id: 'tile-1',
              label: 'PhotoTile',
              params: ['photo', 'onLike'],
              children: [
                TreeNode(
                  id: 'like-1',
                  label: 'LikeButton',
                  params: ['liked', 'onTap'],
                ),
              ],
            ),
            TreeNode(
              id: 'tile-2',
              label: 'PhotoTile',
              params: ['photo', 'onLike'],
              children: [
                TreeNode(
                  id: 'like-2',
                  label: 'LikeButton',
                  params: ['liked', 'onTap'],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// The fixed canvas [WidgetTreeView] lays [demoTree] out inside, regardless
/// of whatever ambient constraints a given slide surrounds it with. Fixed
/// rather than derived from `LayoutBuilder` so that a slide composing
/// something outside the tree (A26's model box) can call
/// `treeNodePositions(demoTree, treeCanvasSize)` itself and get coordinates
/// that agree exactly with what [WidgetTreeView] rendered — no risk of the
/// two disagreeing because one read different ambient constraints than the
/// other.
const treeCanvasSize = Size(640, 560);

/// Fixed width for every node box, regardless of [WidgetTreeView.showParams]
/// or how many parameters a node carries — chips wrap inside this width,
/// never widen it.
const _nodeWidth = 148.0;

/// Nominal box height used only to centre [treeNodePositions]' anchor point
/// against a node's *label-only* box — deliberately not the taller height a
/// node reaches once its parameter chips are showing, so a node's anchor
/// (and therefore [Positioned.top]) never moves when
/// [WidgetTreeView.showParams] toggles; the box simply grows downward past
/// it.
const _nodeBaseHeight = 56.0;

const _labelFontSize = 15.0;
const _chipFontSize = 11.0;
const _chipSpacing = 4.0;
const _chipHorizontalPadding = 6.0;
const _chipVerticalPadding = 2.0;
const _chipBorderWidth = 1.0;
const _chipRadius = 6.0;

/// Diameter of the small badge a subscribed leaf shows at its box's corner —
/// a marker that *this* node has a live subscription. It deliberately does
/// not attempt to draw a line to the model box: that box's position is a
/// composition decision for the slide that places it (see [treeNodePositions]
/// doc), not something [WidgetTreeView] can know about its own tree.
const _subscribedDotSize = 10.0;

const _glowBlur = 12.0;
const _glowSpread = 2.0;

/// [Palette.blue] at ~40% alpha, written as a literal ARGB constant (rather
/// than a runtime `.withValues` call) so it stays usable inside a
/// `const [BoxShadow(...)]` list.
const _flashGlowColor = Color(0x66118EEA);

/// Computes every node's centre point in [size], purely from [root]'s shape:
/// depth gives the vertical band (`size.height` split evenly across tree
/// depth), and a node's index among its level's siblings gives the
/// horizontal slot (that level's share of `size.width` split evenly across
/// however many siblings share it). Same `(root, size)` in, same positions
/// out, always — no [WidgetTreeView] flag is a parameter here, so none of
/// them can perturb layout.
///
/// [WidgetTreeView] uses this internally against [treeCanvasSize]; it is
/// exported so a slide can call it with that same size to place something
/// of its own (a model box, a connector) in the tree's coordinate space.
Map<String, Offset> treeNodePositions(TreeNode root, Size size) {
  final levels = _levelsOf(root);
  final rowHeight = size.height / levels.length;
  final positions = <String, Offset>{};
  for (var depth = 0; depth < levels.length; depth++) {
    final level = levels[depth];
    final columnWidth = size.width / level.length;
    final y = (depth + 0.5) * rowHeight;
    for (var index = 0; index < level.length; index++) {
      final x = (index + 0.5) * columnWidth;
      positions[level[index].id] = Offset(x, y);
    }
  }
  return positions;
}

/// Renders [root] inside a [treeCanvasSize] [Stack]: one bordered box per
/// node, [Positioned] at its [treeNodePositions] anchor, with parent-child
/// edges painted beneath them by [TreeEdgePainter]. See the library doc for
/// the determinism guarantee this layout is built around.
///
/// - [flashing] / [subscribed] retarget which node ids are lit or marked for
///   this render, without mutating [root] (see [TreeNode]).
/// - [traversalTo] drives the A24 "reaching up the tree" pulse: every node
///   on the ancestor path from [root] down to that id lights up, each with
///   an [AnimatedContainer] duration that grows with its distance from
///   [traversalTo] — so although every one of them starts animating at the
///   same instant, the node closest to [traversalTo] reaches "lit" first and
///   [root] (furthest away) arrives last, reading as a pulse travelling up
///   the chain node by node with no timer involved. The edges along that
///   same ancestor path light up too — via one `TweenAnimationBuilder`
///   feeding a single 0-to-1 progress value into [TreeEdgePainter] (the
///   same technique `AnimatedArrow` in `annotate.dart` uses to draw itself)
///   — timed so edge `d` (the one leading into the node at distance `d+1`
///   from [traversalTo]) finishes lighting at the same instant that node's
///   own border finishes arriving. Node and edge are meant to read as one
///   continuous movement up the chain, not two independent effects.
/// - [showParams] reveals each node's [TreeNode.params] as small chips.
class WidgetTreeView extends StatelessWidget {
  const WidgetTreeView({
    required this.root,
    this.flashing = const {},
    this.subscribed = const {},
    this.traversalTo,
    this.showParams = false,
    super.key,
  });

  final TreeNode root;
  final Set<String> flashing;
  final Set<String> subscribed;
  final String? traversalTo;
  final bool showParams;

  @override
  Widget build(BuildContext context) {
    final positions = treeNodePositions(root, treeCanvasSize);
    final path = traversalTo == null ? null : _pathTo(root, traversalTo!);
    assert(
      traversalTo == null || path != null,
      'WidgetTreeView.traversalTo "$traversalTo" is not a node in this tree.',
    );
    final pulseDelays = _pulseDelaysFor(path);
    final nodes = _levelsOf(root).expand((level) => level);

    return SizedBox.fromSize(
      size: treeCanvasSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: path == null ? 0.0 : 1.0),
              duration:
                  path == null ? Tokens.fade : Tokens.travel * path.length,
              // Deliberately linear, not Tokens.curve: this progress is a
              // raw elapsed-time fraction that TreeEdgePainter.edgeProgress
              // re-windows per edge and curves *locally* (see its doc).
              // Curving here too would curve twice — once globally, once
              // per edge — which is exactly what desynced edges from node
              // borders in an earlier version of this fix.
              curve: Curves.linear,
              builder: (context, progress, child) => CustomPaint(
                key: const ValueKey('tree-edges'),
                painter: TreeEdgePainter(
                  root: root,
                  positions: positions,
                  pathIds: path ?? const [],
                  progress: progress,
                ),
              ),
            ),
          ),
          for (final node in nodes)
            Positioned(
              left: positions[node.id]!.dx - _nodeWidth / 2,
              top: positions[node.id]!.dy - _nodeBaseHeight / 2,
              child: _NodeBox(
                node: node,
                flashing: node.flashing || flashing.contains(node.id),
                subscribed: node.subscribed || subscribed.contains(node.id),
                pulseDelay: pulseDelays[node.id],
                showParams: showParams,
              ),
            ),
        ],
      ),
    );
  }
}

/// Groups [root] and its descendants into depth levels via BFS, preserving
/// left-to-right sibling order. Purely structural — depends only on
/// [TreeNode.children], never on any [WidgetTreeView] flag.
List<List<TreeNode>> _levelsOf(TreeNode root) {
  final levels = <List<TreeNode>>[];
  var current = [root];
  while (current.isNotEmpty) {
    levels.add(current);
    current = [for (final node in current) ...node.children];
  }
  return levels;
}

/// The ids from [root] down to [targetId], inclusive of both, or `null` if
/// [targetId] is not in the tree.
List<String>? _pathTo(TreeNode node, String targetId) {
  if (node.id == targetId) return [node.id];
  for (final child in node.children) {
    final sub = _pathTo(child, targetId);
    if (sub != null) return [node.id, ...sub];
  }
  return null;
}

/// Maps every node id on [path] (root-to-target order, or `null` when no
/// traversal is active) onto its distance from the target (0 at the target
/// itself, increasing toward the root). See [WidgetTreeView.traversalTo]
/// for how this distance drives the staggered-duration pulse illusion, and
/// [TreeEdgePainter] for how the same distance times the edges.
Map<String, int> _pulseDelaysFor(List<String>? path) {
  if (path == null) return const {};
  return {
    for (var i = 0; i < path.length; i++) path[i]: path.length - 1 - i,
  };
}

/// Paints every parent-child edge of [root] as a straight line between the
/// two nodes' [positions] — laid beneath the node boxes in the [Stack], so
/// the (opaque) boxes visually occlude each line down to touching their own
/// border. This is what makes [WidgetTreeView] read as a tree rather than a
/// stack of independently placed boxes.
///
/// Edges that lie on [pathIds] (the current A24 traversal chain, in
/// root-to-target order — see [WidgetTreeView.traversalTo]) are additionally
/// drawn in [Palette.blue] up to a per-edge fraction from [edgeProgress],
/// growing from the target end toward the root end as [progress] runs 0 to
/// 1 — the same partial-line-reveal technique `ArrowPainter` in
/// `annotate.dart` uses, just applied to one segment of a multi-segment
/// chain instead of a single arrow. Edge `d` (the one arriving at the node
/// `d` steps from the target) starts growing exactly when that node's own
/// [_NodeBox] border finishes its own arrival, and finishes growing exactly
/// when the *next* node's border finishes arriving — see [edgeProgress].
///
/// Public (like `ArrowPainter`) so a test can find this painter via its
/// `ValueKey('tree-edges')`, cast to this type, and inspect [pathIds] /
/// [progress] / [edgeProgress] directly, the same way `annotate_test.dart`
/// inspects `ArrowPainter.progress` — far more robust than asserting on the
/// exact sequence of canvas draw calls.
class TreeEdgePainter extends CustomPainter {
  const TreeEdgePainter({
    required this.root,
    required this.positions,
    required this.pathIds,
    required this.progress,
  });

  final TreeNode root;
  final Map<String, Offset> positions;

  /// The current traversal path, root-to-target order (empty when no pulse
  /// is active). Consecutive ids here are guaranteed to be parent/child,
  /// since this is exactly the ancestor chain [WidgetTreeView.traversalTo]
  /// walks.
  final List<String> pathIds;

  /// How far the A24 pulse has travelled overall, from 0 (nothing lit) to 1
  /// (every edge on [pathIds] fully lit, in sync with the root node's own
  /// arrival — see [WidgetTreeView.traversalTo]). Individual edges reach
  /// their own fully-lit state well before [progress] reaches 1; see
  /// [edgeProgress].
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Palette.textSecondary
      ..strokeWidth = Tokens.strokeWidth
      ..style = PaintingStyle.stroke;
    final litPaint = Paint()
      ..color = Palette.blue
      ..strokeWidth = Tokens.strokeWidth
      ..style = PaintingStyle.stroke;
    _paintEdges(canvas, root, basePaint, litPaint);
  }

  void _paintEdges(
    Canvas canvas,
    TreeNode node,
    Paint basePaint,
    Paint litPaint,
  ) {
    final from = positions[node.id];
    if (from == null) return;
    for (final child in node.children) {
      final to = positions[child.id];
      if (to != null) {
        final lit = edgeProgress(node.id, child.id);
        // Draw the unlit remainder and the lit portion as two non-
        // overlapping segments (rather than a full grey line under a full
        // blue one) so a fully-lit edge paints once, not twice.
        if (lit < 1) {
          canvas.drawLine(
            lit <= 0 ? from : Offset.lerp(from, to, lit)!,
            to,
            basePaint,
          );
        }
        if (lit > 0) {
          canvas.drawLine(from, Offset.lerp(from, to, lit)!, litPaint);
        }
      }
      _paintEdges(canvas, child, basePaint, litPaint);
    }
  }

  /// 0 when the edge from [parentId] to [childId] is not on [pathIds], or
  /// the pulse has not yet reached it; grows to 1 as [progress] advances.
  ///
  /// [progress] arrives here as a *linear* elapsed-time fraction (see
  /// [WidgetTreeView.build]'s deliberate `Curves.linear` on the builder that
  /// feeds it) precisely so this method can re-derive real elapsed time —
  /// `scaled = progress * pathIds.length` is elapsed time in units of
  /// `Tokens.travel` — and apply [Tokens.curve] itself, *within this edge's
  /// own local window*, exactly the way each node's own [_NodeBox]
  /// `AnimatedContainer` applies [Tokens.curve] over its own individual
  /// duration rather than sharing one globally-curved value.
  ///
  /// This edge's window is `[d+1, d+2]` in those units, where `d` is the
  /// child's distance from the target: real time `Tokens.travel * (d+1)` to
  /// `Tokens.travel * (d+2)`, so it starts lighting exactly when the child
  /// node itself finishes arriving and finishes lighting exactly when the
  /// *parent* node finishes arriving. Curving the already-rescaled *global*
  /// progress instead of a local window (an earlier version of this method)
  /// looks similar but is wrong: since `Tokens.curve(x) > x` on `(0, 1)`,
  /// every interior edge would reach full brightness hundreds of
  /// milliseconds before the node it leads into — this local-window version
  /// is what a real-duration test (`widget_tree_test.dart`) checks for.
  double edgeProgress(String parentId, String childId) {
    if (pathIds.length < 2) return 0;
    final parentIndex = pathIds.indexOf(parentId);
    final childIndex = parentIndex + 1;
    if (parentIndex == -1 ||
        childIndex >= pathIds.length ||
        pathIds[childIndex] != childId) {
      return 0;
    }
    final childDistanceFromTarget = pathIds.length - 1 - childIndex;
    final scaled = progress * pathIds.length;
    final windowStart = childDistanceFromTarget + 1;
    final localLinear = (scaled - windowStart).clamp(0.0, 1.0);
    return Tokens.curve.transform(localLinear);
  }

  // `positions` is static for the lifetime of a slide's `demoTree` and
  // `progress`/`pathIds` change every animated frame; repainting
  // unconditionally is cheap for the handful of edges this tree ever has
  // and avoids depending on Map/List equality (freshly computed collections
  // are never `==` their predecessor even when every entry matches).
  @override
  bool shouldRepaint(covariant TreeEdgePainter oldDelegate) => true;
}

class _NodeBox extends StatelessWidget {
  const _NodeBox({
    required this.node,
    required this.flashing,
    required this.subscribed,
    required this.pulseDelay,
    required this.showParams,
  });

  final TreeNode node;
  final bool flashing;
  final bool subscribed;

  /// Non-null when this node sits on the current traversal path; its value
  /// is the node's distance from [WidgetTreeView.traversalTo].
  final int? pulseDelay;
  final bool showParams;

  bool get _onPath => pulseDelay != null;

  Duration get _borderDuration {
    if (flashing) return Tokens.fade;
    if (_onPath) return Tokens.travel * (pulseDelay! + 1);
    return Tokens.fade;
  }

  Color get _borderColor =>
      flashing || _onPath ? Palette.blue : Palette.textSecondary;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            key: ValueKey('flash-${node.id}'),
            duration: _borderDuration,
            curve: Tokens.curve,
            width: _nodeWidth,
            padding: const EdgeInsets.all(Tokens.gapSm),
            decoration: BoxDecoration(
              color: Palette.surface,
              border: Border.all(color: _borderColor, width: Tokens.strokeWidth),
              borderRadius: BorderRadius.circular(Tokens.radius),
              boxShadow: flashing
                  ? const [
                      BoxShadow(
                        color: _flashGlowColor,
                        blurRadius: _glowBlur,
                        spreadRadius: _glowSpread,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Palette.textPrimary,
                    fontSize: _labelFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showParams && node.params.isNotEmpty) ...[
                  const SizedBox(height: Tokens.gapXs),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: _chipSpacing,
                    runSpacing: _chipSpacing,
                    children: [
                      for (final param in node.params) _ParamChip(param),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: -_subscribedDotSize / 2,
            right: -_subscribedDotSize / 2,
            child: AnimatedOpacity(
              duration: Tokens.fade,
              curve: Tokens.curve,
              opacity: subscribed ? 1.0 : 0.0,
              child: Container(
                width: _subscribedDotSize,
                height: _subscribedDotSize,
                decoration: const BoxDecoration(
                  color: Palette.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
}

/// A small label under a node showing one parameter name, for
/// [WidgetTreeView.showParams].
class _ParamChip extends StatelessWidget {
  const _ParamChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _chipHorizontalPadding,
          vertical: _chipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: Palette.base,
          border: Border.all(
            color: Palette.textSecondary,
            width: _chipBorderWidth,
          ),
          borderRadius: BorderRadius.circular(_chipRadius),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Palette.textSecondary,
            fontSize: _chipFontSize,
          ),
        ),
      );
}
