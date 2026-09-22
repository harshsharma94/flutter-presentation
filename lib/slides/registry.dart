import 'package:flutter_bootcamp_deck/slides/s00_open/beautiful_lie_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s00_open/homework_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s00_open/roadmap_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s00_open/title_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s01_structure/structure_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/api_gap_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/async_await_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/error_swallowed_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/future_states_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/http_clients_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/live_first_request_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/loading_state_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/three_states_code_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s02_api/when_it_breaks_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/auth_401_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/interceptor_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/oauth_flow_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/unsplash_reality_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/break_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/codegen_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/delete_hardcoded_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/from_json_code_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/json_to_dart_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/live_map_model_slide.dart';
import 'package:flutter_bootcamp_deck/slides/slide_spec.dart';

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
  SlideSpec(
    route: '/future-states',
    section: '§2 API',
    steps: 3,
    body: (step) => FutureStatesBody(step: step),
    speakerNotes: 'A Future is exactly one of three things: not done yet, '
        'done with a value, or done with an error. Step 3 is the point: '
        'the error branch is not a rare edge case bolted onto the model, '
        'it\'s equally native to it. Every `await` you write is choosing '
        'to handle two branches, not one.',
  ),
  SlideSpec(
    route: '/loading-state',
    section: '§2 API',
    body: (step) => LoadingStateBody(step: step),
    speakerNotes: 'Hand the keyboard to someone. Make them click error. '
        'Ask what a user would do here. Let the silence sit — that\'s the '
        'point, not a gap to fill. Then click data and note it\'s pulling '
        'from the same offline fixture as slide 8, no live request risked.',
  ),
  SlideSpec(
    route: '/error-swallowed',
    section: '§2 API',
    steps: 3,
    body: (step) => ErrorSwallowedBody(step: step),
    speakerNotes: 'Step 1: this compiles, runs, and ships — nobody\'s '
        'lint catches an empty catch block. Step 2: let the clock actually '
        'climb from 5 to 30 while you keep talking; don\'t rush past it, '
        'the discomfort is the lesson. Step 3 is the punchline — say it '
        'plainly and then stop talking for a second.',
  ),
  SlideSpec(
    route: '/three-states-code',
    section: '§2 API',
    steps: 3,
    body: (step) => ThreeStatesCodeBody(step: step),
    speakerNotes: 'This is the same switch slide 11 just ran live — show '
        'it quickly as the code behind the demo, don\'t re-teach it. Cut '
        'this one first if you\'re short on time; the demo already made '
        'the point.',
  ),
  SlideSpec(
    route: '/when-it-breaks',
    section: '§2 API',
    steps: 3,
    body: (step) => WhenItBreaksBody(step: step),
    speakerNotes: 'Put this on screen when someone\'s app hangs. Don\'t '
        'teach it cold. Android: AndroidManifest.xml needs the INTERNET '
        'permission. macOS: Runner.entitlements needs '
        'com.apple.security.network.client, both debug and release. Web: '
        'CORS is the server\'s problem, not yours — point them at a proxy '
        'or a CORS-friendly endpoint for the workshop and move on.',
  ),

  // §3 Auth
  SlideSpec(
    route: '/auth-401',
    section: '§3 Auth',
    steps: 3,
    body: (step) => Auth401Body(step: step),
    speakerNotes: 'A request with no credential just bounces — a flat 401, '
        'nothing more. Step 3\'s key is deliberately unexplained: where it '
        'comes from and how you keep it valid without asking the user to '
        'log in again every hour is the whole of slide 16.',
  ),
  SlideSpec(
    route: '/oauth-flow',
    section: '§3 Auth',
    steps: 9,
    body: (step) => OauthFlowBody(step: step),
    speakerNotes: 'Step 7 is the whole point — nobody logged in again. The '
        'user saw nothing. Ask them where this lives in their Android app; '
        'answer is OkHttp Authenticator, which is slide 17.',
  ),
  SlideSpec(
    route: '/auth-interceptor',
    section: '§3 Auth',
    steps: 4,
    body: (step) => AuthInterceptorBody(step: step),
    speakerNotes: 'This is slide 16\'s steps 7 through 9, automated. Every '
        'platform has this exact shape — an interceptor sitting between '
        'the app and the network, watching for a 401 it can fix by itself. '
        'Walk the four highlighted lines, then land on the correlation: '
        'they already have this pattern under a different name.',
  ),
  SlideSpec(
    route: '/unsplash-reality',
    section: '§3 Auth',
    steps: 2,
    body: (step) => UnsplashRealityBody(step: step),
    speakerNotes: 'Say plainly: we taught you the full flow because that\'s '
        'what production looks like. Today\'s API needs one header. '
        'Knowing the difference is the skill.',
  ),

  // §4 Data
  SlideSpec(
    route: '/json-to-dart',
    section: '§4 Data',
    steps: 6,
    body: (step) => JsonToDartBody(step: step),
    speakerNotes: 'Four keys, four wires — call each one out as it flies. '
        'Step 5 is the reverse trip: same wires, toJson. Step 6 is the one '
        'that lands: every platform they know does this with reflection or '
        'an annotation processor. Dart has no runtime reflection, so '
        'someone writes the mapping — either you, by hand, or build_runner '
        'on slide 23.',
  ),
  SlideSpec(
    route: '/from-json-code',
    section: '§4 Data',
    steps: 5,
    body: (step) => FromJsonCodeBody(step: step),
    speakerNotes: 'Walk the highlighted lines, don\'t read the file. The '
        'two things worth saying out loud: `factory` is allowed to return a '
        'cached or subclass instance (that is the whole difference from a '
        'normal constructor), and the `as String` casts are where a bad '
        'response actually blows up — which is why this parsing lives '
        'behind the repository, not in build().',
  ),
  SlideSpec(
    route: '/live-map-model',
    section: '§4 Data',
    body: (step) => LiveMapModelBody(step: step),
    speakerNotes: 'Use their Day 1 Photo class as-is. Don\'t rename fields '
        'to match the API — the whole point is that the mapping layer '
        'absorbs the difference. If someone asks why not just use the JSON '
        'map directly, that is the repository discussion after the break.',
  ),
  SlideSpec(
    route: '/delete-hardcoded',
    section: '§4 Data',
    steps: 3,
    body: (step) => DeleteHardcodedBody(step: step),
    speakerNotes: 'Pause here. This is the moment. Step forward slowly and '
        'let them watch the characters morph — twelve lines they typed '
        'yesterday become one. Then let both screens fill from it. Don\'t '
        'talk over step 3.',
  ),
  SlideSpec(
    route: '/codegen',
    section: '§4 Data',
    steps: 2,
    body: (step) => CodegenBody(step: step),
    speakerNotes: 'Optional — only run this if you are ahead of schedule. '
        'Frame it as "you now understand exactly what it generates", which '
        'is why we did it by hand first. One sentence on build_runner '
        'being a compile step, not magic, then move.',
  ),
  SlideSpec(
    route: '/break',
    section: '§4 Data',
    chrome: false,
    body: (step) => BreakBody(step: step),
    speakerNotes: 'Actually take 15. Session 2 is the dense half.',
  ),
];
