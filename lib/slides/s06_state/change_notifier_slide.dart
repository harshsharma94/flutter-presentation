import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/notifier_demo.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/widget_tree.dart';

const _modelWidth = 200.0;
const _modelHeight = 76.0;

/// Slide 28 — `/change-notifier` (7 steps, A26). Hybrid: a step-driven
/// diagram *plus* a genuinely tappable button wired to a real
/// [CounterModel], so the numbers and the flashes are real events rather
/// than a drawing of events.
///
/// The slide answers exactly one question — **who is listening, and how do
/// they find out?** — because that is the question `notifyListeners()` begs
/// and never answers by itself. So every step has a sentence beside it
/// naming the mechanic in plain words, and the sentences are the slide; the
/// diagram is their illustration.
///
/// Two things are deliberate and have bitten before:
///
/// - The tappable button is **outside** the tree on purpose. It stands for a
///   `LikeButton` being tapped, and the step-3 note says so. Putting it on a
///   tile would make the count look like that tile's own state, which is the
///   exact misconception this slide exists to remove: the number lives in
///   one object that the tiles only *read*.
/// - The `dispose()` note lives in the right-hand column, not on the canvas.
///   On the canvas it was positioned under the left-most leaf, where it
///   overlapped the node and ran off the slide.
class ChangeNotifierBody extends StatefulWidget {
  const ChangeNotifierBody({required this.step, super.key});

  final int step;

  @override
  State<ChangeNotifierBody> createState() => _ChangeNotifierBodyState();
}

class _ChangeNotifierBodyState extends State<ChangeNotifierBody> {
  final _model = CounterModel();

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final positions = treeNodePositions(demoTree, treeCanvasSize);
    final leafA = positions['like-1']!;
    final leafB = positions['like-2']!;

    // Step 2 registers both leaves; step 5 disposes one, so the next pulse
    // has nowhere to travel on that line.
    final listeners = <String>{
      if (step >= 2) 'like-1',
      if (step >= 2 && step < 5) 'like-2',
    };

