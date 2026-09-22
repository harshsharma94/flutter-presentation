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

/// Slide 28 — `/change-notifier` (9 steps, A26). Hybrid: a step-driven
/// diagram *plus* a genuinely tappable button wired to a real
/// [CounterModel]. Every arrow is labelled with the real method name.
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
    final pal = Palette.of(context);
    final step = widget.step;
    final positions = treeNodePositions(demoTree, treeCanvasSize);
    final leafA = positions['like-1']!;
    final leafB = positions['like-2']!;

    // Step 2 registers both leaves; step 6 disposes one, so the next pulse
    // has nowhere to travel on that line.
    final listeners = <String>{
      if (step >= 2) 'like-1',
      if (step >= 2 && step < 6) 'like-2',
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
                          // Step 5 onward: a tick lights exactly the nodes
                          // that are still registered.
                          flashing: step >= 5 && _model.likes > 0
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
                      if (step < 6)
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
                      Positioned(
                        left: 0,
                        top: treeCanvasSize.height - 60,
                        child: StepReveal(
                          atStep: 6,
                          dimWhenPast: false,
                          child: Callout(
                            atStep: 6,
                            text:
                                'dispose() — the line is gone, the next '
                                'pulse skips it',
                            color: Palette.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Tokens.gapMd),
              SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepReveal(
                      atStep: 3,
                      dimWhenPast: false,
                      child: FilledButton.icon(
                        key: ValueKey('increment'),
                        onPressed: _model.increment,
                        icon: Icon(Icons.favorite),
                        label: Text('counter.increment()'),
                      ),
                    ),
                    SizedBox(height: Tokens.gapSm),
                    Text(
                      'This button is real. Tap it.',
                      style: TextStyle(color: pal.textSecondary, fontSize: 20),
                    ),
                    SizedBox(height: Tokens.gapMd),
                    CorrelationPanel(
                      flutterLabel: 'ChangeNotifier',
                      firstStep: 7,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
              fontSize: 18,
            ),
          ),
          if (step >= 4)
            Text(
              'notifyListeners()',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: Palette.green,
                fontSize: 13,
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
