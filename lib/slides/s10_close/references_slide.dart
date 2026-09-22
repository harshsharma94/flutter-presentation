import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// One group per step. Official source first, then the single community
/// resource actually worth their evening — not a link dump.
const _groups = [
  (
    title: 'Dart & async',
    links: [
      (label: 'dart.dev/language', note: 'official'),
      (label: 'dart.dev/codelabs/async-await', note: 'do this one tonight'),
      (label: 'dart.dev/effective-dart', note: 'style, when you have time'),
    ],
  ),
  (
    title: 'Networking',
    links: [
      (label: 'pub.dev/packages/dio', note: 'official docs + interceptors'),
      (label: 'docs.flutter.dev/cookbook/networking', note: 'the short version'),
    ],
  ),
  (
    title: 'JSON',
    links: [
      (
        label: 'docs.flutter.dev/data-and-backend/serialization/json',
        note: 'official',
      ),
      (label: 'pub.dev/packages/json_serializable', note: 'when hand-writing hurts'),
    ],
  ),
  (
    title: 'Architecture',
    links: [
      (label: 'docs.flutter.dev/app-architecture', note: "Flutter's own guide"),
      (label: 'blog.cleancoder.com — The Clean Architecture', note: 'the source'),
      (label: 'samnewman.io/patterns/architectural/bff', note: 'BFF, first-hand'),
    ],
  ),
  (
    title: 'State management',
    links: [
      (
        label: 'docs.flutter.dev/data-and-backend/state-mgmt/options',
        note: 'how to choose',
      ),
      (label: 'pub.dev/packages/provider', note: 'what we used'),
      (label: 'Flutter Widget of the Week — InheritedWidget', note: '3 minutes'),
    ],
  ),
  (
    title: 'Performance & this deck',
    links: [
      (label: 'docs.flutter.dev/perf/best-practices', note: 'rebuild scope'),
      (label: 'unsplash.com/documentation', note: "today's API"),
      (label: 'github.com/mkobuolys/flutter_deck', note: 'this deck is built with it'),
    ],
  ),
];

/// Slide 50 — `/references` (6 steps).
class ReferencesBody extends StatelessWidget {
  const ReferencesBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapMd),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 1180,
              child: Wrap(
                spacing: Tokens.gapLg,
                runSpacing: Tokens.gapMd,
                children: [
                  for (var i = 0; i < _groups.length; i++)
                    StepReveal(
                      atStep: i + 1,
                      dimWhenPast: false,
                      child: SizedBox(
                        width: 550,
                        child: _Group(
                          title: _groups[i].title,
                          links: _groups[i].links,
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
  final List<({String label, String note})> links;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Palette.blue,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      link.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        color: Palette.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: Tokens.gapXs),
                  Text(
                    link.note,
                    style: const TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
}
