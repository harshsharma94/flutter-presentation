import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/rebuild_scope_demo.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Slide 30 — `/watch-read-consumer` (1 step, A28). Live and interactive,
/// not step-driven: hand over the keyboard. The flash region is the lesson.
///
/// The legend beside the demo is not decoration. Nothing before this slide
/// has shown `context.watch`, `context.read` or `Consumer` — slide 29 ends at
/// "`ChangeNotifierProvider` exists", and three unexplained API names then
/// arrive at once on a slide with no steps to pace them. So each is written
/// out as the line you would actually type, with what it subscribes to and
/// what it rebuilds, and the heading says the thing the buttons cannot: all
/// three are reading the *same* notifier. The only difference is how much of
/// the tree hears about it.
class WatchReadConsumerBody extends StatelessWidget {
  const WatchReadConsumerBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapMd),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Three ways to read one ChangeNotifier.',
                style: TextStyle(color: pal.textPrimary, fontSize: 30),
              ),
              SizedBox(height: Tokens.gapXs),
              Text(
                'Same CounterModel behind all three buttons. What changes is '
                'how much of the tree rebuilds when it calls '
                'notifyListeners().',
                style: TextStyle(color: pal.textSecondary, fontSize: 21),
              ),
              SizedBox(height: Tokens.gapMd),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RebuildScopeDemo(),
                  SizedBox(width: Tokens.gapLg),
                  SizedBox(width: 620, child: _Legend()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What each button actually is, in the words they would type.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Entry(
        color: Palette.blue,
        code: 'final likes = context.watch<CounterModel>().likes;',
        text:
            'Subscribes the widget that calls it. Called high in the '
            'tree, everything underneath rebuilds with it.',
      ),
      _Entry(
        color: Palette.amber,
        code: 'context.read<CounterModel>().increment();',
        text:
            'Does not subscribe at all. For calling a method, never for '
            'reading a value you want to redraw — watch the number refuse '
            'to move.',
      ),
      _Entry(
        color: Palette.green,
        code:
            'Consumer<CounterModel>(\n'
            '  builder: (context, model, _) => Text(\'\${model.likes}\'),\n'
            ')',
        text:
            'Subscribes only what is inside the builder. Same data, one '
            'leaf rebuilt instead of a screen.',
      ),
    ],
  );
}

class _Entry extends StatelessWidget {
  const _Entry({required this.color, required this.code, required this.text});

  final Color color;
  final String code;
  final String text;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: Tokens.gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Tokens.gapSm,
              vertical: Tokens.gapXs,
            ),
            decoration: BoxDecoration(
              color: pal.surface,
              border: Border.all(color: color, width: Tokens.strokeWidth),
              borderRadius: BorderRadius.circular(Tokens.radius),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: color,
                fontSize: 18,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            text,
            style: TextStyle(
              color: pal.textSecondary,
              fontSize: 19,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
