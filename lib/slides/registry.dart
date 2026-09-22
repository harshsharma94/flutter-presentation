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
import 'package:flutter_bootcamp_deck/slides/s05_architecture/dependency_rule_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/god_file_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/live_extract_repo_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/repository_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/testability_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/three_layers_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/change_notifier_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/inherited_limits_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/inherited_widget_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/provider_fusion_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/state_problem_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/watch_read_consumer_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/live_convert_provider_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s06_state/state_decision_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s07_di/di_multiprovider_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s07_di/di_problem_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s07_di/di_testing_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s08_dart/cascade_spread_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s08_dart/named_params_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/assignment_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_row_error_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_row_plain_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_row_warning_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/bff_vs_nonbff_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/design_to_tree_slide.dart';
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

  // §5 Architecture
  SlideSpec(
    route: '/god-file',
    section: '§5 Architecture',
    steps: 4,
    body: (step) => GodFileBody(step: step),
    speakerNotes: 'This is their Day 1 file, honestly drawn. Point at the '
        'interleaving — the concerns are not in four tidy blocks, they are '
        'braided. Step 4 is the question that actually costs money: a bug '
        'report comes in and there is no obvious place to start reading. '
        'Ask how they would unit-test the sort rule here. They cannot.',
  ),
  SlideSpec(
    route: '/three-layers',
    section: '§5 Architecture',
    steps: 8,
    body: (step) => ThreeLayersBody(step: step),
    speakerNotes: 'Same bands, same colours — say that out loud so they see '
        'it is a sort, not new code. Domain is the one to dwell on: no '
        'Flutter imports, no Dio, which is exactly why it is the layer you '
        'can test in milliseconds. Steps 6-8 are the payoff — they have '
        'already built this shape under three other names.',
  ),
  SlideSpec(
    route: '/dependency-rule',
    section: '§5 Architecture',
    steps: 4,
    body: (step) => DependencyRuleBody(step: step),
    speakerNotes: 'One rule, and it is the only thing they need to '
        'memorise. Step 3 is the violation, and it is always the same '
        'violation in real code: an import of the HTTP client inside a '
        'rules file. Step 4 shows the cost — the domain test now needs '
        'DNS. Land it: the rule is not aesthetic, it is what keeps tests '
        'fast.',
  ),
  SlideSpec(
    route: '/testability',
    section: '§5 Architecture',
    steps: 3,
    body: (step) => TestabilityBody(step: step),
    speakerNotes: 'Watch the Domain slab as the swap happens — it does not '
        'move a pixel. That is the point. 2400ms to 3ms is not a '
        'micro-optimisation, it is the difference between a suite you run '
        'on every save and one you run in CI and ignore.',
  ),
  SlideSpec(
    route: '/repository',
    section: '§5 Architecture',
    steps: 3,
    body: (step) => RepositoryBody(step: step),
    speakerNotes: 'Same knock, different door. Ask where they have seen '
        'this: Android Repository, Spring @Repository, a Go interface with '
        'two implementations. Then make the connection back to slide 28 — '
        'the fake repository worked precisely because the caller only ever '
        'knew the door.',
  ),
  SlideSpec(
    route: '/live-extract-repo',
    section: '§5 Architecture',
    body: (step) => LiveExtractRepoBody(step: step),
    speakerNotes: 'Do it as a refactor, not a rewrite. Cut the dio.get out '
        'of build(), paste it into PhotoRepository, inject it. Then ask '
        'what just got easier to test — let them answer.',
  ),

  // §6 State
  SlideSpec(
    route: '/state-problem',
    section: '§6 State',
    steps: 5,
    body: (step) => StateProblemBody(step: step),
    speakerNotes: 'This is the tree for the next five slides — it never '
        'jumps, so they can keep their bearings. Step 2 is the one to sit '
        'on: point at HomeScreen and PhotoGrid and say they do not use '
        'photos at all, they just carry it. Step 5 is the second cost — '
        'setState at the root rebuilds everything below it.',
  ),
  SlideSpec(
    route: '/inherited-widget',
    section: '§6 State',
    steps: 8,
    body: (step) => InheritedWidgetBody(step: step),
    speakerNotes: 'Step 3 is the one they will remember — let the pulse '
        'finish travelling before you talk. Then say it out loud: the '
        'lookup is O(1), not a tree walk at runtime, because Flutter '
        'caches it per element. The animation shows the conceptual walk, '
        'not the runtime cost. Step 5 is the payoff over slide 31: only '
        'subscribers rebuild.',
  ),
  SlideSpec(
    route: '/inherited-limits',
    section: '§6 State',
    steps: 2,
    body: (step) => InheritedLimitsBody(step: step),
    speakerNotes: 'This slide exists so ChangeNotifier looks necessary '
        'instead of arbitrary. Do not skip it. The field is final — it has '
        'to be, that is what makes the lookup safe — so changing the data '
        'means rebuilding the whole scope from above.',
  ),
  SlideSpec(
    route: '/change-notifier',
    section: '§6 State',
    steps: 9,
    body: (step) => ChangeNotifierBody(step: step),
    speakerNotes: 'Let them tap it several times — it is a real '
        'ChangeNotifier, not a drawing of one. Every arrow is labelled with '
        'the real method name; point at each as you say it. Step 6 is the '
        'one people forget in production: dispose, or the listener outlives '
        'the widget and you leak.',
  ),
  SlideSpec(
    route: '/provider-fusion',
    section: '§6 State',
    steps: 3,
    body: (step) => ProviderFusionBody(step: step),
    speakerNotes: 'Say it as arithmetic: InheritedWidget solves reach, '
        'ChangeNotifier solves change, and neither solves the other. '
        'Provider is not a new concept — it is the two they just learned, '
        'wired together so they stop writing the wrapper from slide 33.',
  ),
  SlideSpec(
    route: '/watch-read-consumer',
    section: '§6 State',
    body: (step) => WatchReadConsumerBody(step: step),
    speakerNotes: 'Hand over the keyboard. Do not assert that Consumer is '
        'better — make them watch the flash region shrink and the counter '
        'drop. Then ask which one they would reach for by default. The '
        'read() mode is the trap worth showing: the number never moves '
        'because read never subscribes.',
  ),

  SlideSpec(
    route: '/state-decision',
    section: '§6 State',
    steps: 4,
    body: (step) => StateDecisionBody(step: step),
    speakerNotes: 'Three rows, and the honest advice is to start at the top '
        'and only move down when something forces you. Most screens never '
        'leave row one. Step 4 matters for the ones who have already read '
        'about Bloc: those tools solve problems they do not have yet.',
  ),
  SlideSpec(
    route: '/live-convert-provider',
    section: '§6 State',
    body: (step) => LiveConvertProviderBody(step: step),
    speakerNotes: 'List screen first, then detail. The detail screen is the '
        'interesting one — ask whether it should read the provider or take '
        'the model as a constructor argument. Both are defensible; make '
        'them argue it.',
  ),

  // §7 DI
  SlideSpec(
    route: '/di-problem',
    section: '§7 DI',
    steps: 3,
    body: (step) => DiProblemBody(step: step),
    speakerNotes: 'This is slide 31 again, but for services instead of '
        'data — say that, they will see it. Step 3 is the cost that '
        'actually shows up in review: adding one dependency means editing '
        'every constructor between main and the leaf.',
  ),
  SlideSpec(
    route: '/di-multiprovider',
    section: '§7 DI',
    steps: 5,
    body: (step) => DiMultiproviderBody(step: step),
    speakerNotes: 'Say it explicitly: Provider is already in the app for '
        'state, so DI costs them zero new packages and zero build_runner. '
        'Note that Provider(create:) is lazy by default. Mention get_it '
        'exists in one sentence and move on — do not teach it.',
  ),
  SlideSpec(
    route: '/di-testing',
    section: '§7 DI',
    steps: 2,
    body: (step) => DiTestingBody(step: step),
    speakerNotes: 'Callback to slide 28 — same idea, now at the wiring '
        'level. This is the answer to "why bother with DI": one line, and '
        'the whole tree is testable. Point out the type argument on '
        'Provider<PhotoRepository> — that is what makes the swap '
        'type-safe.',
  ),

  // §8 Dart bits
  SlideSpec(
    route: '/named-params',
    section: '§8 Dart',
    steps: 3,
    body: (step) => NamedParamsBody(step: step),
    speakerNotes: 'Ask them, before step 2, which argument is which. '
        'Someone will get it wrong. That is the slide. Then the morph — '
        'same call, readable at the call site, and now the compiler '
        'enforces required.',
  ),
  SlideSpec(
    route: '/cascade-spread',
    section: '§8 Dart',
    steps: 2,
    body: (step) => CascadeSpreadBody(step: step),
    speakerNotes: 'Ninety seconds total. They will meet both in the '
        'codebase today; they do not need a lecture. If anyone asks: '
        'cascade returns the receiver, which is why it chains, and spread '
        'is what lets you build a children list conditionally without a '
        'helper function.',
  ),

  // §9 Hands-on
  SlideSpec(
    route: '/design-to-tree',
    section: '§9 Hands-on',
    steps: 7,
    body: (step) => DesignToTreeBody(step: step),
    speakerNotes: 'Make them call out the widget before you reveal it. This '
        'is the actual skill — reading a design as a hierarchy. Do not '
        'rush it. Ask why ListView.builder and not a Column of six rows; '
        'the answer is that the count comes from the server.',
  ),
  SlideSpec(
    route: '/bff-row-plain',
    section: '§9 Hands-on',
    steps: 4,
    body: (step) => BffRowPlainBody(step: step),
    speakerNotes: 'Start with the ordinary row so the next two read as the '
        'same machinery with different data. Point at cta.type and say it '
        'out loud: the client switches on a string the server sent, not on '
        'which row this is.',
  ),
  SlideSpec(
    route: '/bff-row-warning',
    section: '§9 Hands-on',
    steps: 4,
    body: (step) => BffRowWarningBody(step: step),
    speakerNotes: 'Same widget, different tone — and the tone came from '
        'color_token, not from an if. Ask what the client would need to '
        'change to add a fourth tone. Answer: nothing, if the token '
        'mapping already covers it.',
  ),
  SlideSpec(
    route: '/bff-row-error',
    section: '§9 Hands-on',
    steps: 4,
    body: (step) => BffRowErrorBody(step: step),
    speakerNotes: 'The disabled case, plus the per-platform action map. '
        'Land the question at the end and actually wait for an answer: '
        'design wants a new state — who ships? On the left nobody; on a '
        'client-driven contract, everybody.',
  ),
  SlideSpec(
    route: '/bff-vs-nonbff',
    section: '§9 Hands-on',
    steps: 4,
    body: (step) => BffVsNonBffBody(step: step),
    speakerNotes: 'Optional — cut this if time is short, slides 45-47 '
        'already made the point. If you run it, be fair to the right-hand '
        'side: a raw resource contract is the right call when the client '
        'genuinely owns presentation, or when several very different '
        'clients share one endpoint.',
  ),
  SlideSpec(
    route: '/assignment',
    section: '§9 Hands-on',
    steps: 3,
    body: (step) => AssignmentBody(step: step),
    speakerNotes: 'Three tasks, in this order — each one depends on the '
        'last. Tell them item 2 is the one that gets skipped and the one '
        'that gets asked about tomorrow.',
  ),
];
