import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/widget_tree.dart';

/// The scope box is drawn *beside* the root rather than inserted into
/// [demoTree] itself. Inserting a node would add a level, which changes
/// `treeNodePositions`' row height and shifts every node — and slides 25–30
/// depend on the tree never jumping across a slide boundary.
const _scopeWidth = 170.0;
const _scopeHeight = 68.0;

/// Slide 26 — `/inherited-widget` (9 steps, A24). The same tree as slide 27,
/// with the chips falling away and an ancestor-chain lookup travelling up to
/// a scope that sits at the root.
///
/// Step 9 is the one that makes the pattern feel ordinary rather than
/// advanced: `Theme.of(context)` is an `InheritedWidget`, and they have been
/// calling it since their first screen. It is also the homework nudge —
/// reading the theme from a leaf is the smallest possible version of this
/// exercise, with no new package and nothing to install.
class InheritedWidgetBody extends StatelessWidget {
  const InheritedWidgetBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final positions = treeNodePositions(demoTree, treeCanvasSize);
    final rootAt = positions['photo-app']!;
    final scopeLeft = rootAt.dx + 100;
    final scopeTop = rootAt.dy - _scopeHeight / 2;

    // Step 4: a second leaf subscribes; the third node deliberately does not.
    final subscribed = <String>{
      if (step >= 3) 'like-1',
      if (step >= 4) 'like-2',
    };

    // Step 5: the data changes and only subscribers rebuild.
    final flashing = <String>{if (step >= 5) ...subscribed};

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapMd),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.fromSize(
                size: treeCanvasSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    WidgetTreeView(
                      root: demoTree,
                      // Step 2 is the chips falling away: showParams goes
                      // false and StepReveal's own downward slide carries
                      // them out rather than cutting them.
                      showParams: step < 2,
                      subscribed: subscribed,
                      flashing: flashing,
                      traversalTo: step >= 3 ? 'like-1' : null,
                    ),
                    Positioned(
                      left: scopeLeft,
                      top: scopeTop,
                      child: StepReveal(
                        atStep: 1,
                        dimWhenPast: false,
                        slideFrom: Offset(0.4, 0),
                        child: const _ScopeBox(),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedArrow(
                        from: Offset(rootAt.dx + 30, rootAt.dy),
                        to: Offset(scopeLeft, scopeTop + _scopeHeight / 2),
                        atStep: 3,
                        color: Palette.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Tokens.gapLg),
              // 440 wide made this column 1789 tall — nearly square once
              // the tree sat beside it, so the slide was scaled down to fit
              // its height and left a third of the screen empty either side.
              SizedBox(
                width: 900,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Note(
                      atStep: 1,
                      text: 'Put the data in a scope at the top of the tree.',
                    ),
                    const _Note(
                      atStep: 2,
                      text:
                          'The middle widgets stop carrying it. Their '
                          'constructors shrink back to what they actually use.',
                      color: Palette.green,
                    ),
                    StepReveal(
                      atStep: 3,
                      child: Container(
                        padding: EdgeInsets.all(Tokens.gapSm),
                        margin: EdgeInsets.only(bottom: Tokens.gapSm),
                        decoration: BoxDecoration(
                          color: pal.base,
                          border: Border.all(color: Palette.blue, width: 1),
                          borderRadius: BorderRadius.circular(Tokens.radius),
                        ),
                        child: Text(
                          'context.dependOnInheritedWidgetOfExactType\n'
                          '    <PhotoScope>()',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 20,
                            color: Palette.blue,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const _Note(
                      atStep: 4,
                      text:
                          'Any descendant can ask. The one that never asks '
                          'never subscribes.',
                    ),
                    const _Note(
                      atStep: 5,
                      text:
                          'Data changes: only the widgets that asked '
                          'rebuild. The rest stay dark.',
                      color: Palette.green,
                    ),
                    SizedBox(height: Tokens.gapXs),
                    CorrelationPanel(
                      flutterLabel: 'InheritedWidget',
                      firstStep: 6,
                      rows: [
                        CorrelationRow(
                          platform: 'Android',
                          concept: 'CompositionLocal',
                        ),
                        CorrelationRow(
                          platform: 'iOS',
                          concept: '@Environment',
                        ),
                        CorrelationRow(
                          platform: 'Web',
                          concept: 'React Context',
                        ),
                      ],
                    ),
                    SizedBox(height: Tokens.gapSm),
                    StepReveal(
                      atStep: 9,
                      dimWhenPast: false,
                      child: _AlreadyUsingItPanel(),
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
}

/// `.of(context)` is the tell. Two lookups they have already written, named
/// as what they are, so tonight's exercise reads as "do the thing you have
/// been doing, on purpose" rather than as a new technique.
class _AlreadyUsingItPanel extends StatelessWidget {
  const _AlreadyUsingItPanel();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: Palette.green, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You have been using one since day 1.',
            style: TextStyle(
              color: Palette.green,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'Theme.of(context).colorScheme.primary\n'
            'MediaQuery.of(context).size',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 19,
              color: pal.textPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'Both are InheritedWidgets. MaterialApp puts the theme at the '
            'root; every .of(context) walks up to it. Tonight: put your own '
            'scope up there and read it from a leaf — same shape, your data.',
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: 18,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeBox extends StatelessWidget {
  const _ScopeBox();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: _scopeWidth,
      constraints: BoxConstraints(minHeight: _scopeHeight),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PhotoScope',
            style: TextStyle(
              color: Palette.blue,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'InheritedWidget',
            style: TextStyle(color: pal.textSecondary, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.atStep, required this.text, this.color});

  final int atStep;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: Tokens.gapSm),
    child: StepReveal(
      atStep: atStep,
      slideFrom: Offset(0.06, 0),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 22, height: 1.35),
      ),
    ),
  );
}
