import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/widgets/slide_canvas.dart';
import 'package:flutter_bootcamp_deck/widgets/source_link.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

/// One slide, described independently of flutter_deck.
///
/// [body] receives the current step and must be renderable with no flutter_deck
/// ancestors — that is what lets `slides_smoke_test.dart` cover all 51 slides
/// without mocks or a router.
class SlideSpec {
  const SlideSpec({
    required this.route,
    required this.section,
    required this.body,
    this.title,
    this.steps = 1,
    this.speakerNotes,
    this.chrome = true,
    this.source,
  });

  final String route;
  final String section;
  final String? title;
  final int steps;
  final String? speakerNotes;
  final Widget Function(int step) body;

  /// Whether the persistent header/footer chrome shows on this slide.
  ///
  /// `false` for the title, break and thanks slides, where the chrome (a
  /// header repeating the section name, a footer with the slide number)
  /// would just duplicate what the slide itself already says.
  final bool chrome;

  /// A repository-relative path to a complete, runnable reference file for
  /// what this slide teaches — shown as a "full source" chip that opens it on
  /// GitHub. See [SourceLink] for why it is a click and not a hover.
  final String? source;
}

/// Wraps a [SlideSpec] as a flutter_deck slide. The section name becomes the
/// persistent header, which is how the deck orients the audience without
/// spending slides on dividers (spec §8.1).
class DeckSlide extends FlutterDeckSlideWidget {
  DeckSlide(this.spec, {super.key})
    : super(
        configuration: FlutterDeckSlideConfiguration(
          route: spec.route,
          title: spec.title ?? spec.section,
          steps: spec.steps,
          speakerNotes: spec.speakerNotes ?? '',
          header: spec.chrome
              ? FlutterDeckHeaderConfiguration(title: spec.section)
              : const FlutterDeckHeaderConfiguration(showHeader: false),
          footer: spec.chrome
              ? null
              : const FlutterDeckFooterConfiguration(showFooter: false),
        ),
      );

  final SlideSpec spec;

  /// Every slide goes through [SlideCanvas], which is what makes the deck
  /// legible from the back of a room — see that class for the reasoning. It
  /// is deliberately applied here, once, rather than in 41 slide bodies:
  /// `slides_smoke_test.dart` pumps those bodies bare, so they keep being
  /// tested at their natural size against a 1280x720 box.
  @override
  Widget build(BuildContext context) => FlutterDeckSlide.blank(
    builder: (context) => FlutterDeckSlideStepsBuilder(
      builder: (context, step) => StepScope(
        step: step,
        child: Stack(
          children: [
            Positioned.fill(child: SlideCanvas(child: spec.body(step))),
            // Outside the canvas, so it is not magnified with the content
            // and sits in the same corner on every slide that has one.
            if (spec.source case final path?)
              Positioned(top: 8, right: 16, child: SourceLink(path: path)),
          ],
        ),
      ),
    ),
  );
}
