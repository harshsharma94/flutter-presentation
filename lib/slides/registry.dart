import 'package:gopay_flutter_deck/slides/s00_open/beautiful_lie_slide.dart';
import 'package:gopay_flutter_deck/slides/s00_open/homework_slide.dart';
import 'package:gopay_flutter_deck/slides/s00_open/roadmap_slide.dart';
import 'package:gopay_flutter_deck/slides/s00_open/title_slide.dart';
import 'package:gopay_flutter_deck/slides/s01_structure/structure_slide.dart';
import 'package:gopay_flutter_deck/slides/s02_api/api_gap_slide.dart';
import 'package:gopay_flutter_deck/slides/s02_api/async_await_slide.dart';
import 'package:gopay_flutter_deck/slides/s02_api/http_clients_slide.dart';
import 'package:gopay_flutter_deck/slides/s02_api/live_first_request_slide.dart';
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

  // §2 API
  SlideSpec(
    route: '/api-gap',
    section: '§2 API',
    steps: 3,
    body: (step) => ApiGapBody(step: step),
    speakerNotes: 'The phone and the internet don\'t just talk to each '
        'other — nothing bridges them yet. Let the empty space sit for a '
        'second before you advance. Step 2 is the naive, direct attempt '
        'failing; step 3 is the shape that actually works: Dio speaks '
        'HTTP, Repository decides when to call it, Model shapes what '
        'comes back. That three-box chain is what the rest of today '
        'builds inside.',
  ),
  SlideSpec(
    route: '/http-clients',
    section: '§2 API',
    steps: 4,
    body: (step) => HttpClientsBody(step: step),
    speakerNotes: 'Dio is not new. It\'s the interceptor+client pair they '
        'already know. Don\'t sell it — just name the mapping and move to '
        'code.',
  ),
  SlideSpec(
    route: '/live-first-request',
    section: '§2 API',
    body: (step) => LiveFirstRequestBody(step: step),
    speakerNotes: 'Type it live, don\'t paste. `final dio = Dio(); final '
        'r = await dio.get(\'https://api.unsplash.com/photos\', options: '
        'Options(headers: {\'Authorization\': \'Client-ID \$key\'})); '
        'print(r.data);` — expect a 401 first if you "forget" the '
        'header. That\'s deliberate; it sets up slide 15.',
  ),
  SlideSpec(
    route: '/async-await',
    section: '§2 API',
    steps: 4,
    body: (step) => AsyncAwaitBody(step: step),
    speakerNotes: '60fps means a new frame every 16ms. Step 2: a '
        'synchronous call blocks the render thread — nothing moves, not '
        'even the phone\'s own spinner, until it returns; that\'s the red '
        'strip and the frozen spinner, not a metaphor. Step 3 is `await`: '
        'the call detaches onto its own lane so the render thread keeps '
        'ticking, and the result rejoins the main flow when it\'s ready. '
        'This is not a new idea — Kotlin\'s `suspend`, Swift\'s '
        '`async/await`, Go\'s goroutines, Java\'s `CompletableFuture` are '
        'all the same guarantee. Rehearse this one: step forward and back '
        'through all four before you present it, and if the spinner ever '
        'moves during step 2, stop and fix it before going on stage.',
  ),
];
