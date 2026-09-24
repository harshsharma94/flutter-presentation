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
import 'package:flutter_bootcamp_deck/slides/s03_auth/auth_401_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/oauth_flow_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s03_auth/unsplash_reality_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/codegen_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/from_json_code_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/json_to_dart_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s04_data/live_map_model_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/dependency_rule_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/god_file_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/live_extract_repo_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s05_architecture/repository_slide.dart';
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
import 'package:flutter_bootcamp_deck/slides/s09_handson/assignment_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/design_to_tree_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s09_handson/row_contract_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s10_close/references_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s10_close/thanks_slide.dart';
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
    speakerNotes:
        '30 seconds, no more. Names, then move — slide 2 is the '
        'hook and you want them still settling in when it lands.',
  ),
  SlideSpec(
    route: '/beautiful-lie',
    section: '§0 Open',
    steps: 3,
    body: (step) => BeautifulLieBody(step: step),
    speakerNotes:
        'They built two screens off one hardcoded list. One '
        'change today fixes both — that\'s slide 18, where the list goes '
        'away for real. Ask: how many of you '
        'copy-pasted the list into the detail screen?',
  ),
  SlideSpec(
    route: '/roadmap',
    section: '§0 Open',
    steps: 5,
    body: (step) => RoadmapBody(step: step),
    speakerNotes:
        'Just orient them — five stops, in order, over today and '
        'tomorrow. Don\'t teach anything yet; this is a map, not a lesson. '
        'Come back to this spine at the start of every section.',
  ),
  SlideSpec(
    route: '/homework',
    section: '§0 Open',
    body: (step) => HomeworkBody(step: step),
    speakerNotes:
        '15 min. Pick 2–3 volunteers. Look for: a reusable row '
        'widget, ListView vs GridView choice, and whether navigation '
        'passes the whole model or just an id. That last one sets up the '
        'repository discussion in session 2.',
  ),

  // §1 API
  SlideSpec(
    route: '/api-gap',
    section: '§1 API',
    steps: 3,
    body: (step) => ApiGapBody(step: step),
    speakerNotes:
        'The phone and the internet don\'t just talk to each '
        'other — nothing bridges them yet. Let the empty space sit for a '
        'second before you advance. Step 2 is the naive, direct attempt '
        'failing; step 3 is the shape that actually works: Dio speaks '
        'HTTP, Repository decides when to call it, Model shapes what '
        'comes back. That three-box chain is what the rest of today '
        'builds inside.',
  ),
  SlideSpec(
    route: '/http-clients',
    section: '§1 API',
    steps: 3,
    body: (step) => HttpClientsBody(step: step),
    speakerNotes:
        'Dio is not new. It\'s the interceptor+client pair they '
        'already know. Don\'t sell it — just name the mapping and move to '
        'code.',
  ),
  SlideSpec(
    route: '/live-first-request',
    section: '§1 API',
    steps: 2,
    body: (step) => LiveFirstRequestBody(step: step),
    speakerNotes:
        'Picsum, not Unsplash: no key, no account, nothing to '
        'explain before §2 Auth. Type it live, don\'t paste: `final dio = '
        'Dio(); dio.get(\'https://picsum.photos/v2/list\').then((r) => '
        'print(r.data));`. Hold tap 2 back and let them try first — the '
        'constraint is the lesson, and they end up holding a Future they '
        'cannot open, which is exactly what the next two slides are for. '
        'If someone already knows await, let them write it, then ask for '
        'the .then version too so the room sees both. Full script and the '
        'stuck-point table are in docs/presenter-guide.md.',
  ),
  SlideSpec(
    route: '/future-states',
    section: '§1 API',
    steps: 4,
    body: (step) => FutureStatesBody(step: step),
    speakerNotes:
        'Define it before the next slide animates it. A Future '
        'is a receipt: you get it immediately, the value arrives later, and '
        'it settles exactly once. Step 2 is the branch every demo shows. '
        'Step 3 is the OTHER branch — say the word "or" out loud and point '
        'at both arrows. It did not become data and then fail; one of the '
        'two happens, once. The error branch is native to the model, not an '
        'edge case bolted on, which is why every await is choosing to '
        'handle two outcomes. Step 4 is the one that surprises people — no '
        'cancel(). You can ignore the result; the work still runs and the '
        'error still lands. Cancelling the request is the client\'s job '
        '(Dio\'s CancelToken), not the Future\'s.',
  ),
  SlideSpec(
    route: '/async-await',
    section: '§1 API',
    steps: 5,
    body: (step) => AsyncAwaitBody(step: step),
    speakerNotes:
        'This slide exists to break a wrong model, so do not rush it. '
        'One isolate, one thread, one event loop; a frame every 16ms. '
        'Step 2: the request goes to the socket, which is the OS — not '
        'your thread. The strip keeps flowing and the spinner keeps '
        'turning, ON PURPOSE. Ask them why. Dart has no blocking HTTP '
        'call, so a network request cannot freeze the UI with await or '
        'without it. Step 3: then what is await FOR? Being told. It is '
        '.then() unwrapped — sequential code, and try/catch that works. '
        'Step 4 is the honest exception: synchronous work on your thread, '
        'never yielding. The spinner dies. await cannot save this; '
        'Isolate.run can. Step 5: the correlation, WITH the caveat — '
        'Kotlin has Dispatchers.IO and Go has real threads, Dart has '
        'neither, so await never moves work anywhere. Rehearse forward '
        'and back: if the spinner freezes on step 2, or keeps turning on '
        'step 4, fix it before you present. Full answer and references '
        'are in docs/presenter-guide.md.',
  ),
  SlideSpec(
    route: '/error-swallowed',
    section: '§1 API',
    steps: 4,
    body: (step) => ErrorSwallowedBody(step: step),
    speakerNotes:
        'Step 1 is the two lines they wrote this morning — point at them '
        'and ask what happens when the wifi drops. Step 2 is the fix most '
        'people reach for: wrap it, and throw the error away. This '
        'compiles, runs, ships and passes review; no linter flags an empty '
        'catch. Step 3: let the clock actually climb from 5 to 30 while you '
        'keep talking — do not rush it, the discomfort IS the content. '
        'Step 4 is the punchline; say it plainly and then stop talking for '
        'a second.',
  ),
  SlideSpec(
    route: '/three-states-code',
    section: '§1 API',
    steps: 3,
    body: (step) => ThreeStatesCodeBody(step: step),
    speakerNotes:
        'The answer to the slide they just watched fail. One '
        'result type, three branches, and the compiler will not let you '
        'forget one — that is what sealed buys you over a bag of booleans. '
        'Walk the highlight: loading, error, data. Step 3 carries what the '
        'old platform-troubleshooting slide used to: the fastest way to see '
        'the error branch for real is wifi off or a bad host. If someone\'s '
        'app hangs instead of erroring, it is almost always the Android '
        'INTERNET permission or the macOS network entitlement.',
  ),
  SlideSpec(
    route: '/loading-state',
    section: '§1 API',
    body: (step) => LoadingStateBody(step: step),
    speakerNotes:
        'Hand the keyboard to someone. Make them click error. '
        'Ask what a user would do here. Let the silence sit — that\'s the '
        'point, not a gap to fill. Then click data and note it\'s pulling '
        'from the same offline fixture as slide 7, no live request risked. '
        'They have now seen the problem and the code that fixes it; this is '
        'the same three branches running, so let them drive and say very '
        'little.',
  ),

  // §2 Auth
  SlideSpec(
    route: '/auth-401',
    section: '§2 Auth',
    steps: 3,
    body: (step) => Auth401Body(step: step),
    speakerNotes:
        'A request with no credential just bounces — a flat 401, '
        'nothing more. Step 3\'s key is deliberately unexplained: where it '
        'comes from and how you keep it valid without asking the user to '
        'log in again every hour is the whole of slide 14.',
  ),
  SlideSpec(
    route: '/oauth-flow',
    section: '§2 Auth',
    steps: 8,
    body: (step) => OauthFlowBody(step: step),
    speakerNotes:
        'This is the phone\'s flow, not the web one they may have seen. '
        'Two things to say out loud. One: the login happens in an in-app '
        'browser tab your app cannot read — Chrome Custom Tabs on '
        'Android, ASWebAuthenticationSession on iOS — and it comes back '
        'as a deep link to a URI you registered. Never a WebView you own; '
        'that is how you end up handling someone\'s password. Two: step 5 '
        'sends a PKCE verifier, NOT a client secret. A shipped app is a '
        'public client; anything compiled into it can be pulled back out '
        'of the binary. Someone will ask where the secret goes — the '
        'answer is that there is not one. Step 8 is the beat the slide '
        'exists for: an hour passes, nobody logged in again, the user saw '
        'nothing. Ask them where the refresh-on-401 lives in their '
        'Android app; the answer is an OkHttp Authenticator.',
  ),
  SlideSpec(
    route: '/unsplash-reality',
    section: '§2 Auth',
    steps: 2,
    body: (step) => UnsplashRealityBody(step: step),
    speakerNotes:
        'Say plainly: we taught you the full flow because that\'s '
        'what production looks like. Today\'s API needs one header. '
        'Knowing the difference is the skill.',
  ),

  // §3 Data
  SlideSpec(
    route: '/json-to-dart',
    section: '§3 Data',
    steps: 6,
    body: (step) => JsonToDartBody(step: step),
    speakerNotes:
        'Four keys, four wires — call each one out as it flies. '
        'Step 5 is the reverse trip: same wires, toJson. Step 6 is the one '
        'that lands: every platform they know does this with reflection or '
        'an annotation processor. Dart has no runtime reflection, so '
        'someone writes the mapping — either you, by hand, or build_runner '
        'on slide 19.',
  ),
  SlideSpec(
    route: '/from-json-code',
    section: '§3 Data',
    steps: 5,
    body: (step) => FromJsonCodeBody(step: step),
    speakerNotes:
        'Walk the highlighted lines, don\'t read the file. The '
        'two things worth saying out loud: `factory` is allowed to return a '
        'cached or subclass instance (that is the whole difference from a '
        'normal constructor), and the `as String` casts are where a bad '
        'response actually blows up — which is why this parsing lives '
        'behind the repository, not in build().',
  ),
  SlideSpec(
    route: '/live-map-model',
    section: '§3 Data',
    body: (step) => LiveMapModelBody(step: step),
    speakerNotes:
        'Use their Day 1 Photo class as-is. Don\'t rename fields '
        'to match the API — the whole point is that the mapping layer '
        'absorbs the difference. If someone asks why not just use the JSON '
        'map directly, that is the repository discussion after the break.',
  ),
  SlideSpec(
    route: '/codegen',
    section: '§3 Data',
    steps: 3,
    body: (step) => CodegenBody(step: step),
    speakerNotes:
        'Optional — only run this if you are ahead of schedule. '
        'Frame it as "you now understand exactly what it generates", which '
        'is why we did it by hand first. The file on the left is whole, so '
        'they can type it: point at the two readValue helpers and say why '
        'they exist — @JsonSerializable maps a flat key for free, but '
        'Unsplash nests the image under urls.regular and the photographer '
        'under user.name, and codegen cannot guess a path. Step 1 is the '
        'three packages FIRST, and the thing people get wrong: two of them '
        'are dev dependencies. Wait for the room before you advance — the '
        'annotations do not resolve until pub get finishes. Step 2 is the '
        'file, whole, so they can type it. Step 3 runs it: one sentence on '
        'build_runner being a compile step, not magic, then move.',
  ),

  // §4 Architecture
  SlideSpec(
    route: '/god-file',
    section: '§4 Architecture',
    steps: 4,
    body: (step) => GodFileBody(step: step),
    speakerNotes:
        'This is their Day 1 file, honestly drawn. Point at the '
        'interleaving — the concerns are not in four tidy blocks, they are '
        'braided. Step 4 is the question that actually costs money: a bug '
        'report comes in and there is no obvious place to start reading. '
        'Ask how they would unit-test the sort rule here. They cannot.',
  ),
  SlideSpec(
    route: '/three-layers',
    section: '§4 Architecture',
    steps: 3,
    body: (step) => ThreeLayersBody(step: step),
    speakerNotes:
        'Same bands, same colours — say that out loud so they see '
        'it is a sort, not new code. Domain is the one to dwell on: no '
        'Flutter imports, no Dio, which is exactly why it is the layer you '
        'can test in milliseconds. Steps 6-8 are the payoff — they have '
        'already built this shape under three other names.',
  ),
  SlideSpec(
    route: '/dependency-rule',
    section: '§4 Architecture',
    steps: 4,
    body: (step) => DependencyRuleBody(step: step),
    speakerNotes:
        'One rule, and it is the only thing they need to '
        'memorise. Step 3 is the violation, and it is always the same '
        'violation in real code: an import of the HTTP client inside a '
        'rules file. Step 4 shows the cost — the domain test now needs '
        'DNS. Land it: the rule is not aesthetic, it is what keeps tests '
        'fast.',
  ),
  SlideSpec(
    route: '/repository',
    section: '§4 Architecture',
    steps: 3,
    body: (step) => RepositoryBody(step: step),
    speakerNotes:
        'Same knock, different door. Ask where they have seen '
        'this: Android Repository, Spring @Repository, a Go interface with '
        'two implementations. Then say the payoff out loud: a fake '
        'repository is a five-line class, and it works precisely because '
        'the caller only ever knew the door.',
  ),
  SlideSpec(
    route: '/live-extract-repo',
    section: '§4 Architecture',
    body: (step) => LiveExtractRepoBody(step: step),
    speakerNotes:
        'Do it as a refactor, not a rewrite. Cut the dio.get out '
        'of build(), paste it into PhotoRepository, inject it. Then ask '
        'what just got easier to test — let them answer.',
  ),

  // §5 State
  SlideSpec(
    route: '/state-problem',
    section: '§5 State',
    steps: 5,
    body: (step) => StateProblemBody(step: step),
    speakerNotes:
        'This is the tree for the next five slides — it never '
        'jumps, so they can keep their bearings. Step 2 is the one to sit '
        'on: point at HomeScreen and PhotoGrid and say they do not use '
        'photos at all, they just carry it. Step 5 is the second cost — '
        'setState at the root rebuilds everything below it.',
  ),
  SlideSpec(
    route: '/inherited-widget',
    section: '§5 State',
    steps: 9,
    body: (step) => InheritedWidgetBody(step: step),
    speakerNotes:
        'Step 3 is the one they will remember — let the pulse '
        'finish travelling before you talk. Then say it out loud: the '
        'lookup is O(1), not a tree walk at runtime, because Flutter '
        'caches it per element. The animation shows the conceptual walk, '
        'not the runtime cost. Step 5 is the payoff over slide 25: only '
        'subscribers rebuild.',
  ),
  SlideSpec(
    route: '/inherited-limits',
    section: '§5 State',
    steps: 2,
    body: (step) => InheritedLimitsBody(step: step),
    speakerNotes:
        'This slide exists so ChangeNotifier looks necessary '
        'instead of arbitrary. Do not skip it. The field is final — it has '
        'to be, that is what makes the lookup safe — so changing the data '
        'means rebuilding the whole scope from above.',
  ),
  SlideSpec(
    route: '/change-notifier',
    section: '§5 State',
    steps: 7,
    body: (step) => ChangeNotifierBody(step: step),
    speakerNotes:
        'The question this slide answers is WHO IS LISTENING. Read the '
        'right-hand column out loud, one line per tap; the diagram is the '
        'illustration, the sentences are the slide. Step 1: one object '
        'holds the number and a list of interested parties — say the word '
        '\'list\', it demystifies the whole thing. Step 2: both LikeButtons '
        'add themselves to that list. Step 3: the button is OUTSIDE the '
        'tree on purpose — say that it stands for tapping either heart, '
        'and that the number is not the tile\'s own state. Let them tap it '
        'several times; it is a real ChangeNotifier. Step 4: the tiles '
        'flash because they are on the list, and nothing else in the tree '
        'moves. Step 5 is the production bug — come off the list or the '
        'model rebuilds a dead widget. Steps 6-7: they already have this '
        'under another name.',
  ),
  SlideSpec(
    route: '/provider-fusion',
    section: '§5 State',
    steps: 3,
    body: (step) => ProviderFusionBody(step: step),
    speakerNotes:
        'Say it as arithmetic, because that is how it is drawn: '
        'InheritedWidget solves reach and cannot change; ChangeNotifier '
        'changes and cannot be found; neither solves the other. Both boxes '
        'stay on screen when the third arrives — point at all three and '
        'say Provider IS those two, it does not replace them. That is the '
        'whole slide, and it is why nobody should feel they are learning a '
        'new library here. Step 3 is the receipt: that is the exact '
        'wrapper from slide 27, and the three lines beside it are what '
        'delete it. Let them read it rather than telling them it is '
        'shorter.',
  ),
  SlideSpec(
    route: '/watch-read-consumer',
    section: '§5 State',
    body: (step) => WatchReadConsumerBody(step: step),
    speakerNotes:
        'Read the three legend entries FIRST — this is the only slide '
        'that names context.watch, context.read and Consumer, and three API '
        'names arriving at once will lose people otherwise. Say the '
        'headline out loud: all three read the SAME CounterModel from the '
        'same provider; the only difference is how much of the tree hears '
        'about notifyListeners(). Then hand over the keyboard. Do not '
        'assert that Consumer is better — make them watch the flash region '
        'shrink and the rebuild counter drop. The read() mode is the trap '
        'worth showing: the number never moves, because read never '
        'subscribes. Then ask which one they would reach for by default.',
  ),

  SlideSpec(
    route: '/state-decision',
    section: '§5 State',
    steps: 4,
    body: (step) => StateDecisionBody(step: step),
    speakerNotes:
        'Three rows, and the honest advice is to start at the top '
        'and only move down when something forces you. Most screens never '
        'leave row one. Step 4 matters for the ones who have already read '
        'about Bloc: those tools solve problems they do not have yet.',
  ),
  SlideSpec(
    route: '/live-convert-provider',
    section: '§5 State',
    body: (step) => LiveConvertProviderBody(step: step),
    speakerNotes:
        'List screen first, then detail. The detail screen is the '
        'interesting one — ask whether it should read the provider or take '
        'the model as a constructor argument. Both are defensible; make '
        'them argue it.',
  ),

  // §6 DI
  SlideSpec(
    route: '/di-problem',
    section: '§6 DI',
    steps: 3,
    body: (step) => DiProblemBody(step: step),
    speakerNotes:
        'This is slide 25 again, but for services instead of '
        'data — say that, they will see it. Step 3 is the cost that '
        'actually shows up in review: adding one dependency means editing '
        'every constructor between main and the leaf.',
  ),
  SlideSpec(
    route: '/di-multiprovider',
    section: '§6 DI',
    steps: 5,
    body: (step) => DiMultiproviderBody(step: step),
    speakerNotes:
        'Say it explicitly: Provider is already in the app for '
        'state, so DI costs them zero new packages and zero build_runner. '
        'Note that Provider(create:) is lazy by default. Mention get_it '
        'exists in one sentence and move on — do not teach it.',
  ),
  SlideSpec(
    route: '/di-testing',
    section: '§6 DI',
    steps: 2,
    body: (step) => DiTestingBody(step: step),
    speakerNotes:
        'Slide 23\'s one door, now at the wiring '
        'level. This is the answer to "why bother with DI": one line, and '
        'the whole tree is testable. Point out the type argument on '
        'Provider<PhotoRepository> — that is what makes the swap '
        'type-safe.',
  ),

  // §7 Folder structure
  SlideSpec(
    route: '/structure',
    section: '§7 Folder structure',
    steps: 8,
    body: (step) => StructureBody(step: step),
    speakerNotes:
        'Don\'t debate folder philosophy. Point out it\'s the '
        'same structure they used in Android, renamed. The rule that '
        'matters: feature-first beats type-first as soon as you have two '
        'features.',
  ),

  // §8 Hands-on
  SlideSpec(
    route: '/design-to-tree',
    section: '§8 Hands-on',
    steps: 7,
    body: (step) => DesignToTreeBody(step: step),
    speakerNotes:
        'Make them call out the widget before you reveal it. This '
        'is the actual skill — reading a design as a hierarchy. Do not '
        'rush it. Ask why ListView.builder and not a Column of six rows; '
        'the answer is that the count comes from the server.',
  ),
  SlideSpec(
    route: '/row-contract',
    section: '§8 Hands-on',
    steps: 4,
    body: (step) => RowContractBody(step: step),
    speakerNotes:
        'One row, two possible answers from the server. Tap 1 lights the '
        'row; tap 2 draws the line to the response. Tap 3: every string on '
        'that row — the title, the balance line, even which control to '
        'draw — arrived in the response. Tap 4 is the same row as raw '
        'fields, and the question to actually ask and wait for: design '
        'wants the balance line reworded on Friday. Who ships? Be fair to '
        'the second shape — it is the right call when the client genuinely '
        'owns presentation, or when several very different clients share '
        'one endpoint. Do not name the pattern or argue the trade-off '
        'further; that is day 3.',
  ),
  SlideSpec(
    route: '/assignment',
    section: '§8 Hands-on',
    steps: 3,
    body: (step) => AssignmentBody(step: step),
    speakerNotes:
        'Three tasks, in this order — each one depends on the '
        'last. Tell them item 2 is the one that gets skipped and the one '
        'that gets asked about tomorrow.',
  ),

  // §9 Close
  SlideSpec(
    route: '/references',
    section: '§9 References',
    steps: 6,
    body: (step) => ReferencesBody(step: step),
    speakerNotes:
        'Do not read these out. Tell them the deck is on GitHub '
        'and point at exactly two: the async-await codelab tonight, and '
        'the Flutter app-architecture guide this weekend. Everything else '
        'is for when they hit the problem it solves.',
  ),
  SlideSpec(
    route: '/thanks',
    section: '§9 References',
    chrome: false,
    body: (step) => ThanksBody(step: step),
    speakerNotes:
        'Q&A. If it goes quiet, prompt with the one from slide '
        '30: which reader would you reach for by default, and why?',
  ),
];
