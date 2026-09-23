import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/inherited_limits_slide.dart'
    show photoScopeHostCode;
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _boxWidth = 300.0;
const _resultWidth = 380.0;

/// The one line that replaces [photoScopeHostCode]. Deliberately shown whole,
/// including the `child:`, so nobody has to take on faith that something was
/// left out.
const _providerLine = '''
ChangeNotifierProvider(
  create: (_) => PhotoModel(),
  child: PhotoApp(),
)''';

/// Slide 29 — `/provider-fusion` (3 steps, A27). Provider is not a new idea:
/// it is the two they have just spent four slides on, added together.
///
/// The slide is arithmetic, and it is drawn as arithmetic — `A + B = C`, with
/// A and B **still on screen** when C arrives. An earlier version cross-faded:
/// the two halves slid to the centre while fading to zero as the combined box
/// faded up in the same place. That reads as a substitution, which is the
/// opposite of the point. Provider does not replace the two ideas; it *is*
/// them, and the room should be able to see all three at once while you say
/// so.
///
/// Step 3 is the receipt. It used to be a counter reading "lines of wiring: 38
/// -> 6" — numbers that appear nowhere else in the deck and that nobody could
/// check, animated by a `TweenAnimationBuilder` whose begin and end were the
/// same value, so it did not even animate. It is now the actual wrapper from
/// slide 27, character for character, against the line that deletes it. The
/// audience read that code twenty minutes ago; they can count it themselves.
class ProviderFusionBody extends StatelessWidget {
  const ProviderFusionBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(Tokens.gapLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Provider is not a new idea.',
                style: TextStyle(color: pal.textPrimary, fontSize: 32),
              ),
              SizedBox(height: Tokens.gapLg),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Half(
                    title: 'InheritedWidget',
                    can: 'reaches every descendant',
                    cannot: 'but it cannot change',
                    color: Palette.blue,
                  ),
                  _Operator(symbol: '+', atStep: 1),
                  _Half(
                    title: 'ChangeNotifier',
                    can: 'changes, and tells its listeners',
                    cannot: 'but nobody can find it',
                    color: Palette.green,
                  ),
                  _Operator(symbol: '=', atStep: 2),
                  StepReveal(
                    atStep: 2,
                    dimWhenPast: false,
                    slideFrom: Offset(0.2, 0),
                    child: _Result(),
                  ),
                ],
              ),
              SizedBox(height: Tokens.gapLg),
              StepReveal(atStep: 3, dimWhenPast: false, child: _Receipt()),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the two halves. Both stay at full opacity for the whole slide —
/// see the class doc for why that is the design and not an oversight.
class _Half extends StatelessWidget {
  const _Half({
    required this.title,
    required this.can,
    required this.cannot,
    required this.color,
  });

  final String title;
  final String can;
  final String cannot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: _boxWidth,
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: color, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            can,
            textAlign: TextAlign.center,
            style: TextStyle(color: pal.textPrimary, fontSize: 19, height: 1.3),
          ),
          Text(
            cannot,
            textAlign: TextAlign.center,
            style: TextStyle(color: Palette.amber, fontSize: 19, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: _resultWidth,
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: pal.textPrimary, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ChangeNotifierProvider',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pal.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'reaches every descendant,\nand changes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Palette.green, fontSize: 19, height: 1.3),
          ),
        ],
      ),
    );
  }
}

/// The `+` and the `=`. Sized so both operators occupy identical width and
/// the three boxes stay on a stable grid as the second one arrives.
class _Operator extends StatelessWidget {
  const _Operator({required this.symbol, required this.atStep});

  final String symbol;
  final int atStep;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return SizedBox(
      width: 64,
      child: StepReveal(
        atStep: atStep,
        dimWhenPast: false,
        child: Text(
          symbol,
          textAlign: TextAlign.center,
          style: TextStyle(color: pal.textSecondary, fontSize: 40),
        ),
      ),
    );
  }
}

/// Slide 27's wrapper against the line that deletes it. Evidence, not a
/// claim — this is the same text they read two slides ago.
class _Receipt extends StatelessWidget {
  const _Receipt();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Panel(
            caption: 'the wrapper from two slides ago',
            captionColor: Palette.amber,
            width: 640,
            child: CodePanel(
              code: photoScopeHostCode,
              fileName: 'lib/state/photo_scope_host.dart',
            ),
          ),
          SizedBox(width: Tokens.gapMd),
          _Panel(
            caption: 'what replaces it',
            captionColor: Palette.green,
            width: 420,
            child: CodePanel(code: _providerLine, fileName: 'lib/main.dart'),
          ),
        ],
      ),
      SizedBox(height: Tokens.gapMd),
      Text(
        'Same behaviour. You just stop writing the plumbing.',
        style: TextStyle(color: Palette.green, fontSize: 22),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.caption,
    required this.captionColor,
    required this.width,
    required this.child,
  });

  final String caption;
  final Color captionColor;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Tokens.gapXs),
          child: Text(
            caption,
            style: TextStyle(color: captionColor, fontSize: 20),
          ),
        ),
        child,
      ],
    ),
  );
}
