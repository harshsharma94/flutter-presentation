# Flutter Bootcamp — Day 2 Deck: Design

**Date:** 2026-09-22
**Author:** Harsh Sharma (with Claude)
**Status:** Approved for planning

---

## 1. Context

Day 2 of an internal Flutter bootcamp for new joiners, fresh out of college. They are
**not** beginners in software — they have spent ~2 months on Android, iOS, Java backend
and Go. They are beginners in Flutter only.

Day 1 covered: Dart basics, what/why Flutter, building UI, `StatefulWidget` vs
`StatelessWidget`, navigation.

**Day 1 homework (confirmed):** a multi-screen Flutter app — navigation between screens,
stateful and stateless widgets, a reusable widget rendered through `ListView`/`GridView`,
fed by a **hardcoded list of models**.

That shape drives everything below. They arrive on Day 2 holding a **list screen and a
detail screen**, both backed by the same hardcoded list. So Day 2 maps onto their own code
exactly:

- list screen  -> `GET /photos`
- detail screen -> `GET /photos/:id`
- their reusable row/tile widget -> the thing the API contract has to feed (§9)

The whole of Day 2 is the act of deleting that hardcoded list from both screens.

Day 2 topic: **State Management & Architecture.**
Coach: Harsh Sharma. Assistant coaches: Harsh, Abhas.
Two sessions, ~2 hours each, with a break between.

## 2. Goals

- A `flutter_deck` presentation that is **minimal, visual, and live-coding-first**.
- The deck carries the *pictures*; the coach carries the *words*.
- Animations exist to **explain mechanism**, never to decorate.
- Correlate to Android / iOS / Java-BE / Go concepts, but only where the analogy earns it.
- Every animation is **step-driven and reversible** so the coach can step backward to
  re-explain when a question interrupts.

## 3. Non-goals

- **Not** a reference app. Deck only. (Explicit decision.)
- Not a starter skeleton for bootcampers.
- Not a written teaching document — slides must be unreadable as a standalone artifact.
  If a slide makes sense without a presenter, it has too much text.
- No slide-transition showmanship. Transition between slides is a plain fade.

## 4. Decisions (and why)

