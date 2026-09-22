import 'package:gopay_flutter_deck/slides/s00_open/beautiful_lie_slide.dart';
import 'package:gopay_flutter_deck/slides/s00_open/homework_slide.dart';
import 'package:gopay_flutter_deck/slides/s00_open/roadmap_slide.dart';
import 'package:gopay_flutter_deck/slides/s00_open/title_slide.dart';
import 'package:gopay_flutter_deck/slides/s01_structure/structure_slide.dart';
import 'package:gopay_flutter_deck/slides/slide_spec.dart';

/// The ordered list of every slide in the deck. This is the single source of
/// truth: `main.dart` builds the deck from it and `slides_smoke_test.dart`
/// iterates it, so a slide cannot exist without being covered by the gate.
///
/// Grouped by section so cutting a slide is a one-line deletion (spec §14).
final List<SlideSpec> slideRegistry = [
  // §0 Open
  SlideSpec(
    route: '/title',
    section: '§0 Open',
    title: 'Day 2 — Making It Real',
    chrome: false,
    body: (step) => TitleBody(step: step),
    speakerNotes: '30 seconds, no more. Names, then move — slide 2 is the '
        'hook and you want them still settling in when it lands.',
  ),
  SlideSpec(
    route: '/beautiful-lie',
    section: '§0 Open',
    steps: 3,
    body: (step) => BeautifulLieBody(step: step),
    speakerNotes: 'They built two screens off one hardcoded list. One '
        'change today fixes both — that\'s slide 22. Ask: how many of you '
        'copy-pasted the list into the detail screen?',
  ),
  SlideSpec(
    route: '/roadmap',
    section: '§0 Open',
    steps: 5,
    body: (step) => RoadmapBody(step: step),
    speakerNotes: 'Just orient them — five stops, in order, over today and '
        'tomorrow. Don\'t teach anything yet; this is a map, not a lesson. '
        'Come back to this spine at the start of every section.',
  ),
  SlideSpec(
    route: '/homework',
    section: '§0 Open',
    body: (step) => HomeworkBody(step: step),
    speakerNotes: '15 min. Pick 2–3 volunteers. Look for: a reusable row '
        'widget, ListView vs GridView choice, and whether navigation '
        'passes the whole model or just an id. That last one sets up the '
        'repository discussion in session 2.',
  ),

  // §1 Folder structure
  SlideSpec(
    route: '/structure',
    section: '§1 Folder structure',
    steps: 9,
    body: (step) => StructureBody(step: step),
    speakerNotes: 'Don\'t debate folder philosophy. Point out it\'s the '
        'same structure they used in Android, renamed. The rule that '
        'matters: feature-first beats type-first as soon as you have two '
        'features.',
  ),
];