    final modelLeft = treeCanvasSize.width - _modelWidth / 2;
    const modelTop = 40.0;
    // Two listeners, two entry points. Converging both lines on one pixel
    // stacked their arrowheads and read as a single thick blob, so each
    // line lands on its own point along the model box's left edge.
    final anchorA = Offset(modelLeft, modelTop + _modelHeight * 0.3);
    final anchorB = Offset(modelLeft, modelTop + _modelHeight * 0.75);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapMd),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: treeCanvasSize.width + _modelWidth,
                height: treeCanvasSize.height,
                child: ListenableBuilder(
                  listenable: _model,
                  builder: (context, _) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox.fromSize(
                        size: treeCanvasSize,
                        child: WidgetTreeView(
                          root: demoTree,
                          subscribed: listeners,
                          // Step 4 onward: a tick lights exactly the nodes
                          // that are still registered.
                          flashing: step >= 4 && _model.likes > 0
                              ? listeners
                              : const {},
                        ),
                      ),
                      Positioned(
                        left: modelLeft,
                        top: modelTop,
                        child: StepReveal(
                          atStep: 1,
                          dimWhenPast: false,
                          slideFrom: Offset(0.3, 0),
                          child: _ModelBox(likes: _model.likes, step: step),
                        ),
                      ),
                      // addListener() lines, drawn from each subscribing
                      // leaf up to the model.
                      Positioned.fill(
                        child: StepReveal(
                          atStep: 2,
                          dimWhenPast: false,
                          child: AnimatedArrow(
                            from: leafA,
                            to: anchorA,
                            atStep: 2,
                            curved: true,
                            color: Palette.green,
                          ),
                        ),
                      ),
                      if (step < 5)
                        Positioned.fill(
                          child: StepReveal(
                            atStep: 2,
                            dimWhenPast: false,
                            child: AnimatedArrow(
                              from: leafB,
                              to: anchorB,
                              atStep: 2,
                              curved: true,
                              color: Palette.green,
                            ),
                          ),
                        ),
                      Positioned(
                        left: modelLeft - 60,
                        top: modelTop + _modelHeight + Tokens.gapSm,
                        child: Callout(
                          atStep: 2,
                          text: 'addListener()',
                          color: Palette.green,
                        ),
                      ),
                      // notifyListeners() — a ring keyed to the notifier's
                      // value, so every tap re-pulses.
                      Positioned(
                        left: modelLeft + _modelWidth / 2 - 60,
                        top: modelTop + _modelHeight / 2 - 60,
                        child: StepReveal(
                          atStep: 4,
                          dimWhenPast: false,
                          child: _Pulse(tick: _model.likes),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Tokens.gapMd),
              SizedBox(
                width: 460,
                child: _Commentary(step: step, model: _model),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The right-hand column: one plain sentence per step naming the mechanic,
/// the real button, and the correlation. This is where the slide is actually
/// explained — `notifyListeners()` on a diagram tells a room that has never
/// seen it precisely nothing.
class _Commentary extends StatelessWidget {
  const _Commentary({required this.step, required this.model});

  final int step;
  final CounterModel model;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Line(
          atStep: 1,
          color: Palette.blue,
          text:
              'One object holds the number — and a list of everyone who '
              'wants to know when it changes.',
        ),
        _Line(
          atStep: 2,
          color: Palette.green,
          text:
              'Both LikeButtons put themselves on that list: '
              'addListener(). That list is all a ChangeNotifier is.',
        ),
        StepReveal(
          atStep: 3,
          dimWhenPast: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: Tokens.gapSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  key: ValueKey('increment'),
                  onPressed: model.increment,
                  icon: Icon(Icons.favorite),
                  label: Text('counter.increment()'),
                ),
                SizedBox(height: Tokens.gapXs),
                Text(
                  'Real button, real model. Tap it — this is the same call a '
                  'LikeButton makes when you tap the heart.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        _Line(
          atStep: 4,
          color: Palette.green,
          text:
              'increment() changes the number, then calls '
              'notifyListeners() — which walks the list and rebuilds '
              'everyone on it. Both tiles flash. Nothing else in the tree '
              'moves.',
        ),
        _Line(
          atStep: 5,
          color: Palette.red,
          text:
              'A widget that goes away must come off the list — '
              'removeListener(), or dispose(). Forget it and the model '
              'keeps rebuilding a widget that no longer exists. That is the '
              'leak, and it is the line people forget in production.',
        ),
        SizedBox(height: Tokens.gapXs),
        CorrelationPanel(
          flutterLabel: 'ChangeNotifier',
          firstStep: 6,
          stepsPerRow: 0,
          flutterStep: 7,
          rows: [
            CorrelationRow(
              platform: 'Android',
              concept: 'LiveData / StateFlow',
            ),
            CorrelationRow(
              platform: 'iOS',
              concept: 'ObservableObject / @Published',
            ),
            CorrelationRow(
              platform: 'Java/Spring',
              concept: 'PropertyChangeListener',
            ),
          ],
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.atStep, required this.text, required this.color});

  final int atStep;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => StepReveal(
    atStep: atStep,
    dimWhenPast: false,
    child: Padding(
      padding: EdgeInsets.only(bottom: Tokens.gapSm),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 21, height: 1.35),
      ),
    ),
  );
}

class _ModelBox extends StatelessWidget {
  const _ModelBox({required this.likes, required this.step});

  final int likes;
  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: _modelWidth,
      constraints: BoxConstraints(minHeight: _modelHeight),
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
            'CounterModel',
            style: TextStyle(
              color: Palette.blue,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'likes: $likes',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: pal.textPrimary,
              fontSize: 20,
            ),
          ),
          if (step >= 4)
            Text(
              'notifyListeners()',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: Palette.green,
                fontSize: 15,
              ),
            ),
        ],
      ),
    );
  }
}

/// A ring that expands and fades once per notification. Keyed on [tick] so
/// a repeat tap restarts it rather than sitting finished.
class _Pulse extends StatelessWidget {
  const _Pulse({required this.tick});

  final int tick;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(tick),
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 700),
    curve: Curves.easeOut,
    builder: (context, t, child) => Opacity(
      opacity: (1 - t).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 0.3 + t * 1.2,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Palette.green, width: Tokens.strokeWidth),
          ),
        ),
      ),
    ),
  );
}
