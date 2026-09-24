import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/source_link.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// One group per step. Official source first, then the single community
/// resource actually worth their evening — not a link dump.
/// Wide enough for the longest label on one line: the Medium URL is 59
/// characters, about 673px of 19px JetBrains Mono. The references test loads
/// the real fonts and fails if any label or note is cut off.
const _columnWidth = 690.0;

/// Every entry carries the URL it opens. A label is what the room reads; the
/// URL is what the click does — they differ where the label is a title
/// (the Widget of the Week video) or a repository path.
///
/// Public so the test can check every URL is well formed.
const referenceGroups = [
  (
    title: 'Dart & async',
    links: [
      (
        label: 'dart.dev/language',
        note: 'official',
        url: 'https://dart.dev/language',
      ),
      (
        label: 'dart.dev/codelabs/async-await',
        note: 'do this one tonight',
        url: 'https://dart.dev/codelabs/async-await',
      ),
      (
        label: 'dart.dev/effective-dart',
        note: 'style, when you have time',
        url: 'https://dart.dev/effective-dart',
      ),
    ],
  ),
  (
    title: 'Networking',
    links: [
      (
        label: 'pub.dev/packages/dio',
        note: 'official docs + interceptors',
        url: 'https://pub.dev/packages/dio',
      ),
      (
        label: 'docs.flutter.dev/cookbook/networking',
        note: 'the short version',
        url: 'https://docs.flutter.dev/cookbook/networking',
      ),
    ],
  ),
  (
    title: 'JSON',
    links: [
      (
        label: 'docs.flutter.dev/data-and-backend/serialization/json',
        note: 'official',
        url: 'https://docs.flutter.dev/data-and-backend/serialization/json',
      ),
      (
        label: 'pub.dev/packages/json_serializable',
        note: 'when hand-writing hurts',
        url: 'https://pub.dev/packages/json_serializable',
      ),
    ],
  ),
  (
    title: 'Architecture',
    links: [
      (
        label: 'docs.flutter.dev/app-architecture',
        note: "Flutter's own guide",
        url: 'https://docs.flutter.dev/app-architecture',
      ),
      (
        label: 'blog.cleancoder.com — The Clean Architecture',
        note: 'the source',
        url: 'https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html',
      ),
      (
        label: 'samnewman.io/patterns/architectural/bff',
        note: 'slide 39, left-hand shape — day 3',
        url: 'https://samnewman.io/patterns/architectural/bff/',
      ),
    ],
  ),
  (
    title: 'State management',
    links: [
      (
        label: 'docs.flutter.dev/data-and-backend/state-mgmt/options',
        note: 'how to choose',
        url: 'https://docs.flutter.dev/data-and-backend/state-mgmt/options',
      ),
      (
        label: 'pub.dev/packages/provider',
        note: 'what we used',
        url: 'https://pub.dev/packages/provider',
      ),
      (
        label: 'Flutter Widget of the Week — InheritedWidget',
        note: '3 minutes',
        url: 'https://www.youtube.com/watch?v=1t-8rBCGBYw',
      ),
      (
        label: 'Widget of the Week — ValueListenableBuilder',
        note: 'a ValueNotifier is a ChangeNotifier',
        url: 'https://www.youtube.com/watch?v=s-ZG-jS5QHQ',
      ),
      (
        label: 'medium.com/flutter-community/inherited-widgets-bc3110821969',
        note: 'the long version of slide 27',
        url: 'https://medium.com/flutter-community/inherited-widgets-bc3110821969',
      ),
      (
        label: 'lib/reference/inherited_widget_example.dart',
        note: 'slides 27-28, complete',
        url: '$repoBlobUrl/lib/reference/inherited_widget_example.dart',
      ),
      (
        label: 'lib/reference/change_notifier_example.dart',
        note: 'slides 29-31, complete',
        url: '$repoBlobUrl/lib/reference/change_notifier_example.dart',
      ),
    ],
  ),
  (
    title: 'Performance & this deck',
    links: [
      (
        label: 'docs.flutter.dev/perf/best-practices',
        note: 'rebuild scope',
        url: 'https://docs.flutter.dev/perf/best-practices',
      ),
      (
        label: 'unsplash.com/documentation',
        note: "today's API",
        url: 'https://unsplash.com/documentation',
      ),
      (
        label: 'github.com/mkobuolys/flutter_deck',
        note: 'this deck is built with it',
        url: 'https://github.com/mkobuolys/flutter_deck',
      ),
    ],
  ),
];

/// Slide 41 — `/references` (6 steps).
class ReferencesBody extends StatelessWidget {
  const ReferencesBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(Tokens.gapMd),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: _columnWidth * 2 + Tokens.gapLg,
          child: Wrap(
            spacing: Tokens.gapLg,
            runSpacing: Tokens.gapMd,
            children: [
              for (var i = 0; i < referenceGroups.length; i++)
                StepReveal(
                  atStep: i + 1,
                  dimWhenPast: false,
                  child: SizedBox(
                    width: _columnWidth,
                    child: _Group(
                      title: referenceGroups[i].title,
                      links: referenceGroups[i].links,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.links});

  final String title;
  final List<({String label, String note, String url})> links;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Palette.blue,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        for (final link in links)
          Padding(
            padding: EdgeInsets.only(bottom: 3),
            // A Wrap, not a Row of two Flexibles. Flutter gives each Flexible
            // an equal share of the row, so the label was capped at half the
            // column however short its note was — most URLs were cut off with
            // "…". In a Wrap the label can use the full width, and the note
            // sits beside it or drops to the next line when there is no room.
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: Tokens.gapXs,
              children: [
                // The label is the link: blue and underlined so it reads as
                // one, opening in a new tab so the deck stays put.
                InkWell(
                  onTap: () => openInNewTab(Uri.parse(link.url)),
                  child: Text(
                    link.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: Palette.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Palette.blue,
                      fontSize: 19,
                    ),
                  ),
                ),
                Text(
                  link.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: pal.textSecondary, fontSize: 17),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
