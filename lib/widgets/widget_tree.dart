/// The shared widget tree for §6 (slides 31-38): the same tree, built once,
/// that the audience watches evolve across nine consecutive slides — first
/// drowning in prop-drilled parameters, then shedding them as an
/// `InheritedWidget` arrives, then pulsing with `ChangeNotifier` listeners,
/// then collapsing into `Provider`.
///
/// The visual continuity across those slides is the whole pedagogical
/// device, so [WidgetTreeView] lays nodes out **deterministically from
/// [WidgetTreeView.root]** — a node's position depends only on the tree's
/// shape, never on [WidgetTreeView.flashing], [WidgetTreeView.subscribed],
/// [WidgetTreeView.traversalTo] or [WidgetTreeView.showParams]. Every node
/// box is a fixed [_nodeWidth] regardless of whether its parameter chips are
/// showing, so turning `showParams` on only makes a box taller (pushing
/// later rows down), never shifts it sideways.
///
/// All motion here is implicit — [AnimatedContainer] reacting to changed
/// `flashing`/`subscribed`/`traversalTo` inputs — so there is no
/// `AnimationController` and no timer, and stepping the presentation
/// backward simply re-targets each animation, which reverses it correctly.
library;

import 'package:flutter/material.dart';
import 'package:gopay_flutter_deck/theme/palette.dart';
import 'package:gopay_flutter_deck/theme/tokens.dart';

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
  /// [WidgetTreeView.traversalTo].
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

/// Fixed width for every node box, regardless of [WidgetTreeView.showParams]
/// or how many parameters a node carries. This is what keeps a node's
/// horizontal position identical whether or not its chips are showing:
/// toggling `showParams` only changes a box's height (chips wrap inside this
/// width), never its column, and each level's row divides its width evenly
/// by sibling count alone.
const _nodeWidth = 148.0;

const _labelFontSize = 15.0;
const _chipFontSize = 11.0;
const _chipSpacing = 4.0;
const _chipHorizontalPadding = 6.0;
const _chipVerticalPadding = 2.0;
const _chipBorderWidth = 1.0;
const _chipRadius = 6.0;

/// Height of the small stub a subscribed leaf grows above its box — a
/// symbolic stand-in for the `addListener()` line A26 draws from leaf to
/// model. It stays local to the node, rather than routed to the model's true
/// on-screen position, because [WidgetTreeView] lays levels out as
/// independent rows rather than absolute coordinates (see class doc).
const _connectorWidth = Tokens.strokeWidth;
const _connectorHeight = Tokens.gapSm;

const _glowBlur = 12.0;
const _glowSpread = 2.0;

/// [Palette.blue] at ~40% alpha, written as a literal ARGB constant (rather
/// than a runtime `.withValues` call) so it stays usable inside a
/// `const [BoxShadow(...)]` list.
const _flashGlowColor = Color(0x66118EEA);

/// Renders [root] as a `Column` of per-depth `Row`s, one bordered box per
/// node. See the library doc for the determinism guarantee that makes this
/// safe to reuse, unchanged in shape, across slides 31-38.
///
/// - [flashing] / [subscribed] retarget which node ids are lit or connected
///   for this render, without mutating [root] (see [TreeNode]).
/// - [traversalTo] drives the A24 "reaching up the tree" pulse: every node
///   on the ancestor path from [root] down to that id lights up, each with
///   an [AnimatedContainer] duration that grows with its distance from
///   [traversalTo] — so although every one of them starts animating at the
///   same instant, the node closest to [traversalTo] reaches "lit" first and
///   [root] (furthest away) arrives last, reading as a pulse travelling up
///   the chain node by node with no timer involved.
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
    final levels = _levelsOf(root);
    final pulseDelays = _pulseDelaysTo(root, traversalTo);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < levels.length; i++) ...[
          if (i > 0) const SizedBox(height: Tokens.gapMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final node in levels[i])
                Expanded(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Tokens.gapXs),
                      child: _NodeBox(
                        node: node,
                        flashing: node.flashing || flashing.contains(node.id),
                        subscribed:
                            node.subscribed || subscribed.contains(node.id),
                        pulseDelay: pulseDelays[node.id],
                        showParams: showParams,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
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

/// Maps every node id on the ancestor path from [root] to [targetId] onto
/// its distance from [targetId] (0 at the target itself, increasing toward
/// [root]). Empty when [targetId] is null. See [WidgetTreeView.traversalTo]
/// for how this distance drives the staggered-duration pulse illusion.
Map<String, int> _pulseDelaysTo(TreeNode root, String? targetId) {
  if (targetId == null) return const {};
  final path = _pathTo(root, targetId);
  assert(
    path != null,
    'WidgetTreeView.traversalTo "$targetId" is not a node in this tree.',
  );
  if (path == null) return const {};
  return {
    for (var i = 0; i < path.length; i++) path[i]: path.length - 1 - i,
  };
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
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Tokens.fade,
            curve: Tokens.curve,
            width: _connectorWidth,
            height: subscribed ? _connectorHeight : 0,
            color: Palette.blue,
          ),
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