| Decision | Choice | Rationale |
|---|---|---|
| Deliverable | Deck only | User decision. Live demos embed in slides instead of a separate app. |
| Slide budget | Driven by content, not clock | "Minimal, to the point"; time goes to live coding, not slides. |
| Codegen | Hand-write first, one `build_runner` payoff demo at the end | Hand-writing `fromJson` is the part that teaches. Codegen shown as payoff, marked skippable, so a `part 'x.g.dart'` error can never derail the main path. |
| DI | `Provider` **is** the DI container | Zero new packages — they already learn Provider for state. Maps 1:1 to Hilt `@Module` / Koin `module {}` / Spring `@Bean`. Avoids a second mental model (get_it's global registry). |
| Auth | Teach generic OAuth2, then show Unsplash's reality | Unsplash's public API takes a static `Client-ID` header — no refresh, no expiry. Teaching refresh-with-Unsplash would be teaching a fiction. Animate the real-world flow they will meet at work, then contrast it with what today actually needs. The contrast *is* the lesson. |
| Hands-on screen | Rebuild the real GoPay "Select payment method" screen | It is their own product; recognition value is high, and payment rows vary richly (title styles, description states, CTA types, action maps) in a way photo rows do not. |
| Deck identity | "GoPay · Flutter Bootcamp" on the title slide and footer | User decision. |
| Section orientation | flutter_deck's built-in per-slide header + a roadmap chip, **no divider slides** | Decided (open question 3). Rationale in §8.1 — orientation without spending slides. |
| Theme | Near-black slate + GoPay blue + Gojek green | Accents carry **semantic** roles, not decoration: blue = Flutter/new, green = what you already know. Two-tone correlation panels are therefore readable at a glance, and every other slide stays monochrome and quiet. |

## 5. Prerequisites

`flutter_deck` 0.29.0 requires **Flutter >= 3.32.0 / Dart >= 3.8.0**. The local `fvm`
cache tops out at 3.27.2 (Dart 3.6.1), so a newer Flutter must be installed.

**Why not just pin an older flutter_deck?** 0.19.0 (May 2025) is the last release that runs
on 3.27.2 — 0.20.0 onward requires 3.32.0. The cost of staying on 0.19.0 is specific:
**0.28.0 is the release that reworked `FlutterDeckCodeHighlight`**, adding
`highlightedLines` and *exact code-piece cross-fading on dynamic code updates* via
`diff_match_patch`. That cross-fade **is** A16's character-morph (the peak of session 1)
and A33's; `highlightedLines` drives A12 and the code steps on slides 14 and 21. On 0.19.0
those degrade to plain swaps, or I hand-roll a diff animation the library now ships.
Upgrading Flutter is the cheaper side of that trade.

**Why 3.47.5 specifically?** No strong reason — any >= 3.32.0 works and the download is the
same size, so latest stable is simply the default. Two mitigations worth recording:
`fvm use` writes `.fvmrc` in this directory only, so other projects and the system `dart`
are untouched; and if 3.47.5 (2026-09-18) disagrees with flutter_deck 0.29.0 (2026-07-01),
dropping to a stable nearer the package's release date is a one-command fix.

Install:

```
fvm install 3.47.5      # latest stable, released 2026-09-18, ~1GB, one-time
fvm use 3.47.5
```

All Flutter/Dart commands in this project run through `fvm`.

## 6. Dependencies

| Package | Why |
|---|---|
| `flutter_deck ^0.29.0` | The deck framework |
| `google_fonts` | Type. **Fonts are bundled as assets, not fetched at runtime** — the deck must render with no network. |
| `dio` | The live API demo slide makes a *real* request |
| `provider` | The Provider / `watch` vs `read` vs `Consumer` demo slides use the *real* package |
| `flutter_deck_web_client` | Presenter view (speaker notes on a second screen) |

Live demos use the real packages. Nothing in this deck simulates a library it is teaching.

## 7. Architecture

### 7.1 File layout

```
lib/
  main.dart                  FlutterDeckApp: configuration, theme, slide list
  theme/
    palette.dart             colour tokens
    deck_theme.dart          FlutterDeckThemeData light + dark
    tokens.dart              spacing, durations, curves
  widgets/
    step_reveal.dart         THE primitive (7.2)
    correlation_panel.dart   two-tone "you know X -> Flutter is Y"
    live_badge.dart          the (LIVE) handoff marker
    annotate.dart            self-drawing arrows, callouts, dashed boxes
    phone_frame.dart         device chrome for embedded demos
    widget_tree.dart         the shared, evolving tree used across all of §6
    code_panel.dart          thin wrapper over FlutterDeckCodeHighlight
  demos/
    three_state_demo.dart    #8   real AnimatedSwitcher
    notifier_demo.dart       #26  real ChangeNotifier + real button
    rebuild_scope_demo.dart  #28  real Provider + rebuild-flash overlay
    unsplash_client.dart     real Dio client + offline fixture fallback
  slides/
    s00_open/ s01_structure/ s02_api/ s03_auth/ s04_data/
    s05_architecture/ s06_state/ s07_di/ s08_dart/ s09_handson/ s10_close/
assets/
  fonts/                     bundled, for offline rendering
  fixtures/unsplash.json     offline fallback for the live request
  images/gopay/              payment screen iconography
```

One file per slide. Per project coding standards: many small files, 200–400 lines typical.

### 7.2 The one primitive

`FlutterDeckSlideStepsBuilder` supplies a `stepNumber` that rebuilds on arrow-key
navigation. Everything is built on a single wrapper over it:

```dart
StepReveal(atStep: 3, child: ...)   // fades/slides in at step 3, dims at later steps
```

Consequences, and the reason this is the most important decision in the deck:

- Every animation is **paced by the presenter**, not by a timer.
- Every animation is **reversible** — step backward to re-explain.
- Animations survive deep-linking (flutter_deck routes each slide, and
  `FlutterDeckSlideStepsBuilder` restores step state on direct navigation).
- Animation state is derived from `stepNumber`, never from mutable local state, so slides
  are pure functions of `(step, theme)` — which is what makes the smoke test in §11 possible.

### 7.3 Motion language

Applied uniformly so the deck reads calm rather than busy:

- 300ms fades, 400ms travel, one easing curve (`Curves.easeOutCubic`) throughout.
- No bounce, no overshoot, no parallax, no confetti.
- At most two things moving at once.
- Completed steps dim to 40% opacity rather than disappearing — the audience keeps the
  context of what came before.
- Slide-to-slide transition: `FlutterDeckTransition.fade()`. Nothing more.

### 7.4 Theme

```
base       #0B0E13   near-black slate
surface    #141922
blue       #118EEA   GoPay  — "Flutter / the new thing"
green      #00AA5B   Gojek  — "what you already know"
amber      #F5A623   warning states
red        #E5484D   error states
text       #E8EDF4 primary / #93A1B5 secondary
```

Light theme mirrors it (`#FFFFFF` / `#F4F7FB` ground, same accents) since flutter_deck
ships a theme toggle. Display type: Outfit. Code: JetBrains Mono. Both bundled.

Slide size: 16:9, FHD resolution.

### 7.5 Secrets

The Unsplash access key is supplied at run time and **never committed**:

```
fvm flutter run -d chrome --dart-define=UNSPLASH_ACCESS_KEY=xxx
```

Read via `String.fromEnvironment('UNSPLASH_ACCESS_KEY')`. If the key is absent **or the
request fails**, the live demo falls back to `assets/fixtures/unsplash.json` and shows a
small "offline fixture" chip. The deck must never die on stage because of conference wifi.

## 8. Slide outline

51 slides. ~20 are single-visual animation frames with under 10 words on them; 7 are
`(LIVE)` handoff slides that are nearly empty by design — a title, the goal, and the
coding script hidden in speaker notes. Actual reading matter is ~24 slides.

Animation IDs (`A1`–`A37`) refer to §9.

### 8.1 Section orientation — no divider slides

A 58-slide deck needs the audience to know where they are, especially after a 20-minute
live-coding block. Spending three slides on dividers would fight the "minimal" goal, so
instead:

- **Every slide sets `FlutterDeckHeaderConfiguration(title: '<section name>')`.** Built
  into flutter_deck, costs nothing, and the section name is on screen permanently.
- **Section-opening slides carry a small roadmap chip** (a minimised A2 with the current
  node lit) in the top-right.
- The footer already shows slide numbers and the gradient progress indicator runs along
  the bottom.

Net effect: continuous orientation, zero extra slides.

| # | Route | Content | Anim | Steps |
|---|---|---|---|---|
| **§0 Open** |
| 1 | `/title` | Day 2 — Making It Real. Coach + assistant coaches | — | — |
| 2 | `/beautiful-lie` | Yesterday you built a beautiful lie (list + detail) | A1 | 3 |
| 3 | `/roadmap` | Today's arc | A2 | 5 |
| 4 | `/homework` | (LIVE) Day 1 homework review | — | — |
| **§1 Folder structure** |
| 5 | `/structure` | lib/ layout, Android equivalent, 3 rules for where code goes | A3 | 9 |
| **§2 API integration** |
| 6 | `/api-gap` | UI <- ? -> Internet | A4 | 3 |
| 7 | `/http-clients` | Correlation: Retrofit/URLSession/RestTemplate/net-http -> Dio | A5 | 4 |
| 8 | `/live-first-request` | (LIVE) first GET, print the JSON | — | — |
| 9 | `/async-await` | The frozen frame | A6 | 4 |
| 10 | `/future-states` | Future<T>: pending / data / error | A7 | 3 |
| 11 | `/loading-state` | (LIVE) three-state switch, interactive | A8 | — |
| 12 | `/error-swallowed` | What an empty catch block costs the user | A9 | 3 |
| 13 | `/three-states-code` | The switch, in code | — | 3 |
| 14 | `/when-it-breaks` | INTERNET permission, macOS entitlement, CORS | — | 3 |
| **§3 Auth** |
| 15 | `/auth-401` | Why auth exists | A10 | 3 |
| 16 | `/oauth-flow` | OAuth2 sequence diagram | A11 | 9 |
| 17 | `/auth-interceptor` | Dio interceptor, annotated | A12 | 4 |
| 18 | `/unsplash-reality` | What Unsplash actually needs + key hygiene | A13 | 2 |
| **§4 Data -> UI** |
| 19 | `/json-to-dart` | JSON morphs into a Dart object; +serialization correlation | A14 | 6 |
| 20 | `/from-json-code` | fromJson anatomy; factory constructors taught here | — | 5 |
| 21 | `/live-map-model` | (LIVE) map the response onto their Day-1 model | — | — |
| 22 | `/delete-hardcoded` | **Delete the hardcoded list** (both screens) | A16 | 3 |
| 23 | `/codegen` | build_runner payoff (skippable) | A17 | 2 |
| **Break** |
| 24 | `/break` | Break | — | — |
| **§5 Architecture** |
| 25 | `/god-file` | The 600-line widget file | A18 | 4 |
| 26 | `/three-layers` | Presentation/Domain/Data assemble; +MVVM/VIPER/Spring correlation | A19 | 8 |
| 27 | `/dependency-rule` | Point inward, or burn | A20 | 4 |
| 28 | `/testability` | Swap the data layer, 2400ms -> 3ms | A21 | 3 |
| 29 | `/repository` | One door, two sources | A22 | 3 |
| 30 | `/live-extract-repo` | (LIVE) extract the repository | — | — |
| **§6 State management** — one continuous tree |
| 31 | `/state-problem` | Prop drilling + callback hell | A23 | 5 |
| 32 | `/inherited-widget` | Reaching up the tree; +CompositionLocal/@Environment correlation | A24 | 8 |
| 33 | `/inherited-limits` | It's immutable — so what changes it? | A25 | 2 |
| 34 | `/change-notifier` | The pulse, annotated; +LiveData/StateFlow/@Published correlation | A26 | 9 |
| 35 | `/provider-fusion` | Provider = the two, married | A27 | 3 |
| 36 | `/watch-read-consumer` | (LIVE) rebuild scope, interactive | A28 | — |
| 37 | `/state-decision` | When to use which | A29 | 4 |
| 38 | `/live-convert-provider` | (LIVE) convert list + detail to Provider | — | — |
| **§7 DI** |
| 39 | `/di-problem` | main.dart spaghetti | A30 | 3 |
| 40 | `/di-multiprovider` | MultiProvider collapse; +Hilt/Koin/@Bean/wire correlation | A31 | 5 |
| 41 | `/di-testing` | One line, and the tree is under test | A32 | 2 |
| **§8 Dart bits** |
| 42 | `/named-params` | Which string was which? | A33 | 3 |
| 43 | `/cascade-spread` | `..` and `...` | A34 | 2 |
| **§9 Hands-on** |
| 44 | `/design-to-tree` | GoPay screen -> widget tree, grows on tap | A35 | 7 |
| 45 | `/bff-row-plain` | Contract reveal: plain row | A36a | 4 |
| 46 | `/bff-row-warning` | Contract reveal: warning + info CTA | A36b | 4 |
| 47 | `/bff-row-error` | Contract reveal: error + disabled + deep link | A36c | 4 |
| 48 | `/bff-vs-nonbff` | Where the business logic lands | A37 | 4 |
| 49 | `/assignment` | Tonight's homework | — | 3 |
| **§10 Close** |
| 50 | `/references` | Official + best community resource per concept | — | 6 |
| 51 | `/thanks` | Thank you / Q&A | — | — |

**Governing principle (applied 2026-09-22, 58 -> 51 slides):**

> Correlation is the **final step of the concept slide**, never a slide of its own.

The Android/iOS/BE analogy lands harder while the diagram it explains is still on screen,
and a separate slide forces the audience to rebuild the context they just lost. Seven
standalone correlation/rules slides were folded into their parents as extra steps
(5, 20, 28, 35, 38, 45), and factory constructors became a callout on slide 21 where the
bootcampers actually meet one (`Photo.fromJson`). Same content, better placement.

**First cut candidates if the deck still runs long:** 23 (codegen payoff),
48 (non-BFF contrast), 13 (three-states code — slide 11 already shows it running live).

## 9. Animation catalogue

All 37. `(LIVE)` = real, tappable widgets rather than a step animation.
Stars mark load-bearing animations — the ones where the animation *is* the explanation.

### §0 Open
- **A1 — The beautiful lie** (3). Their Day-1 app: a polished list screen and the detail
  screen it navigates to, side by side. Both tilt up to reveal **the same hardcoded
  `List<Photo>` feeding both**, and a strikethrough animates across it. The shared source
  is the point — it is why one change fixes both screens later (A16).
- **A2 — Roadmap spine** (5). Five nodes light in sequence; reused dimmed on section
  dividers as "you are here".

### §1 Folder structure
- **A3 — Tree assembly** (9). Folders dock one by one with role labels; the Android
  equivalent column fades in beside them, joined by faint lines. Folded-in final steps: the
  three rules for deciding where a new file goes.

### §2 API integration
- **A4 — The gap** (3). Phone, cloud, nothing between. A dashed line fails. Then
  `Dio -> Repository -> Model` slides into the gap.
- **A5 — Correlation: HTTP clients** (4). Retrofit/URLSession/RestTemplate/net-http
  converge on Dio.
- **A6 (*) — async/await, the frozen frame** (4). A 60fps tick strip. A sync call drops
  in: ticks go red and stop, the phone beside it freezes mid-spinner, "138 dropped
  frames". Then the same call detaches to a second "suspended" lane: ticks stay green and
  flowing, the phone stays alive. The result slots back into the main lane. Correlation
  chips at step 4: `suspend` / `async-await` / goroutine / `CompletableFuture`.
- **A7 — Future marble** (3). One circle: pulsing outline -> filled blue, or -> filled red.
- **A8 (*) (LIVE) — Three-state switch.** A real embedded phone plus three buttons
  (`loading` / `error` / `data`). Tapping cross-fades a genuine `AnimatedSwitcher` while
  the matching `switch` branch highlights in the code beside it. Keyboard-handover slide.
- **A9 — Swallowed error** (3). `catch (e) {}` in red beside an infinite spinner; a clock
  ticks 5s -> 30s; a thumb taps back; "user lost".

### §3 Auth
- **A10 — The 401 bounce** (3). An envelope hits a wall and returns stamped 401. Then a
  key attaches and it passes through.
- **A11 (**) — OAuth2 sequence diagram** (9). Four lanes: App, Browser, Auth Server, API.
  Each arrow draws itself (~400ms); previous arrows dim to 40% so the current hop is
  always obvious. The access token renders as a short pill, the refresh token as a long
  one, so the difference is visible rather than asserted. At step 7 **time passes and the
  access pill shrinks and greys**; step 8 is the 401; step 9 refreshes and **replays the
  failed request in green**. The longest animation in the deck (~90s of talking); can be
  compressed to 6 steps by merging the authorize/login/code hops.
- **A12 — Interceptor annotated** (4). Dio `onError` code with `highlightedLines` walking
  the refresh-and-retry path, each step lighting a matching arrow on a mini-diagram.
  Correlation: OkHttp `Authenticator` / URLSession delegate / Spring filter / Go middleware.
- **A13 — Unsplash reality** (2). The whole four-lane diagram shrinks and collapses into a
  single line: `Authorization: Client-ID ...`. Then a red "this never goes in git" callout.

### §4 Data -> UI
- **A14 (*) — JSON morphs into Dart** (5). Each JSON key-value lifts out of the raw block,
  travels a curved path, and lands as a named argument in the `Photo(` constructor; the
  source line dims once consumed. The final step reverses briefly to show `toJson`.
- **A15 — Correlation: serialization** (1). *Final step of slide 19, not a slide of its
  own (§8).* Gson/Moshi, Codable, Jackson, `encoding/json` -> `fromJson`, plus: *"Dart has
  no runtime reflection — that's why this is manual."* Answers the "why isn't this
  automatic?" question before it is asked, while the morph diagram is still on screen.
- **A16 (**) — Deleting the hardcoded list** (3). The 12-line hardcoded list
  **character-morphs** into `await repo.getPhotos()` using `FlutterDeckCodeHighlight`'s
  real code-diff animation (`animateCodeUpdate`), and **both phones** beside it — list and
  detail — swap grey placeholders for live Unsplash images from the one change. The peak of
  session 1.
- **A17 — Codegen payoff** (2). 40 hand-written lines collapse into `part 'photo.g.dart';`;
  a terminal panel types `dart run build_runner build`; the generated file expands back out.

### §5 Architecture
- **A18 — The 600-line file** (4). One rectangle grows taller; coloured bands
  (UI / network / parsing / rules) interleave and tangle; a bug icon lands.
- **A19 (*) — Three layers assemble** (5). *The same bands from A18* separate and sort
  themselves into Presentation / Domain / Data slabs. Visual continuity from the previous
  slide is the point — it is the same code, reorganised. Folded-in final steps: correlation
  with MVVM+UseCase, VIPER, and Controller-Service-Repository.
- **A20 — The dependency rule** (4). Arrows point inward, green. Then one flips outward
  (Domain -> Data) and turns red; the Domain slab catches fire; the test panel beside it
  goes red: "to test one rule you now need a network."
- **A21 (*) — Testability swap** (3). The Data slab slides out and a `FakeRepository`
  slides in. **Domain never moves.** A test timer reads `2400ms -> 3ms`.
- **A22 — Repository = one door** (3). Two sources behind one door. A caller knocks; the
  door opens to the API; then the network drops out and the same knock silently opens to
  the cache. The caller is unchanged.

### §6 State management — one continuous tree across nine slides
The tree widget persists and evolves; they watch the same tree get better.

- **A23 — Prop drilling** (5). A 5-deep tree. The value threads down and every middle node
  gains a `photos` parameter it does not use ("doesn't care, still has to carry it"). A
  callback threads back *up*. Add a second piece of state and every middle node's parameter
  count doubles. Finally `setState` at the root **flashes the entire tree**.
- **A24 (*) — InheritedWidget, reaching up** (5). Same tree. The middle nodes **shed their
  parameters** — they visibly fall away. A leaf fires
  `dependOnInheritedWidgetOfExactType<PhotoScope>()` and **a traversal pulse travels up the
  ancestor chain, node by node**, until it locks onto the scope. A second leaf subscribes;
  a third does not. On change, only the subscribers flash. Folded-in final steps:
  correlation chips for `CompositionLocal`, `@Environment`, React Context.
- **A25 — What InheritedWidget can't do** (2). The scope node highlights: it is immutable,
  so something else must rebuild it. An awkward `setState` wrapper appears around it. This
  slide exists so that ChangeNotifier looks necessary rather than arbitrary.
- **A26 (**) — ChangeNotifier, the pulse** (6). `addListener()` draws a labelled line from
  each leaf to the model. A **real tappable button** calls `counter.increment()` and the
  method name flashes on the model box. `notifyListeners()` **pulses a ring outward along
  every registered line**; connected leaves flash and tick up, unconnected stay dark. One
  leaf `dispose()`s, its line snaps, and the next pulse skips it. Every arrow is labelled
  with its real method name. Folded-in final steps: correlation chips for
  `LiveData`/`StateFlow` and `ObservableObject`/`@Published`.
- **A27 — Provider = the two, married** (3). The InheritedWidget and ChangeNotifier boxes
  slide together and **fuse** into `ChangeNotifierProvider`; surrounding boilerplate
  collapses and vanishes; a line counter reads `38 -> 6`.
- **A28 (**) (LIVE) — watch vs read vs Consumer.** The tree as real widgets with a genuine
  **rebuild-flash overlay** (a per-node build counter incremented inside `build`). Toggle
  `context.watch` at the top: a huge region flashes. Toggle `Consumer` around one leaf:
  **the flashing region visibly shrinks to a single node.** A live counter reads
  "rebuilds this frame: 14 -> 1". Turns "prefer Consumer" from folklore into something they
  watched happen. Second keyboard-handover slide.
- **A29 — Decision table** (4). Rows reveal: `setState` (local, ephemeral),
  `InheritedWidget` (read-only config down the tree), `ChangeNotifier + Provider` (shared
  mutable), and "Bloc/Riverpod exist for when this starts to hurt."

### §7 DI
- **A30 — main.dart spaghetti** (3). Three objects constructed manually, each passed into
  the next and threaded four levels down; lines cross. Add one more dependency: six more
  lines and worse crossing.
- **A31 — MultiProvider collapse** (2). The spaghetti collapses into a clean provider list
  and the crossing lines straighten. Folded-in final steps: correlation with Hilt
  `@Module`, Koin `module {}`, Spring `@Bean`, Go `wire`.
- **A32 — Swap for tests** (2). One line swaps `PhotoRepository` for `FakePhotoRepository`;
  the whole subtree turns green "under test"; nothing else changes. Deliberate callback
  to A21 — the same idea, now at the wiring level.

### §8 Dart bits
- **A33 — Named parameters** (3). `Photo('a', 'b', 'c', true)` with question marks popping
  over each argument; the call **morphs** into named arguments and the marks resolve into
  labels.
- **A34 — Cascade & spread** (2). A repeated-variable block morphs into `..`;
  `[...list, item]` expands to show elements flowing out of the spread.

### §9 Hands-on
- **A35 (**) — Design -> widget tree** (7). The rebuilt GoPay "Select payment method"
  screen renders as a real Flutter widget on the left. Each step dashes a box around one
  region and its widget name flies out to the right, assembling
  `Scaffold -> Column -> SectionHeader -> ListView -> PaymentRow -> [Icon, Column[Title,
  Subtitle], Trailing]`. **The tree grows with every tap.**
- **A36 (**) — BFF contract reveal** (3 slides, ~4 steps each). Same screen. Each step
  highlights one row and its JSON fragment flies in from the right **connected by a
  self-drawing arrow** to that exact row — the arrow draws, it does not merely appear.
  Each reveal also highlights **the Dart widget property that JSON drives**
  (`color_token: "error"` -> `style: theme.error`). Row variants:
  - a. plain row: title, balance, radio button
  - b. warning row: `"type": "INFO"`, `color_token`, info CTA opening a dialog
  - c. error row: `"type": "ERROR"`, disabled, `"cta": {"type": "DEEP_LINK"}` with the
    android / ios / web action map
- **A37 — BFF vs non-BFF** (4). Split screen, identical UI on both sides. Left: rich JSON,
  thin client `switch`. Right: bare `{id, type, balance}` and **business logic visibly
  accumulating in the client** as if-statements stack up and the line count climbs. Final
  step adds a new payment type: the left needs zero client changes (the server ships it),
  the right needs an app release. "Ships in: 1 day vs 6 weeks."

### Protected set
If build time runs short, **A6, A24, A26, A28** are protected. In each, the animation is
the explanation rather than an illustration of it.

## 10. References slide

Grouped, revealed in 6 steps. Official source first, best community resource second.

- **Dart / async** — dart.dev/language, dart.dev/codelabs/async-await, Effective Dart
- **Networking** — pub.dev/packages/dio, docs.flutter.dev networking cookbook
- **JSON** — docs.flutter.dev/data-and-backend/serialization/json, json_serializable
- **Architecture** — docs.flutter.dev/app-architecture (Flutter's own guide), Uncle Bob's
  Clean Architecture post
- **State management** — docs.flutter.dev/data-and-backend/state-mgmt/options,
  pub.dev/packages/provider, `InheritedWidget` and `ChangeNotifier` API docs,
  Flutter Widget of the Week
- **Performance / rebuilds** — docs.flutter.dev/perf/best-practices
- **BFF pattern** — Sam Newman's BFF article
- **Unsplash API** — unsplash.com/documentation
- **This deck** — github.com/mkobuolys/flutter_deck

## 11. Testing

The global 80% coverage standard is written for application code. A slide deck's risk
profile is different: the failure that matters is **a slide that throws or overflows in
front of an audience**. Coverage is therefore targeted rather than blanket, and the
deviation is deliberate.

1. **Slide smoke test (the important one).** Pump every slide, at every step, in both
   light and dark, at 1920x1080 and 1280x720. Assert no exception and no overflow. This is
   possible precisely because §7.2 makes slides pure functions of `(step, theme)`.
2. **Widget tests for the shared primitives** — `StepReveal`, `AnnotatedArrow`,
   `CorrelationPanel`, `WidgetTree`, `RebuildCounter`.
3. **Unit tests for `UnsplashClient`** — success, network failure -> fixture fallback,
   missing key -> fixture fallback.

Interactive demo slides get an interaction test each (tap the button, assert the state
changed), since those are the slides where a failure is most visible.

## 12. Presenting and deploying

- **Primary: Chrome.** `fvm flutter run -d chrome --dart-define=UNSPLASH_ACCESS_KEY=...`
  `FlutterDeckWebClient` gives presenter view (speaker notes on a second screen) for free,
  and Unsplash serves permissive CORS headers so the live request works.
- **Backup: macOS desktop.** Same command with `-d macos`. Needs the network entitlement
  in `macos/Runner/*.entitlements` — which doubles as a genuine teaching moment for
  slide 15.
- **Shareable artifact:** `fvm flutter build web` served locally over `python3 -m http.server`.
- Fonts bundled, fixtures bundled: the deck renders fully with no network.

## 13. Git workflow

Conventional commits. Per the user's explicit request, **one commit per slide once its
content and animation are working** — not one large drop. Commit messages name the slide
and its animation, e.g. `feat: add InheritedWidget tree-traversal slide (A24)`.

## 14. Risks

| Risk | Mitigation |
|---|---|
| A28's real rebuild-flash overlay is the hardest build in the deck | Build it for real first. If instrumenting genuine rebuilds fights back, fall back to a staged step animation that looks identical. Decide early, not at the end. |
| Flutter 3.47.5 download is ~1GB | Start it first, before any other work. |
| Live Unsplash request fails on stage | Fixture fallback with an "offline fixture" chip (§7.5). |
| `google_fonts` fetches at runtime by default | Bundle the TTFs as assets and declare them in `pubspec.yaml`. |
| 51 slides may still be more than "minimal" | Cut list identified in §8; the slide list in `main.dart` is grouped by section so a cut is a one-line deletion. |

## 15. Resolved questions

All three open questions are closed as of 2026-09-22:

1. **Day 1 homework** — confirmed as a multi-screen app (list + detail, reusable widget in
   a ListView/GridView, hardcoded models). Spine re-hung in §1; slides 2, 23, 24, 43 and
   animations A1 and A16 updated to work across both screens.
2. **Deck identity** — "GoPay · Flutter Bootcamp", on the title slide and footer.
3. **Section dividers** — decided: none. Built-in per-slide headers plus a roadmap chip on
   section-opening slides give the same orientation for zero extra slides (§8.1).

## 16. Open questions

**None.** Both deferred judgement calls are now closed:

- **Slide count: 51.** Decided by the correlation-folding principle in §8, not by trimming
  content. Further cuts stay available but are no longer planned.
- **A11 stays at 9 steps.** The full OAuth hop-by-hop is kept; compress later if it drags
  in rehearsal.
