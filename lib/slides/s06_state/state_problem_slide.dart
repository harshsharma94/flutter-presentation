import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/widget_tree.dart';

/// Step 4 doubles the load on every middle node: a second piece of state
/// arrives and has to be threaded through widgets that still don't use it.
final _crowdedTree = TreeNode(
  id: 'photo-app',
  label: 'PhotoApp',
  children: [
    TreeNode(
      id: 'home-screen',
      label: 'HomeScreen',
      params: ['photos', 'onLike', 'user', 'onFollow'],
      children: [
        TreeNode(
          id: 'photo-grid',
          label: 'PhotoGrid',
          params: ['photos', 'onLike', 'user', 'onFollow'],
          children: [
            TreeNode(
              id: 'tile-1',
              label: 'PhotoTile',
              params: ['photo', 'onLike', 'user', 'onFollow'],
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
              params: ['photo', 'onLike', 'user', 'onFollow'],
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

const _everyNodeId = {
  'photo-app',
  'home-screen',
  'photo-grid',
  'tile-1',
  'tile-2',
  'like-1',
  'like-2',
};

/// Slide 28 — `/state-problem` (5 steps, A23). Prop drilling, drawn. The
/// tree, its layout and its node positions are shared with slides 28–33, so
/// nothing jumps at a slide boundary.
class StateProblemBody extends StatelessWidget {
  const StateProblemBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Tokens.gapMd),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.fromSize(
              size: treeCanvasSize,
              child: WidgetTreeView(
                root: step >= 4 ? _crowdedTree : demoTree,
                showParams: step >= 2,
                subscribed: step >= 1 ? const {'like-1'} : const {},
                flashing: step >= 5 ? _everyNodeId : const {},
              ),
            ),
            const SizedBox(width: Tokens.gapLg),
            SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Note(
                    atStep: 1,
                    text:
                        'The data lives at the root. The widget that '
                        'needs it is four levels down.',
                  ),
                  const _Note(
                    atStep: 2,
                    text:
                        'Every widget in between takes a parameter it '
                        'never reads.',
                  ),
                  const Callout(
                    atStep: 2,
                    text: "doesn't care, still has to carry it",
                    color: Palette.amber,
                  ),
                  const SizedBox(height: Tokens.gapSm),
                  const _Note(
                    atStep: 3,
                    text:
                        'And the callback has to be threaded all the '
                        'way back up.',
                  ),
                  const _Note(
                    atStep: 4,
                    text:
                        'Add one more piece of state and every '
                        'constructor in the middle grows again.',
                  ),
                  const _Note(
                    atStep: 5,
                    text:
                        'setState at the root rebuilds the entire '
                        'subtree — including everything that did not '
                        'change.',
                    color: Palette.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note({required this.atStep, required this.text, this.color});

  final int atStep;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Tokens.gapSm),
    child: StepReveal(
      atStep: atStep,
      slideFrom: const Offset(0.06, 0),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 23, height: 1.35),
      ),
    ),
  );
}
