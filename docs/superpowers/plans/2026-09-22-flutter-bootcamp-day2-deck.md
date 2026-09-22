# Flutter Bootcamp Day 2 Deck — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 51-slide `flutter_deck` presentation for GoPay's Flutter bootcamp Day 2, carrying 37 step-driven animations and 3 live interactive demos that explain API integration, auth, data mapping, clean architecture, state management and DI to engineers arriving from Android/iOS/Java/Go.

**Architecture:** Every slide splits in two — a thin `FlutterDeckSlideWidget` wrapper that owns routing/config, and a pure `Body` widget that takes the current `step` as a plain `int` and has no flutter_deck ancestors. A single `SlideSpec` registry feeds both `main.dart` and the smoke test, so a slide cannot exist without being covered. All animation is derived from `step` through one primitive (`StepReveal`), which makes every animation presenter-paced, reversible, and testable by pumping a body at a fixed step.

**Tech Stack:** Flutter 3.47.5 (via fvm), Dart 3.8+, `flutter_deck ^0.29.0`, `provider`, `dio`, `google_fonts` (bundled assets), `flutter_deck_web_client`.

**Spec:** `docs/superpowers/specs/2026-09-22-flutter-bootcamp-day2-deck-design.md`

## Global Constraints

- **Flutter >= 3.32.0 / Dart >= 3.8.0.** Pinned to 3.47.5 via fvm. Every Flutter and Dart command runs through `fvm` (`fvm flutter ...`, `fvm dart ...`). Never invoke bare `flutter`.
- **No `build_runner` in the deck itself.** Codegen appears only as *content* on slide 23. No `.g.dart` files, no mockito.
- **Deck identity:** "Flutter Bootcamp". Title slide and footer.
- **Palette (exact):** base `#0B0E13`, surface `#141922`, blue `#118EEA` (GoPay — "Flutter/new"), green `#00AA5B` (Gojek — "what you already know"), amber `#F5A623` (warning), red `#E5484D` (error), text `#E8EDF4` primary / `#93A1B5` secondary.
- **Motion language:** 300ms fades, 400ms travel, `Curves.easeOutCubic` everywhere, no bounce/overshoot, max two things moving at once, completed steps dim to 40% rather than disappearing. Slide transition is `FlutterDeckTransition.fade()` and nothing else.
- **Text density:** no slide may exceed ~25 words of body copy. If a slide needs more, it is two slides or the words belong in speaker notes.
- **Secrets:** the Unsplash key arrives via `--dart-define=UNSPLASH_ACCESS_KEY=...` and is read with `String.fromEnvironment`. Never hardcoded, never committed. Missing key or failed request falls back to a bundled fixture.
- **Offline:** fonts bundled as assets, fixtures bundled. The deck must render fully with no network.
- **Commits:** conventional commits, one commit per slide (or per tightly-coupled slide pair) once its content and animation work. Every commit message names the slide number and animation ID, e.g. `feat(slide-32): InheritedWidget tree traversal (A24)`.
- **Every commit must leave `fvm flutter test` green** and `fvm flutter analyze` clean.

---

## File Structure

### Foundation (Tasks 1–8)

| File | Responsibility |
|---|---|
| `pubspec.yaml` | Deps, bundled font + fixture + image assets |
| `.fvmrc` | Pins Flutter 3.47.5 |
| `analysis_options.yaml` | `flutter_lints` + `prefer_const_constructors` enforced |
| `lib/main.dart` | `FlutterDeckApp`: configuration, themes, plugins, slide list built from the registry |
| `lib/theme/palette.dart` | Raw colour constants. No widgets. |
| `lib/theme/tokens.dart` | Spacing, durations, curves. No colours. |
| `lib/theme/deck_theme.dart` | `FlutterDeckThemeData` light + dark built from palette + tokens |
| `lib/widgets/step_scope.dart` | `StepScope` InheritedWidget carrying the current step |
| `lib/widgets/step_reveal.dart` | `StepReveal` — the one animation primitive |
| `lib/widgets/correlation_panel.dart` | Two-tone "you know X → Flutter is Y" panel |
| `lib/widgets/live_badge.dart` | The `● LIVE` handoff marker |
| `lib/widgets/phone_frame.dart` | Device chrome wrapper for embedded demos |
| `lib/widgets/annotate.dart` | `AnimatedArrow`, `DashedBox`, `Callout` custom painters |
| `lib/widgets/widget_tree.dart` | The shared, evolving tree used across all of §6 |
| `lib/widgets/code_panel.dart` | Thin wrapper over `FlutterDeckCodeHighlight` with deck defaults |
| `lib/slides/slide_spec.dart` | `SlideSpec` + `DeckSlide` generic wrapper |
| `lib/slides/registry.dart` | The ordered list of all 51 `SlideSpec`s — single source of truth |
| `lib/demos/unsplash_client.dart` | Real Dio client + fixture fallback |
| `assets/fonts/` | Outfit + JetBrains Mono TTFs |
| `assets/fixtures/unsplash_photos.json` | Offline fallback payload |
| `test/support/pump.dart` | `pumpBody` harness |
| `test/slides_smoke_test.dart` | Every slide × every step × both themes × two resolutions |

### Slide bodies (Tasks 9–28)

One file per slide under `lib/slides/s{NN}_{section}/`, each exporting `{Name}Slide` (deck wrapper) and `{Name}Body` (pure, step-driven). Section folders: `s00_open`, `s01_structure`, `s02_api`, `s03_auth`, `s04_data`, `s05_architecture`, `s06_state`, `s07_di`, `s08_dart`, `s09_handson`, `s10_close`.

---

## Task 1: Project scaffold and flutter_deck compatibility gate

This task exists to fail fast. If Flutter 3.47.5 and flutter_deck 0.29.0 disagree, we learn it now and not after 20 slides.

**Files:**
- Create: `.fvmrc`, `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`
- Test: `test/smoke_test.dart`

**Interfaces:**
- Consumes: nothing
- Produces: a runnable `FlutterDeckApp` with one slide; `fvm` pinned to 3.47.5

- [ ] **Step 1: Pin the SDK and create the project**

```bash
cd /Users/batman/Desktop/Projects/flutter-presentation
fvm use 3.47.5 --force
fvm flutter --version    # expect Flutter 3.47.5, Dart >=3.8
fvm flutter create --project-name flutter_bootcamp_deck --platforms=web,macos .
```

- [ ] **Step 2: Add dependencies**

```bash
fvm flutter pub add flutter_deck provider dio google_fonts flutter_deck_web_client
fvm flutter pub add --dev flutter_lints
fvm flutter pub get
```

Expected: resolves with `flutter_deck 0.29.x`. **If pub reports a version solve failure against Flutter 3.47.5, stop and report it** — the fallback recorded in the spec (§5) is to drop to a stable release nearer flutter_deck 0.29.0's 2026-07-01 publish date.

- [ ] **Step 3: Write the failing smoke test**

```dart
// test/smoke_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/main.dart';

void main() {
  testWidgets('deck boots and shows the title slide', (tester) async {
    await tester.pumpWidget(const BootcampDeckApp());
    await tester.pumpAndSettle();
    expect(find.text('Flutter Bootcamp'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Run it and watch it fail**

Run: `fvm flutter test test/smoke_test.dart`
Expected: FAIL — `BootcampDeckApp` is undefined.

- [ ] **Step 5: Write the minimal deck**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

void main() => runApp(const BootcampDeckApp());

class BootcampDeckApp extends StatelessWidget {
  const BootcampDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterDeckApp(
      configuration: const FlutterDeckConfiguration(
        transition: FlutterDeckTransition.fade(),
        slideSize: FlutterDeckSlideSize.fromAspectRatio(
          aspectRatio: FlutterDeckAspectRatio.ratio16x9(),
          resolution: FlutterDeckResolution.fhd(),
        ),
      ),
      slides: [
        FlutterDeckSlide.title(
          configuration: const FlutterDeckSlideConfiguration(route: '/title'),
          title: 'Flutter Bootcamp',
          subtitle: 'Day 2 — Making It Real',
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Run the test and the app**

Run: `fvm flutter test test/smoke_test.dart` → Expected: PASS
Run: `fvm flutter analyze` → Expected: no issues
Run: `fvm flutter run -d chrome` → Expected: title slide renders; left/right arrows do not crash. Close it.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: scaffold flutter_deck project on Flutter 3.47.5"
```

---

## Task 2: Theme

**Files:**
- Create: `lib/theme/palette.dart`, `lib/theme/tokens.dart`, `lib/theme/deck_theme.dart`
- Create: `assets/fonts/` (Outfit-Regular.ttf, Outfit-SemiBold.ttf, JetBrainsMono-Regular.ttf)
- Modify: `pubspec.yaml` (font declarations), `lib/main.dart`
- Test: `test/theme/deck_theme_test.dart`

**Interfaces:**
- Produces: `Palette` (static colour constants), `Tokens` (static spacing/duration/curve constants), `deckLightTheme` / `deckDarkTheme` as `FlutterDeckThemeData`

- [ ] **Step 1: Bundle the fonts**

Download Outfit (Regular 400, SemiBold 600) and JetBrains Mono (Regular 400) TTFs into `assets/fonts/`. **Bundling rather than using `google_fonts`' runtime fetch is a hard requirement** — the deck must render with no network (Global Constraints).

Declare in `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/fixtures/
    - assets/images/
  fonts:
    - family: Outfit
      fonts:
        - asset: assets/fonts/Outfit-Regular.ttf
          weight: 400
        - asset: assets/fonts/Outfit-SemiBold.ttf
          weight: 600
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
          weight: 400
```

- [ ] **Step 2: Write the failing test**

```dart
// test/theme/deck_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

void main() {
  test('dark theme uses the deck base and blue accent', () {
    final scheme = deckDarkTheme.materialTheme.colorScheme;
    expect(scheme.brightness, Brightness.dark);
    expect(scheme.primary, Palette.blue);
    expect(deckDarkTheme.materialTheme.scaffoldBackgroundColor, Palette.base);
  });

  test('light theme keeps the same accents', () {
    expect(deckLightTheme.materialTheme.colorScheme.primary, Palette.blue);
    expect(deckLightTheme.materialTheme.colorScheme.brightness, Brightness.light);
  });

  test('correlation accents are distinct and semantic', () {
    expect(Palette.blue, isNot(Palette.green));
  });
}
```

- [ ] **Step 3: Run it and watch it fail**

Run: `fvm flutter test test/theme/deck_theme_test.dart`
Expected: FAIL — `deck_theme.dart` does not exist.

- [ ] **Step 4: Implement palette and tokens**

```dart
// lib/theme/palette.dart
import 'package:flutter/material.dart';

/// Raw colour constants for the deck. Accents carry semantic roles:
/// [blue] means "Flutter / the new thing", [green] means "what you already know".
abstract final class Palette {
  static const base = Color(0xFF0B0E13);
  static const surface = Color(0xFF141922);
  static const blue = Color(0xFF118EEA);   // primary accent
  static const green = Color(0xFF00AA5B);  // familiar-platform accent
  static const amber = Color(0xFFF5A623);
  static const red = Color(0xFFE5484D);
  static const textPrimary = Color(0xFFE8EDF4);
  static const textSecondary = Color(0xFF93A1B5);

  static const lightBase = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF4F7FB);
  static const lightTextPrimary = Color(0xFF0B0E13);
  static const lightTextSecondary = Color(0xFF5A6B80);
}
```

```dart
// lib/theme/tokens.dart
import 'package:flutter/animation.dart';

/// The deck's motion language and spacing scale. One curve, two durations.
abstract final class Tokens {
  static const fade = Duration(milliseconds: 300);
  static const travel = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic;

  /// Completed steps dim to this rather than disappearing, so the audience
  /// keeps the context of what came before.
  static const dimmed = 0.4;

  static const gapXs = 8.0;
  static const gapSm = 16.0;
  static const gapMd = 24.0;
  static const gapLg = 40.0;
  static const gapXl = 64.0;

  static const radius = 12.0;
  static const strokeWidth = 2.0;
}
```

- [ ] **Step 5: Implement the theme**

```dart
// lib/theme/deck_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';

const _display = 'Outfit';
const _mono = 'JetBrainsMono';

ThemeData _base(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: _display,
    scaffoldBackgroundColor: dark ? Palette.base : Palette.lightBase,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.blue,
      brightness: brightness,
    ).copyWith(
      primary: Palette.blue,
      secondary: Palette.green,
      error: Palette.red,
      surface: dark ? Palette.surface : Palette.lightSurface,
    ),
  );
}

final deckDarkTheme = FlutterDeckThemeData.fromTheme(_base(Brightness.dark));
final deckLightTheme = FlutterDeckThemeData.fromTheme(_base(Brightness.light));

/// Monospace style for every code and JSON surface in the deck.
const deckCodeStyle = TextStyle(fontFamily: _mono, fontSize: 22, height: 1.45);
```

- [ ] **Step 6: Run the test**

Run: `fvm flutter test test/theme/deck_theme_test.dart` → Expected: PASS

- [ ] **Step 7: Wire the themes into the app**

In `lib/main.dart`, add `lightTheme: deckLightTheme, darkTheme: deckDarkTheme, themeMode: ThemeMode.dark` to `FlutterDeckApp`.

- [ ] **Step 8: Verify and commit**

```bash
fvm flutter test && fvm flutter analyze
git add -A
git commit -m "feat: add deck deck theme with bundled fonts"
```

---

## Task 3: StepScope and StepReveal — the animation primitive

Everything in the deck animates through this. Get it right and the remaining 37 animations are composition.

**Files:**
- Create: `lib/widgets/step_scope.dart`, `lib/widgets/step_reveal.dart`
- Test: `test/widgets/step_reveal_test.dart`

**Interfaces:**
- Consumes: `Tokens` (Task 2)
- Produces:
  - `StepScope({required int step, required Widget child})`, `StepScope.of(BuildContext) -> int`
  - `StepReveal({required int atStep, int? until, Widget child, Offset slideFrom, bool dimWhenPast})`

- [ ] **Step 1: Write the failing tests**

```dart
// test/widgets/step_reveal_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

Widget _harness(int step) => MaterialApp(
      home: StepScope(
        step: step,
        child: const StepReveal(atStep: 2, child: Text('hello')),
      ),
    );

double _opacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.ancestor(
      of: find.text('hello'),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity;

void main() {
  testWidgets('hidden before its step', (tester) async {
    await tester.pumpWidget(_harness(1));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 0.0);
  });

  testWidgets('fully visible on its step', (tester) async {
    await tester.pumpWidget(_harness(2));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1.0);
  });

  testWidgets('dims rather than disappears after its step', (tester) async {
    await tester.pumpWidget(_harness(3));
    await tester.pumpAndSettle();
    expect(_opacity(tester), Tokens.dimmed);
  });

  testWidgets('until hides it again', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const StepScope(
        step: 4,
        child: StepReveal(atStep: 2, until: 3, child: Text('hello')),
      ),
    ));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 0.0);
  });

  testWidgets('StepScope.of throws a useful error when missing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StepReveal(atStep: 1, child: Text('hello')),
    ));
    expect(tester.takeException(), isA<FlutterError>());
  });
}
```

- [ ] **Step 2: Run and watch them fail**

Run: `fvm flutter test test/widgets/step_reveal_test.dart`
Expected: FAIL — files do not exist.

- [ ] **Step 3: Implement StepScope**

```dart
// lib/widgets/step_scope.dart
import 'package:flutter/widgets.dart';

/// Carries the current slide step down the tree so [StepReveal] and friends
/// do not have to thread it through every constructor.
///
/// Slide bodies provide this; they take `step` as a plain `int`, which is what
/// lets the smoke test pump any slide without a flutter_deck ancestor.
class StepScope extends InheritedWidget {
  const StepScope({required this.step, required super.child, super.key});

  final int step;

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StepScope>();
    if (scope == null) {
      throw FlutterError(
        'StepScope.of() called with a context that has no StepScope ancestor.\n'
        'Slide bodies must wrap their content in StepScope(step: step, ...).',
      );
    }
    return scope.step;
  }

  @override
  bool updateShouldNotify(StepScope oldWidget) => step != oldWidget.step;
}
```

- [ ] **Step 4: Implement StepReveal**

```dart
// lib/widgets/step_reveal.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

/// Reveals [child] at [atStep], dims it once the deck has moved past, and
/// optionally hides it again after [until].
///
/// This is the deck's only animation primitive. Because visibility is derived
/// purely from the ambient step, every animation is presenter-paced and
/// reversible — stepping backward re-hides things correctly with no state.
class StepReveal extends StatelessWidget {
  const StepReveal({
    required this.atStep,
    required this.child,
    this.until,
    this.slideFrom = const Offset(0, 0.04),
    this.dimWhenPast = true,
    super.key,
  });

  final int atStep;
  final int? until;
  final Widget child;
  final Offset slideFrom;
  final bool dimWhenPast;

  @override
  Widget build(BuildContext context) {
    final step = StepScope.of(context);
    final past = until != null && step > until!;
    final arrived = step >= atStep;

    final opacity = !arrived || past
        ? 0.0
        : (dimWhenPast && step > atStep ? Tokens.dimmed : 1.0);

    return AnimatedSlide(
      duration: Tokens.travel,
      curve: Tokens.curve,
      offset: arrived && !past ? Offset.zero : slideFrom,
      child: AnimatedOpacity(
        duration: Tokens.fade,
        curve: Tokens.curve,
        opacity: opacity,
        child: IgnorePointer(ignoring: opacity == 0, child: child),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the tests**

Run: `fvm flutter test test/widgets/step_reveal_test.dart` → Expected: all 5 PASS

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add StepScope and StepReveal animation primitive"
```

---

## Task 4: Slide registry, generic deck wrapper, and the smoke-test harness

The gate every later task runs against. Building it now means no slide is ever added without coverage.

**Files:**
- Create: `lib/slides/slide_spec.dart`, `lib/slides/registry.dart`
- Create: `test/support/pump.dart`, `test/slides_smoke_test.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `StepScope` (Task 3), `deckDarkTheme`/`deckLightTheme` (Task 2)
- Produces:
  - `SlideSpec({required String route, required String section, String? title, int steps = 1, String? speakerNotes, required Widget Function(int step) body})`
  - `const List<SlideSpec> slideRegistry`
  - `DeckSlide(SlideSpec spec) extends FlutterDeckSlideWidget`
  - `pumpBody(WidgetTester, Widget, {Size size, Brightness brightness})`

- [ ] **Step 1: Implement SlideSpec and the generic wrapper**

```dart
// lib/slides/slide_spec.dart
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
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
  });

  final String route;
  final String section;
  final String? title;
  final int steps;
  final String? speakerNotes;
  final Widget Function(int step) body;
}

/// Wraps a [SlideSpec] as a flutter_deck slide. The section name becomes the
/// persistent header, which is how the deck orients the audience without
/// spending slides on dividers (spec §8.1).
class DeckSlide extends FlutterDeckSlideWidget {
  DeckSlide(this.spec)
      : super(
          configuration: FlutterDeckSlideConfiguration(
            route: spec.route,
            title: spec.title ?? spec.section,
            steps: spec.steps,
            speakerNotes: spec.speakerNotes ?? '',
            header: FlutterDeckHeaderConfiguration(title: spec.section),
          ),
        );

  final SlideSpec spec;

  @override
  Widget build(BuildContext context) => FlutterDeckSlide.blank(
        builder: (context) => FlutterDeckSlideStepsBuilder(
          builder: (context, step) =>
              StepScope(step: step, child: spec.body(step)),
        ),
      );
}
```

- [ ] **Step 2: Create the registry with a single placeholder slide**

```dart
// lib/slides/registry.dart
import 'package:flutter/material.dart';
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
    section: 'Flutter Bootcamp',
    title: 'Day 2 — Making It Real',
    body: (step) => const Center(child: Text('Flutter Bootcamp')),
  ),
];
```

- [ ] **Step 3: Write the pump harness**

```dart
// test/support/pump.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/widgets/step_scope.dart';

const fhd = Size(1920, 1080);
const hd = Size(1280, 720);

/// Pumps a slide body in isolation at a fixed step. No flutter_deck ancestors
/// are required, which is the whole point of the body/wrapper split.
Future<void> pumpBody(
  WidgetTester tester,
  Widget body, {
  int step = 1,
  Size size = fhd,
  Brightness brightness = Brightness.dark,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: (brightness == Brightness.dark ? deckDarkTheme : deckLightTheme)
          .materialTheme,
      home: Scaffold(
        body: StepScope(step: step, child: body),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
```

- [ ] **Step 4: Write the smoke test**

```dart
// test/slides_smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/slides/registry.dart';

import 'support/pump.dart';

void main() {
  group('every slide renders at every step', () {
    for (final spec in slideRegistry) {
      for (var step = 1; step <= spec.steps; step++) {
        for (final brightness in Brightness.values) {
          for (final size in const [fhd, hd]) {
            testWidgets(
              '${spec.route} step $step ${brightness.name} ${size.width.toInt()}w',
              (tester) async {
                await pumpBody(
                  tester,
                  spec.body(step),
                  step: step,
                  size: size,
                  brightness: brightness,
                );
                // A RenderFlex overflow surfaces here. This is the assertion
                // that matters: the failure mode we care about is a slide
                // breaking in front of an audience.
                expect(tester.takeException(), isNull);
              },
            );
          }
        }
      }
    }
  });

  test('routes are unique', () {
    final routes = slideRegistry.map((s) => s.route).toList();
    expect(routes.toSet().length, routes.length);
  });

  test('every slide declares at least one step', () {
    expect(slideRegistry.every((s) => s.steps >= 1), isTrue);
  });
}
```

- [ ] **Step 5: Run it**

Run: `fvm flutter test test/slides_smoke_test.dart`
Expected: PASS (4 render cases for the single placeholder slide, plus 2 structural tests).

- [ ] **Step 6: Build the deck from the registry**

Replace the hardcoded `slides:` list in `lib/main.dart` with:

```dart
slides: [for (final spec in slideRegistry) DeckSlide(spec)],
```

and add to `FlutterDeckConfiguration`:

```dart
footer: const FlutterDeckFooterConfiguration(
  showSlideNumbers: true,
  showSocialHandle: false,
),
progressIndicator: const FlutterDeckProgressIndicator.gradient(
  gradient: LinearGradient(colors: [Palette.green, Palette.blue]),
  backgroundColor: Palette.surface,
),
```

plus `speakerInfo: const FlutterDeckSpeakerInfo(name: 'Harsh Sharma', description: 'Coach · Assistant coaches: Harsh, Abhas', socialHandle: 'Flutter Bootcamp', imagePath: 'assets/images/logo.png')` on `FlutterDeckApp`.

- [ ] **Step 7: Verify the whole deck still boots**

Run: `fvm flutter test` → Expected: PASS
Run: `fvm flutter analyze` → Expected: clean

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: add slide registry, generic deck wrapper and smoke-test gate"
```

---

## Task 5: Shared slide furniture

**Files:**
- Create: `lib/widgets/correlation_panel.dart`, `lib/widgets/live_badge.dart`, `lib/widgets/phone_frame.dart`, `lib/widgets/code_panel.dart`
- Modify: `test/support/pump.dart` (wrap in `FlutterDeckCodeHighlightTheme` — see Step 5)
- Test: `test/widgets/correlation_panel_test.dart`

**Interfaces:**
- Consumes: `Palette`, `Tokens`, `StepReveal`
- Produces:
  - `CorrelationPanel({required List<CorrelationRow> rows, required String flutterLabel, int firstStep = 1})`
  - `CorrelationRow({required String platform, required String concept})`
  - `LiveBadge()` and `LiveSlideBody({required String goal, required List<String> beats})`
  - `PhoneFrame({required Widget child, double width = 300})`
  - `CodePanel({required String code, String language = 'dart', String? fileName, List<int> highlightedLines = const []})`

- [ ] **Step 1: Write the failing test**

```dart
// test/widgets/correlation_panel_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';

import '../support/pump.dart';

void main() {
  const panel = CorrelationPanel(
    flutterLabel: 'Dio',
    rows: [
      CorrelationRow(platform: 'Android', concept: 'Retrofit + OkHttp'),
      CorrelationRow(platform: 'iOS', concept: 'URLSession'),
    ],
  );

  testWidgets('reveals one row per step', (tester) async {
    await pumpBody(tester, panel, step: 1);
    expect(find.text('Retrofit + OkHttp'), findsOneWidget);
    expect(find.text('Dio'), findsOneWidget);
  });

  testWidgets('known-platform side uses the green accent', (tester) async {
    await pumpBody(tester, panel, step: 3);
    final text = tester.widget<Text>(find.text('Retrofit + OkHttp'));
    expect(text.style?.color, Palette.green);
  });
}
```

- [ ] **Step 2: Run and watch it fail**

Run: `fvm flutter test test/widgets/correlation_panel_test.dart` → Expected: FAIL, file missing.

- [ ] **Step 3: Implement CorrelationPanel**

Two columns. Left column rows use `Palette.green` (what they already know), right column single box uses `Palette.blue` (the Flutter equivalent), joined by a thin arrow. Each left row wrapped in `StepReveal(atStep: firstStep + index)`; the right box reveals at `firstStep + rows.length`.

```dart
// lib/widgets/correlation_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

class CorrelationRow {
  const CorrelationRow({required this.platform, required this.concept});
  final String platform;
  final String concept;
}

/// "You already know X — in Flutter it is Y."
///
/// Green is always the familiar side, blue always the Flutter side, deck-wide.
/// Per spec §8 this renders as the final steps of a concept slide, not a slide
/// of its own — the analogy lands while the diagram is still on screen.
class CorrelationPanel extends StatelessWidget {
  const CorrelationPanel({
    required this.rows,
    required this.flutterLabel,
    this.firstStep = 1,
    super.key,
  });

  final List<CorrelationRow> rows;
  final String flutterLabel;
  final int firstStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows.length; i++)
                StepReveal(
                  atStep: firstStep + i,
                  dimWhenPast: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Tokens.gapXs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rows[i].platform,
                          style: const TextStyle(
                            color: Palette.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          rows[i].concept,
                          style: const TextStyle(
                            color: Palette.green,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: Tokens.gapLg),
        StepReveal(
          atStep: firstStep + rows.length - 1,
          dimWhenPast: false,
          child: const Icon(Icons.arrow_forward,
              color: Palette.textSecondary, size: 32),
        ),
        const SizedBox(width: Tokens.gapLg),
        Expanded(
          child: StepReveal(
            atStep: firstStep + rows.length - 1,
            dimWhenPast: false,
            child: Container(
              padding: const EdgeInsets.all(Tokens.gapMd),
              decoration: BoxDecoration(
                border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
                borderRadius: BorderRadius.circular(Tokens.radius),
              ),
              child: Text(
                flutterLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.blue, fontSize: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Implement LiveBadge and LiveSlideBody**

`LiveSlideBody` is what all 7 `● LIVE` handoff slides render: a pulsing red dot + the word LIVE, the one-line goal in large type, and nothing else. The coding script lives in `SlideSpec.speakerNotes`, visible only in presenter view.

```dart
// lib/widgets/live_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Palette.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Tokens.gapSm),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Palette.red,
              fontSize: 20,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

/// The body of a live-coding handoff slide. Deliberately almost empty — the
/// audience looks at the IDE, not the screen. The script is in speaker notes.
class LiveSlideBody extends StatelessWidget {
  const LiveSlideBody({required this.goal, super.key});

  final String goal;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LiveBadge(),
            const SizedBox(height: Tokens.gapLg),
            Text(
              goal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Palette.textPrimary,
                fontSize: 48,
                height: 1.25,
              ),
            ),
          ],
        ),
      );
}
```

- [ ] **Step 5: Implement PhoneFrame and CodePanel**

`PhoneFrame` — a rounded 9:19.5 container with a 2px `Palette.textSecondary` border and a notch bar, clipping its child.
`CodePanel` — wraps `FlutterDeckCodeHighlight` with `deckCodeStyle`, `animateCodeUpdate: true` and `codeUpdateDuration: Tokens.travel` so code morphing is consistent deck-wide.

```dart
// lib/widgets/code_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_bootcamp_deck/theme/deck_theme.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// Deck-wide defaults for code. `animateCodeUpdate` is what makes A16's
/// character-morph work — changing [code] between steps cross-fades the diff.
class CodePanel extends StatelessWidget {
  const CodePanel({
    required this.code,
    this.language = 'dart',
    this.fileName,
    this.highlightedLines = const [],
    super.key,
  });

  final String code;
  final String language;
  final String? fileName;
  final List<int> highlightedLines;

  @override
  Widget build(BuildContext context) => FlutterDeckCodeHighlightTheme(
        data: FlutterDeckCodeHighlightTheme.of(context)
            .copyWith(textStyle: deckCodeStyle),
        child: FlutterDeckCodeHighlight(
          code: code,
          language: language,
          fileName: fileName,
          highlightedLines: highlightedLines,
          codeUpdateDuration: Tokens.travel,
        ),
      );
}
```

Note: `CodePanel` depends on `FlutterDeckCodeHighlightTheme`, which needs a flutter_deck ancestor. Slides that use it therefore wrap their `CodePanel` usage in a `Builder` guarded for tests — **or** the smoke test provides `FlutterDeckCodeHighlightTheme` in `pumpBody`. Take the second option: add the theme wrapper to `pumpBody` in `test/support/pump.dart` so code slides stay coverable.

- [ ] **Step 6: Run tests and commit**

```bash
fvm flutter test && fvm flutter analyze
git add -A
git commit -m "feat: add correlation panel, live badge, phone frame and code panel"
```

---

## Task 6: Annotation painters

The drawing layer for every diagram slide: arrows that draw themselves, dashed boxes that appear around regions, and callouts.

**Files:**
- Create: `lib/widgets/annotate.dart`
- Test: `test/widgets/annotate_test.dart`

**Interfaces:**
- Consumes: `Tokens`, `Palette`, `StepScope`
- Produces:
  - `AnimatedArrow({required Offset from, required Offset to, required int atStep, Color color, bool curved})` — draws itself over `Tokens.travel` when the step arrives
  - `DashedBox({required int atStep, required Widget child, Color color})`
  - `Callout({required int atStep, required String text, Color color})`

- [ ] **Step 1: Write the failing test**

```dart
// test/widgets/annotate_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';

import '../support/pump.dart';

void main() {
  testWidgets('arrow has zero progress before its step', (tester) async {
    await pumpBody(
      tester,
      const AnimatedArrow(from: Offset(0, 0), to: Offset(100, 100), atStep: 2),
      step: 1,
    );
    final painter = tester
        .widget<CustomPaint>(find.byType(CustomPaint).first)
        .painter! as ArrowPainter;
    expect(painter.progress, 0.0);
  });

  testWidgets('arrow is fully drawn once its step arrives', (tester) async {
    await pumpBody(
      tester,
      const AnimatedArrow(from: Offset(0, 0), to: Offset(100, 100), atStep: 2),
      step: 2,
    );
    final painter = tester
        .widget<CustomPaint>(find.byType(CustomPaint).first)
        .painter! as ArrowPainter;
    expect(painter.progress, 1.0);
  });

  testWidgets('dashed box renders its child', (tester) async {
    await pumpBody(
      tester,
      const DashedBox(atStep: 1, child: Text('region')),
      step: 1,
    );
    expect(find.text('region'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run and watch it fail**

Run: `fvm flutter test test/widgets/annotate_test.dart` → Expected: FAIL, file missing.

- [ ] **Step 3: Implement**

`AnimatedArrow` uses `TweenAnimationBuilder<double>` keyed on whether the step has arrived, feeding `progress` (0→1) into `ArrowPainter`. The painter draws a path (straight or quadratic bézier when `curved`) clipped to `progress` of its total length using `PathMetric.extractPath`, plus an arrowhead that only appears once `progress > 0.95`. `ArrowPainter` must expose `progress` as a public final field so the test above can read it, and implement `shouldRepaint` comparing `progress` and `color`.

`DashedBox` paints a dashed `RRect` border around its child via a `CustomPaint` foreground painter, wrapped in `StepReveal(atStep: atStep)`.

`Callout` is a small rounded label with a 1px border in `color`, wrapped in `StepReveal`.

- [ ] **Step 4: Run tests, then commit**

```bash
fvm flutter test test/widgets/annotate_test.dart   # Expected: PASS
fvm flutter analyze
git add -A
git commit -m "feat: add animated arrow, dashed box and callout painters"
```

---

## Task 7: The shared widget tree for §6

Nine slides share one tree that re-arranges itself. Building it once, driven by data, is what makes that continuity possible.

**Files:**
- Create: `lib/widgets/widget_tree.dart`
- Test: `test/widgets/widget_tree_test.dart`

**Interfaces:**
- Consumes: `Palette`, `Tokens`, `StepReveal`
- Produces:
  - `TreeNode({required String id, required String label, List<TreeNode> children = const [], List<String> params = const [], bool flashing = false, bool subscribed = false})`
  - `WidgetTreeView({required TreeNode root, Set<String> flashing = const {}, Set<String> subscribed = const {}, String? traversalTo, bool showParams = false})`
  - `demoTree` — the canonical 5-level tree reused across slides 31–38

- [ ] **Step 1: Write the failing test**

```dart
// test/widgets/widget_tree_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/widgets/widget_tree.dart';

import '../support/pump.dart';

void main() {
  testWidgets('renders every node label', (tester) async {
    await pumpBody(tester, const WidgetTreeView(root: demoTree));
    expect(find.text('PhotoApp'), findsOneWidget);
    expect(find.text('PhotoTile'), findsWidgets);
  });

  testWidgets('shows parameters threaded through a node', (tester) async {
    await pumpBody(
      tester,
      const WidgetTreeView(root: demoTree, showParams: true),
    );
    expect(find.textContaining('photos'), findsWidgets);
  });

  testWidgets('flashing nodes are highlighted', (tester) async {
    await pumpBody(
      tester,
      const WidgetTreeView(root: demoTree, flashing: {'tile-1'}),
    );
    expect(find.byKey(const ValueKey('flash-tile-1')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run and watch it fail**

Run: `fvm flutter test test/widgets/widget_tree_test.dart` → Expected: FAIL.

- [ ] **Step 3: Implement**

`demoTree` is `PhotoApp → HomeScreen → PhotoGrid → PhotoTile ×2 → LikeButton`, five levels deep. `WidgetTreeView` lays nodes out in a `Column` of `Row`s, each node a bordered box. `flashing` node ids get a `Palette.blue` glow wrapped in a `Container(key: ValueKey('flash-$id'))`. `subscribed` ids draw a thin connector. `traversalTo` drives the A24 pulse: the node ids on the ancestor path light in sequence, derived from the step, not from a timer.

Parameters render as small chips under a node's label when `showParams` is true — this is what visibly falls away in A24.

- [ ] **Step 4: Run tests and commit**

```bash
fvm flutter test test/widgets/widget_tree_test.dart   # Expected: PASS
git add -A
git commit -m "feat: add shared widget tree view for state management section"
```

---

## Task 8: Unsplash client with offline fixture fallback

**Files:**
- Create: `lib/demos/unsplash_client.dart`, `lib/demos/photo.dart`, `assets/fixtures/unsplash_photos.json`
- Test: `test/demos/unsplash_client_test.dart`

**Interfaces:**
- Consumes: `dio`
- Produces:
  - `Photo({required String id, required String imageUrl, required String author, required int likes})` with `Photo.fromJson(Map<String, dynamic>)`
  - `UnsplashClient({String accessKey = const String.fromEnvironment('UNSPLASH_ACCESS_KEY'), Dio? dio, Future<String> Function(String)? loadAsset})` with `Future<PhotoResult> getPhotos()`
  - `PhotoResult({required List<Photo> photos, required bool fromFixture})`

- [ ] **Step 1: Write the failing tests**

```dart
// test/demos/unsplash_client_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/demos/unsplash_client.dart';

class _FailingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(o, s, f) async => throw DioException(
        requestOptions: RequestOptions(path: '/photos'),
        type: DioExceptionType.connectionError,
      );
}

const _fixture = '''
[{"id":"a1","urls":{"regular":"https://x/a1.jpg"},
  "user":{"name":"Ansel"},"likes":42}]
''';

void main() {
  test('parses a photo from the Unsplash shape', () {
    final photo = Photo.fromJson({
      'id': 'a1',
      'urls': {'regular': 'https://x/a1.jpg'},
      'user': {'name': 'Ansel'},
      'likes': 42,
    });
    expect(photo.id, 'a1');
    expect(photo.imageUrl, 'https://x/a1.jpg');
    expect(photo.author, 'Ansel');
    expect(photo.likes, 42);
  });

  test('falls back to the fixture when the network fails', () async {
    final dio = Dio()..httpClientAdapter = _FailingAdapter();
    final client = UnsplashClient(
      dio: dio,
      loadAsset: (_) async => _fixture,
    );
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
    expect(result.photos.single.author, 'Ansel');
  });

  test('falls back to the fixture when no key is configured', () async {
    final client = UnsplashClient(
      accessKey: '',
      loadAsset: (_) async => _fixture,
    );
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
  });
}
```

- [ ] **Step 2: Run and watch them fail**

Run: `fvm flutter test test/demos/unsplash_client_test.dart` → Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/demos/photo.dart
/// The model the bootcampers already have from Day 1, now fed by the API.
class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    required this.author,
    required this.likes,
  });

  /// Hand-written on purpose — writing this mapping is the lesson (spec §4).
  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as String,
        imageUrl: (json['urls'] as Map<String, dynamic>)['regular'] as String,
        author: (json['user'] as Map<String, dynamic>)['name'] as String,
        likes: json['likes'] as int,
      );

  final String id;
  final String imageUrl;
  final String author;
  final int likes;
}
```

`UnsplashClient` takes `accessKey` defaulting to `String.fromEnvironment('UNSPLASH_ACCESS_KEY')`, a `Dio` (injectable for tests) and a `loadAsset` function defaulting to `rootBundle.loadString`. `getPhotos()` returns the fixture immediately when `accessKey.isEmpty`; otherwise it calls `GET https://api.unsplash.com/photos?per_page=12` with header `Authorization: Client-ID $accessKey`, and on **any** `DioException` falls back to the fixture rather than throwing. `fromFixture` drives the "offline fixture" chip on slide 8.

Create `assets/fixtures/unsplash_photos.json` with 12 real Unsplash photo objects (id, urls.regular, user.name, likes) so the offline path looks identical to the live one.

- [ ] **Step 4: Run tests and commit**

```bash
fvm flutter test test/demos/unsplash_client_test.dart   # Expected: PASS
git add -A
git commit -m "feat: add Unsplash client with offline fixture fallback"
```

---
## Slide task conventions (Tasks 9–28)

Every slide task follows the same five-step cycle. It is written out in full here and referenced by number in each task, because repeating 40 identical TDD cycles would bury the content that actually differs.

**The cycle, for each slide in the task:**

1. **Register the slide.** Add its `SlideSpec` to `lib/slides/registry.dart` in the correct section block, with `route`, `section`, `steps`, and `speakerNotes` from this task. Point `body` at the new `{Name}Body`.
2. **Run the smoke test and watch it fail.** `fvm flutter test test/slides_smoke_test.dart` → FAIL, `{Name}Body` undefined. This is the RED step: the registry proves the gate covers the slide before the slide exists.
3. **Write the body.** Create `lib/slides/{section}/{name}_slide.dart` exporting `{Name}Body extends StatelessWidget` with a `final int step` field (the `DeckSlide` wrapper supplies `StepScope`, so `StepReveal` works without threading). Compose from Task 3–7 primitives. Never exceed 25 words of body copy.
4. **Run the gate.** `fvm flutter test && fvm flutter analyze` → PASS and clean. The smoke test now renders the slide at every step, both themes, both resolutions.
5. **Verify on screen, then commit.** `fvm flutter run -d chrome`, navigate to the route, arrow through every step **forward and backward**. Reverse traversal is not optional — it is the property that lets the coach answer a question mid-slide. Then commit with the slide number and animation ID.

**Speaker notes are required on every slide.** They are the coach's script and the audience never sees them. A slide with no notes is incomplete.

---

## Task 9: §0 Open — slides 1–4 (A1, A2)

**Files:**
- Create: `lib/slides/s00_open/title_slide.dart`, `beautiful_lie_slide.dart`, `roadmap_slide.dart`, `homework_slide.dart`
- Modify: `lib/slides/registry.dart`
- Test: covered by `test/slides_smoke_test.dart`

**Interfaces:**
- Consumes: `StepReveal`, `PhoneFrame`, `CodePanel`, `LiveSlideBody`
- Produces: `RoadmapSpine({required int activeNode, bool compact = false})` — reused as the section-opening chip on slides 5, 6, 15, 19, 25, 31, 39, 42, 44

**Slide 1 — `/title`** (1 step). `FlutterDeckSlide.title` via template override. "Flutter Bootcamp" / "Day 2 — Making It Real". Below, small: "Coach: Harsh Sharma · Assistant coaches: Harsh, Abhas".

**Slide 2 — `/beautiful-lie`** (3 steps, A1):
- Step 1: two `PhoneFrame`s side by side — a list screen and the detail screen it navigates to. Both look finished. Caption: *"Yesterday."*
- Step 2: both phones rotate up ~12° on the X axis (`Transform`, `Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(-0.21)`) and a `CodePanel` fades in beneath showing the shared hardcoded list. An `AnimatedArrow` from the code to **each** phone — the single source feeding both is the point.
- Step 3: `Callout` in `Palette.red`: *"Today: we delete this."* A strikethrough line draws across the code via `AnimatedArrow` styled flat.
- Notes: "They built two screens off one hardcoded list. One change today fixes both — that's slide 22. Ask: how many of you copy-pasted the list into the detail screen?"

**Slide 3 — `/roadmap`** (5 steps, A2). `RoadmapSpine` with five nodes: API · Auth · Data · Architecture · State. Node *n* lights at step *n* in `Palette.blue`; earlier nodes stay lit at `Tokens.dimmed`; later nodes are `Palette.textSecondary`. Build `RoadmapSpine` here with a `compact` variant (horizontal, 1/3 scale) for the section-opening chip.

**Slide 4 — `/homework`** (1 step). `LiveSlideBody(goal: 'Show us what you built.')`.
- Notes: "15 min. Pick 2–3 volunteers. Look for: a reusable row widget, ListView vs GridView choice, and whether navigation passes the whole model or just an id. That last one sets up the repository discussion in session 2."

- [ ] **Step 1: Slides 1–4, following the five-step cycle above**
- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "feat(slides-1-4): opening section with beautiful-lie reveal (A1, A2)"
```

---

## Task 10: §1 Folder structure — slide 5 (A3)

**Files:**
- Create: `lib/slides/s01_structure/structure_slide.dart`
- Modify: `lib/slides/registry.dart`

**Interfaces:**
- Consumes: `StepReveal`, `CorrelationPanel`, `AnimatedArrow`, `RoadmapSpine`

**Slide 5 — `/structure`** (9 steps, A3):
- Steps 1–6: `lib/` appears, then one folder docks per step from the left with a role label — `models/` ("what the data is"), `repo/` ("where it comes from"), `state/` ("what changes"), `screens/` ("what you route to"), `widgets/` ("what you reuse"), `main.dart` ("wiring").
- Step 7: the Android column fades in on the right joined by faint `AnimatedArrow`s — `data/model`, `data/repository`, `ui/viewmodel`, `ui/screen`, `ui/component`, `Application.kt`.
- Steps 8–9: two rules as `Callout`s — *"Files that change together live together"* and *"If you can't name the folder, you don't understand the feature yet."*
- Notes: "Don't debate folder philosophy. Point out it's the same structure they used in Android, renamed. The rule that matters: feature-first beats type-first as soon as you have two features."

- [ ] **Step 1: Slide 5, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slide-5): folder structure assembly with Android correlation (A3)`

---

## Task 11: §2 API part 1 — slides 6–8 (A4, A5)

**Files:**
- Create: `lib/slides/s02_api/api_gap_slide.dart`, `http_clients_slide.dart`, `live_first_request_slide.dart`

**Slide 6 — `/api-gap`** (3 steps, A4):
- Step 1: `PhoneFrame` left, a cloud glyph right, empty space between. No words.
- Step 2: a dashed `AnimatedArrow` attempts the crossing and stops halfway; a small `Palette.red` × pulses once at the break.
- Step 3: three boxes slide into the gap left-to-right — `Dio` → `Repository` → `Model` — and the arrow completes through them.

**Slide 7 — `/http-clients`** (4 steps, A5). `CorrelationPanel(flutterLabel: 'Dio', rows: [Android: 'Retrofit + OkHttp', iOS: 'URLSession / Alamofire', 'Java/Spring': 'RestTemplate / WebClient', Go: 'net/http'])`.
- Notes: "Dio is not new. It's the interceptor+client pair they already know. Don't sell it — just name the mapping and move to code."

**Slide 8 — `/live-first-request`** (1 step). `LiveSlideBody(goal: 'One GET. Print the JSON.')`.
- Notes: "Type it live, don't paste. `final dio = Dio(); final r = await dio.get('https://api.unsplash.com/photos', options: Options(headers: {'Authorization': 'Client-ID \$key'})); print(r.data);` — expect a 401 first if you 'forget' the header. That's deliberate; it sets up slide 15."

- [ ] **Step 1: Slides 6–8, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-6-8): API gap, HTTP client correlation, live request (A4, A5)`

---

## Task 12: §2 — slide 9, the frozen frame (A6) ⭐ PROTECTED

One of the four animations where the animation *is* the explanation. Give it the time it needs.

**Files:**
- Create: `lib/slides/s02_api/async_await_slide.dart`
- Create: `lib/widgets/frame_strip.dart`
- Modify: `test/support/pump.dart` (add the `stripPainterOf` helper — see Step 1)
- Test: `test/widgets/frame_strip_test.dart`

**Interfaces:**
- Produces: `FrameStrip({required int frameCount, required int stalledFrom, required int stalledTo, required bool stalled})` — 60 tick marks, green when flowing, `Palette.red` when stalled

**Slide 9 — `/async-await`** (4 steps, A6):
- Step 1: a `FrameStrip` of 60 ticks flowing green, and a `PhoneFrame` beside it with a rotating spinner. Label: *"60 fps."*
- Step 2: a `fetchPhotos()` block drops onto the strip. Ticks beneath it turn `Palette.red` and **stop**; the spinner in the phone **freezes mid-rotation** (drive its angle from the step, not from an `AnimationController`, so it genuinely halts). `Callout`: *"blocked · 2.3s · 138 frames dropped"*.
- Step 3: the same block detaches and floats to a second lane labelled `await — suspended`. The strip's ticks return to green and resume; the spinner spins again.
- Step 4: the result slides back into the main lane. `CorrelationPanel` chips fade in: Kotlin `suspend`, Swift `async/await`, Go goroutine, Java `CompletableFuture`.

Implementation note: the spinner must be driven by `step` (e.g. `Transform.rotate(angle: step >= 2 && step < 3 ? _frozenAngle : _animatedAngle)`) rather than a free-running controller. A controller would keep spinning during the "frozen" step and destroy the entire point of the slide.

- [ ] **Step 1: Write the failing `FrameStrip` test**

```dart
// test/widgets/frame_strip_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/widgets/frame_strip.dart';

import '../support/pump.dart';

void main() {
  testWidgets('all ticks flow green when not stalled', (tester) async {
    await pumpBody(
      tester,
      const FrameStrip(frameCount: 60, stalled: false, stalledFrom: 20, stalledTo: 45),
    );
    final painter = stripPainterOf(tester);
    expect(painter.stalled, isFalse);
    expect(painter.colorAt(30), Palette.green);
  });

  testWidgets('stalled range turns red', (tester) async {
    await pumpBody(
      tester,
      const FrameStrip(frameCount: 60, stalled: true, stalledFrom: 20, stalledTo: 45),
    );
    final painter = stripPainterOf(tester);
    expect(painter.colorAt(30), Palette.red);
    expect(painter.colorAt(10), Palette.green);
  });
}
```

(`stripPainterOf` is a helper added to `test/support/pump.dart` that finds the `CustomPaint` and casts its painter to `FrameStripPainter`. `colorAt(int index)` must be a public method on the painter.)

- [ ] **Step 2: Run and watch it fail** — `fvm flutter test test/widgets/frame_strip_test.dart` → FAIL
- [ ] **Step 3: Implement `FrameStrip` + `FrameStripPainter`**
- [ ] **Step 4: Run the test** → PASS
- [ ] **Step 5: Build slide 9 following the five-step cycle**
- [ ] **Step 6: Rehearse it.** Step forward and backward through all 4 steps twice. If the spinner ever moves during step 2, the slide is wrong — fix before committing.
- [ ] **Step 7: Commit** — `feat(slide-9): async/await frozen-frame animation (A6)`

---

## Task 13: §2 API part 3 — slides 10–14 (A7, A8, A9)

**Files:**
- Create: `lib/slides/s02_api/future_states_slide.dart`, `loading_state_slide.dart`, `error_swallowed_slide.dart`, `three_states_code_slide.dart`, `when_it_breaks_slide.dart`
- Create: `lib/demos/three_state_demo.dart`

**Slide 10 — `/future-states`** (3 steps, A7). One circle. Step 1: pulsing outline, label `pending`. Step 2: fills `Palette.blue`, label `data`. Step 3: a branch arrow to a second circle filling `Palette.red`, label `error`.

**Slide 11 — `/loading-state`** (1 step, A8) — **LIVE interactive.** `ThreeStateDemo`: a real `PhoneFrame` + three `FilledButton`s (`loading` / `error` / `data`) driving a genuine `AnimatedSwitcher` with `Tokens.fade`. Beside it, a `CodePanel` whose `highlightedLines` track the selected branch. This is a `StatefulWidget` with local state — it is deliberately **not** step-driven, because the audience drives it.
- Notes: "Hand the keyboard to someone. Make them click error. Ask what a user would do here."

**Slide 12 — `/error-swallowed`** (3 steps, A9). Step 1: `CodePanel` showing `try { … } catch (e) {}` with the empty block on `highlightedLines`. Step 2: a `PhoneFrame` with a spinner and a clock reading 5s → 30s (`step`-driven text). Step 3: `Callout` in red — *"They didn't file a bug. They left."*

**Slide 13 — `/three-states-code`** (3 steps). The `switch` over a sealed result type, `highlightedLines` walking loading → error → data. *Cut candidate — slide 11 already shows this running.*

**Slide 14 — `/when-it-breaks`** (3 steps). Three failure modes as `Callout`s, one per step: Android `INTERNET` permission missing; macOS missing `com.apple.security.network.client` entitlement; web CORS. Each with the exact error string they will see.
- Notes: "Put this on screen when someone's app hangs. Don't teach it cold."

- [ ] **Step 1: Slides 10–14, following the five-step cycle**
- [ ] **Step 2: Add an interaction test for the live demo**

```dart
// test/demos/three_state_demo_test.dart
testWidgets('tapping error swaps the phone content', (tester) async {
  await pumpBody(tester, const ThreeStateDemo());
  expect(find.byKey(const ValueKey('state-loading')), findsOneWidget);
  await tester.tap(find.text('error'));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('state-error')), findsOneWidget);
});
```

- [ ] **Step 3: Commit** — `feat(slides-10-14): loading and error states with live three-state demo (A7, A8, A9)`

---

## Task 14: §3 Auth — slides 15–16 (A10, A11) ⭐

A11 is the deck's longest animation at 9 steps. It gets its own reusable sequence-diagram widget because getting lane geometry right once is worth it.

**Files:**
- Create: `lib/slides/s03_auth/auth_401_slide.dart`, `oauth_flow_slide.dart`
- Create: `lib/widgets/sequence_diagram.dart`
- Test: `test/widgets/sequence_diagram_test.dart`

**Interfaces:**
- Produces:
  - `SequenceLane({required String id, required String label})`
  - `SequenceHop({required String from, required String to, required String label, required int atStep, Color? color, bool replay = false})`
  - `SequenceDiagram({required List<SequenceLane> lanes, required List<SequenceHop> hops})` — resolves lane x-positions, stacks hops vertically by step, draws each via `AnimatedArrow`
  - `TokenPill({required String label, required double widthFactor, required Color color, required bool expired})`

**Slide 15 — `/auth-401`** (3 steps, A10). Envelope flies phone→server, hits a wall, returns stamped `401`; phone shows an empty screen. Step 3: a key attaches and it passes.

**Slide 16 — `/oauth-flow`** (9 steps, A11). Lanes: `App` · `Browser` · `Auth Server` · `API`. Hops:
1. App → Browser — `open /authorize`
2. Browser — user logs in (avatar + tick, no lane crossing)
3. Auth Server → App — `code` (redirect)
4. App → Auth Server — `exchange code + secret`
5. Auth Server → App — **two `TokenPill`s**: `access_token` (`widthFactor: 0.35`, blue) and `refresh_token` (`widthFactor: 0.9`, green). The size difference carries the meaning; do not label it.
6. App → API — `GET /photos` ✓
7. *No hop.* The access `TokenPill` animates `expired: true` — shrinks to `widthFactor: 0` and greys. `Callout`: *"1 hour later."*
8. App → API — request → `401` in `Palette.red`
9. App → Auth Server — `refresh` → new access pill → **the step-8 hop redraws in `Palette.green`** (`replay: true`)

- Notes: "Step 7 is the whole point — nobody logged in again. The user saw nothing. Ask them where this lives in their Android app; answer is OkHttp Authenticator, which is slide 17."

- [ ] **Step 1: Write the failing `SequenceDiagram` test**

```dart
// test/widgets/sequence_diagram_test.dart
testWidgets('draws only hops up to the current step', (tester) async {
  await pumpBody(tester, const _OAuthFixture(), step: 3);
  expect(find.text('open /authorize'), findsOneWidget);
  expect(find.text('exchange code + secret'), findsNothing);
});

testWidgets('expired token pill collapses', (tester) async {
  await pumpBody(tester, const _OAuthFixture(), step: 7);
  final pill = tester.widget<TokenPill>(
    find.byKey(const ValueKey('pill-access')),
  );
  expect(pill.expired, isTrue);
});
```

`_OAuthFixture` is a private test-file widget you write alongside these tests: a
`SequenceDiagram` with the four lanes and the nine hops from slide 16 below, so the
diagram widget is tested against the real configuration it has to render.

- [ ] **Step 2: Run and watch it fail** → FAIL
- [ ] **Step 3: Implement `SequenceDiagram`, `SequenceHop`, `TokenPill`**
- [ ] **Step 4: Run the test** → PASS
- [ ] **Step 5: Build slides 15–16 following the five-step cycle**
- [ ] **Step 6: Rehearse all 9 steps forward and backward.** Every hop must be individually re-explainable.
- [ ] **Step 7: Commit** — `feat(slides-15-16): OAuth2 sequence diagram with token expiry (A10, A11)`

---

## Task 15: §3 Auth — slides 17–18 (A12, A13)

**Files:**
- Create: `lib/slides/s03_auth/interceptor_slide.dart`, `unsplash_reality_slide.dart`

**Slide 17 — `/auth-interceptor`** (4 steps, A12). A `CodePanel` of a Dio `onError` interceptor. `highlightedLines` walk: detect 401 → call refresh → update header → retry. Beside it a miniature `SequenceDiagram` (reuse Task 14) where the matching hop lights per step. Final step: `CorrelationPanel(flutterLabel: 'Dio Interceptor', rows: [Android: 'OkHttp Authenticator', iOS: 'URLSession delegate', 'Java/Spring': 'ClientHttpRequestInterceptor', Go: 'http.RoundTripper'])`.

**Slide 18 — `/unsplash-reality`** (2 steps, A13). Step 1: the full four-lane diagram from slide 16, scaled to 0.25 and dimmed, collapsing into one line of code: `Authorization: Client-ID abc123`. Step 2: a `Palette.red` `Callout` — *"`--dart-define`. Never in git."*
- Notes: "Say plainly: we taught you the full flow because that's what production looks like. Today's API needs one header. Knowing the difference is the skill."

- [ ] **Step 1: Slides 17–18, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-17-18): Dio interceptor and Unsplash key hygiene (A12, A13)`

---

## Task 16: §4 Data — slides 19–21 (A14)

**Files:**
- Create: `lib/slides/s04_data/json_to_dart_slide.dart`, `from_json_code_slide.dart`, `live_map_model_slide.dart`
- Create: `lib/widgets/field_flight.dart`

**Interfaces:**
- Produces: `FieldFlight({required String jsonKey, required String jsonValue, required String dartParam, required int atStep, required Offset from, required Offset to})` — one key-value travelling a curved path

**Slide 19 — `/json-to-dart`** (6 steps, A14). Raw JSON left, an empty `Photo(` constructor right. Steps 1–4: `id`, `urls.regular`, `user.name`, `likes` each lift out, travel a curved `AnimatedArrow` path, and land as a named argument; the consumed source line dims to `Tokens.dimmed`. Step 5: the arrow reverses briefly — `toJson`. Step 6 (**A15**): `CorrelationPanel(flutterLabel: 'fromJson', rows: [Android: 'Gson / Moshi / kotlinx', iOS: 'Codable', 'Java/Spring': 'Jackson', Go: 'encoding/json'])` plus a `Callout`: *"Dart has no runtime reflection. That's why."* — per spec §8 this is a step of this slide, not a slide of its own.

**Slide 20 — `/from-json-code`** (5 steps). `CodePanel` of `Photo.fromJson`, `highlightedLines` walking each field. Step 4 highlights the `factory` keyword with a `Callout`: *"factory = a constructor that doesn't have to return a new instance."* Step 5 highlights the named parameters with: *"Four Strings positionally is a bug waiting to happen — slide 42."*

**Slide 21 — `/live-map-model`** (1 step). `LiveSlideBody(goal: "Map the response onto yesterday's model.")`
- Notes: "Use their Day 1 Photo class as-is. Don't rename fields to match the API — the whole point is the mapping layer absorbs the difference. If someone asks why not just use the JSON map directly, that's the repository discussion after the break."

- [ ] **Step 1: Slides 19–21, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-19-21): JSON to Dart field flight and fromJson anatomy (A14)`

---

## Task 17: §4 Data — slides 22–24 (A16, A17) ⭐

Slide 22 is the emotional peak of session 1.

**Files:**
- Create: `lib/slides/s04_data/delete_hardcoded_slide.dart`, `codegen_slide.dart`, `break_slide.dart`

**Slide 22 — `/delete-hardcoded`** (3 steps, A16):
- Step 1: `CodePanel` showing the Day-1 hardcoded list verbatim (12 lines), and two `PhoneFrame`s beside it with grey placeholder tiles.
- Step 2: **the same `CodePanel` instance** is given new `code` — `final photos = await repo.getPhotos();`. Because `CodePanel` sets `animateCodeUpdate: true`, `diff_match_patch` cross-fades the exact changed characters. Do **not** swap widgets or use a key that forces a rebuild; the morph depends on the same element receiving new `code`.
- Step 3: both phones fill with real Unsplash images (via `UnsplashClient`, fixture-backed). `Callout`: *"One list. Two screens. Done."*
- Notes: "Pause here. This is the moment. Let them see both screens fill from one line."

**Slide 23 — `/codegen`** (2 steps, A17). Step 1: the 40-line hand-written `fromJson` collapses to `part 'photo.g.dart';` + 3 lines. Step 2: a terminal panel types `dart run build_runner build` and the generated file expands. *Cut candidate.*
- Notes: "Optional. Only run this if you're ahead of schedule. Frame it as 'you now understand what it generates' — that's why we did it by hand first."

**Slide 24 — `/break`** (1 step). Large: *"Break."* Below, small: *"Back in 15."* Nothing else.

- [ ] **Step 1: Slides 22–24, following the five-step cycle**
- [ ] **Step 2: Verify the morph specifically.** On slide 22, step forward then backward between steps 1 and 2 three times. The characters must cross-fade, not cut. If they cut, the `CodePanel` is being rebuilt with a new key — fix it.
- [ ] **Step 3: Commit** — `feat(slides-22-24): delete the hardcoded list with code morph (A16, A17)`

---

## Task 18: §5 Architecture — slides 25–30 (A18–A22)

**Files:**
- Create: `lib/slides/s05_architecture/god_file_slide.dart`, `three_layers_slide.dart`, `dependency_rule_slide.dart`, `testability_slide.dart`, `repository_slide.dart`, `live_extract_repo_slide.dart`
- Create: `lib/widgets/layer_slab.dart`

**Interfaces:**
- Produces: `LayerSlab({required String name, required List<Band> bands, required bool onFire})`, `Band({required String label, required Color color})` — the coloured bands must be **the same `Band` instances** in slides 25 and 26 so the sorting animation reads as continuity

**Slide 25 — `/god-file`** (4 steps, A18). A file rectangle grows taller across steps; interleaved `Band`s appear — UI (blue), network (green), parsing (amber), business rules (red). Step 4: a bug glyph lands; `Callout`: *"Where do you even look?"*

**Slide 26 — `/three-layers`** (8 steps, A19). Steps 1–5: the *same bands* separate and sort into three `LayerSlab`s — Presentation, Domain, Data. Steps 6–8: `CorrelationPanel(flutterLabel: 'Presentation / Domain / Data', rows: [Android: 'MVVM + UseCase', iOS: 'MVVM / VIPER', 'Java/Spring': 'Controller → Service → Repository'])`.

**Slide 27 — `/dependency-rule`** (4 steps, A20). Step 2: all arrows point inward toward Domain, `Palette.green`. Step 3: one flips outward, turns `Palette.red`, Domain slab gets `onFire: true` (red tint spreads). Step 4: a test panel beside it goes red — *"to test one rule you now need a network."*

**Slide 28 — `/testability`** (3 steps, A21). The Data slab slides out; `FakeRepository` slides in; **Domain does not move** (assert this in review — if the Domain slab shifts by even a pixel the animation lies). Timer text: `2400ms` → `3ms`.

**Slide 29 — `/repository`** (3 steps, A22). Two sources (API cloud, local DB) behind one door. A caller knocks; the door opens to the API; then the network drops out and the same knock opens to the cache. Caller unchanged.

**Slide 30 — `/live-extract-repo`** (1 step). `LiveSlideBody(goal: 'Pull the Dio call out of the widget.')`
- Notes: "Do it as a refactor, not a rewrite. Cut the dio.get out of build(), paste into PhotoRepository, inject it. Ask what just got easier to test."

- [ ] **Step 1: Slides 25–30, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-25-30): clean architecture layers and repository pattern (A18-A22)`

---

## Task 19: §6 State — slides 31–33 (A23, A24) ⭐ PROTECTED

**Files:**
- Create: `lib/slides/s06_state/state_problem_slide.dart`, `inherited_widget_slide.dart`, `inherited_limits_slide.dart`

**Slide 31 — `/state-problem`** (5 steps, A23). Uses `WidgetTreeView` (Task 7) with `demoTree`.
- Step 1: the tree, data at the root, the leaf that needs it marked.
- Step 2: `showParams: true` — the value threads down; every middle node gains a `photos` chip. `Callout`: *"doesn't care, still has to carry it."*
- Step 3: a callback threads back **up**; middle nodes gain `onTap:` chips.
- Step 4: a second piece of state; chip count on every middle node doubles.
- Step 5: `flashing:` set to **every** node id — `setState` at the root rebuilds the whole tree.

**Slide 32 — `/inherited-widget`** (8 steps, A24). Same `demoTree`, visual continuity is essential.
- Step 1: a `PhotoScope` node slides in near the root.
- Step 2: `showParams: false` — the chips **fall away** (animate downward + fade, do not just vanish).
- Step 3: `traversalTo: 'like-button'` — the ancestor-chain pulse travels **up**, node by node, and locks onto the scope. Annotate with `dependOnInheritedWidgetOfExactType<PhotoScope>()`.
- Step 4: a second leaf subscribes; a third explicitly does not.
- Step 5: data changes — `flashing:` contains only the two subscriber ids. The non-subscriber stays dark.
- Steps 6–8: `CorrelationPanel(flutterLabel: 'InheritedWidget', rows: [Android: 'CompositionLocal', iOS: '@Environment', Web: 'React Context'])`.
- Notes: "Step 3 is the one they'll remember. Say it out loud: lookup is O(1), not a tree walk at runtime — Flutter caches it per element. The *animation* shows the conceptual walk."

**Slide 33 — `/inherited-limits`** (2 steps, A25). The scope node highlights; `Callout`: *"It's immutable. Something else has to rebuild it."* Step 2: an awkward `setState` wrapper appears around it.
- Notes: "This slide exists so ChangeNotifier looks necessary instead of arbitrary. Don't skip it."

- [ ] **Step 1: Slides 31–33, following the five-step cycle**
- [ ] **Step 2: Verify continuity.** Navigate 31 → 32 and confirm the tree does not jump. Node positions must be identical across the slide boundary; if they shift, extract the layout constants into a shared const.
- [ ] **Step 3: Commit** — `feat(slides-31-33): prop drilling and InheritedWidget tree traversal (A23-A25)`

---

## Task 20: §6 State — slides 34–35 (A26, A27) ⭐ PROTECTED

**Files:**
- Create: `lib/slides/s06_state/change_notifier_slide.dart`, `provider_fusion_slide.dart`
- Create: `lib/demos/notifier_demo.dart`

**Slide 34 — `/change-notifier`** (9 steps, A26). Hybrid: step-driven diagram **plus** a genuinely tappable button.
- Step 1: a model box beside the tree.
- Step 2: `addListener()` draws a labelled line from each subscribing leaf to the model — the method name annotates the line as it draws.
- Step 3: a real `FilledButton` appears. Tapping it calls `counter.increment()` on a real `ChangeNotifier`; the method name flashes on the model box.
- Step 4: `notifyListeners()` — a ring pulses outward along every registered line (`TweenAnimationBuilder` on a radius, keyed to the notifier's value so repeat taps re-pulse).
- Step 5: connected leaves flash and their numbers tick up; unconnected stay dark.
- Step 6: one leaf `dispose()`s — its line snaps; the next pulse skips it.
- Steps 7–9: `CorrelationPanel(flutterLabel: 'ChangeNotifier', rows: [Android: 'LiveData / StateFlow', iOS: 'ObservableObject / @Published', 'Java/Spring': 'PropertyChangeListener'])`.
- Notes: "Let them tap it several times. Every arrow is labelled with the real method name — point at each one as you say it."

**Slide 35 — `/provider-fusion`** (3 steps, A27). The `InheritedWidget` box and `ChangeNotifier` box slide together and fuse into `ChangeNotifierProvider`; surrounding boilerplate collapses; a line counter animates `38 → 6`.

- [ ] **Step 1: Slides 34–35, following the five-step cycle**
- [ ] **Step 2: Add an interaction test**

```dart
// test/demos/notifier_demo_test.dart
testWidgets('tapping increment pulses subscribers', (tester) async {
  await pumpBody(tester, const NotifierDemo(), step: 5);
  expect(find.text('0'), findsWidgets);
  await tester.tap(find.byKey(const ValueKey('increment')));
  await tester.pumpAndSettle();
  expect(find.text('1'), findsWidgets);
});
```

- [ ] **Step 3: Commit** — `feat(slides-34-35): ChangeNotifier pulse and Provider fusion (A26, A27)`

---

## Task 21: §6 State — slide 36, rebuild scope (A28) ⭐⭐ HIGHEST RISK

The single highest-value slide and the hardest build. **Attempt the real instrumentation first.** The spec's fallback is a staged animation that looks identical — but decide early, not after a day of fighting it.

**Files:**
- Create: `lib/slides/s06_state/watch_read_consumer_slide.dart`
- Create: `lib/demos/rebuild_scope_demo.dart`, `lib/widgets/rebuild_flash.dart`
- Test: `test/widgets/rebuild_flash_test.dart`

**Interfaces:**
- Produces: `RebuildFlash({required String id, required Widget child})` — increments a counter and triggers a brief `Palette.blue` overlay **inside its own `build`**, so it flashes exactly when Flutter actually rebuilds it
- Produces: `RebuildTally` — a `ChangeNotifier` counting rebuilds this frame, displayed live, with `int countFor(String id)`
- Produces: `RebuildTallyScope({required RebuildTally tally, required Widget child})` with `RebuildTallyScope.of(BuildContext) -> RebuildTally`

**Slide 36 — `/watch-read-consumer`** (1 step, A28) — **LIVE interactive, not step-driven.**
- The `demoTree` rendered as real widgets inside a real `ChangeNotifierProvider`.
- Three `SegmentedButton` options: `context.watch` (at the root) · `context.read` · `Consumer` (around one leaf).
- Every node wrapped in `RebuildFlash`. A live readout: *"rebuilds this frame: N"*.
- Switching to `watch` at the root makes a large region flash on every notifier tick; switching to `Consumer` shrinks the flashing region to one node and the readout drops from ~14 to 1.
- Notes: "Hand over the keyboard. Don't assert that Consumer is better — make them watch the flash region shrink. Then ask which one they'd reach for by default."

- [ ] **Step 1: Write the failing `RebuildFlash` test**

```dart
// test/widgets/rebuild_flash_test.dart
testWidgets('counts a rebuild each time it builds', (tester) async {
  final tally = RebuildTally();
  final notifier = ValueNotifier(0);
  await pumpBody(
    tester,
    RebuildTallyScope(
      tally: tally,
      child: ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (_, v, __) =>
            RebuildFlash(id: 'node-a', child: Text('$v')),
      ),
    ),
  );
  expect(tally.countFor('node-a'), 1);

  notifier.value = 1;
  await tester.pumpAndSettle();
  expect(tally.countFor('node-a'), 2);
});
```

- [ ] **Step 2: Run and watch it fail** → FAIL
- [ ] **Step 3: Implement `RebuildTally`, `RebuildTallyScope`, `RebuildFlash`**

`RebuildFlash.build` calls `RebuildTallyScope.of(context).record(id)` and drives a short `Palette.blue` overlay whose opacity decays via a `TweenAnimationBuilder` re-keyed on the count. Because the flash is triggered from `build`, it fires if and only if Flutter genuinely rebuilt the widget — which is the property that makes the slide honest.

**Guard:** `record()` mutates a `ChangeNotifier` during build, which will throw if it notifies synchronously. Defer the notify with `WidgetsBinding.instance.addPostFrameCallback`.

- [ ] **Step 4: Run the test** → PASS
- [ ] **Step 5: Build the demo and slide 36**
- [ ] **Step 6: Decision gate.** Run it and switch modes. If the flash regions do **not** visibly differ between `watch`-at-root and `Consumer`-at-leaf, stop and fall back to the staged animation recorded in spec §14. Report which path was taken.
- [ ] **Step 7: Commit** — `feat(slide-36): live rebuild-scope demo for watch/read/Consumer (A28)`

---

## Task 22: §6 State — slides 37–38 (A29)

**Files:**
- Create: `lib/slides/s06_state/state_decision_slide.dart`, `live_convert_provider_slide.dart`

**Slide 37 — `/state-decision`** (4 steps, A29). One row per step, minimal text:
- `setState` → local and ephemeral
- `InheritedWidget` → read-only config, down the tree
- `ChangeNotifier + Provider` → shared and mutable
- *"Bloc / Riverpod exist for when this starts to hurt."*

**Slide 38 — `/live-convert-provider`** (1 step). `LiveSlideBody(goal: 'Convert both screens to Provider.')`
- Notes: "List screen first, then detail. The detail screen is the interesting one — ask whether it should read the provider or take the model as a constructor argument. Both are defensible; make them argue it."

- [ ] **Step 1: Slides 37–38, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-37-38): state management decision table and live conversion (A29)`

---

## Task 23: §7 DI — slides 39–41 (A30–A32)

**Files:**
- Create: `lib/slides/s07_di/di_problem_slide.dart`, `di_multiprovider_slide.dart`, `di_testing_slide.dart`

**Slide 39 — `/di-problem`** (3 steps, A30). `main.dart` with three objects constructed manually and threaded four levels down; `AnimatedArrow`s cross. Step 3: one more dependency — six more lines, worse crossing.

**Slide 40 — `/di-multiprovider`** (5 steps, A31). Steps 1–2: the spaghetti collapses into a `MultiProvider` block; crossing lines straighten into a list. Steps 3–5: `CorrelationPanel(flutterLabel: 'MultiProvider', rows: [Android: 'Hilt @Module / Koin module {}', iOS: 'init injection', 'Java/Spring': '@Bean / @Configuration', Go: 'wire'])`.
- Notes: "Say explicitly: Provider is already in the app for state, so DI costs them zero new packages. Mention get_it exists in one sentence and move on."

**Slide 41 — `/di-testing`** (2 steps, A32). One line in the provider list swaps `PhotoRepository` → `FakePhotoRepository`; the subtree beneath turns `Palette.green` "under test"; nothing else changes.
- Notes: "Callback to slide 28. Same idea, now at the wiring level. This is the answer to 'why bother with DI' — one line and the whole tree is testable."

- [ ] **Step 1: Slides 39–41, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-39-41): dependency injection with MultiProvider (A30-A32)`

---

## Task 24: §8 Dart bits — slides 42–43 (A33, A34)

**Files:**
- Create: `lib/slides/s08_dart/named_params_slide.dart`, `cascade_spread_slide.dart`

**Slide 42 — `/named-params`** (3 steps, A33). Step 1: `CodePanel` with `Photo('a1', 'https://…', 'Ansel', true)`. Step 2: `Callout`s with `?` over each argument — *"which is which?"* Step 3: the **same `CodePanel`** receives named-argument code; `animateCodeUpdate` morphs it and the callouts resolve into labels.

**Slide 43 — `/cascade-spread`** (2 steps, A34). Step 1: a repeated-variable block morphs into `..` cascade form. Step 2: `[...list, item]` expands, elements flowing out of the spread.
- Notes: "Ninety seconds total. They'll meet these in the codebase; they don't need a lecture."

- [ ] **Step 1: Slides 42–43, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-42-43): named parameters, cascade and spread (A33, A34)`

---

## Task 25: §9 Hands-on — slide 44, design to widget tree (A35) ⭐

**Files:**
- Create: `lib/slides/s09_handson/design_to_tree_slide.dart`
- Create: `lib/demos/gopay_payment_screen.dart`
- Create: `assets/images/gopay/` (payment method icons)

**Interfaces:**
- Produces: `GoPayPaymentScreen({Set<String> highlightedRegions = const {}})` — a real Flutter rebuild of the "Select payment method" screen, with named regions (`header`, `section-title`, `row-gopay`, `row-paylater`, `row-cicil`, `row-card`, `cta`) that can be individually outlined

**Slide 44 — `/design-to-tree`** (7 steps, A35). `GoPayPaymentScreen` renders left. Each step draws a `DashedBox` around one region and its widget name flies right to assemble the tree: `Scaffold` → `Column` → `SectionHeader` → `ListView` → `PaymentRow` → `[Icon, Column[Title, Subtitle], Trailing]`. The tree grows with every tap.
- Notes: "Make them call out the widget before you reveal it. This is the skill: reading a design as a hierarchy. Don't rush it."

Build the screen from the reference photo: header "Select payment method", a "Payment methods" section with subtitle "Swipe left to set as default", rows for GoPay Coins / GoPay / GoPayLater / GoPayLater Cicil / Jago / card entries, and an "Add methods" section. Neutral reconstruction — approximate layout and iconography, no lifted brand assets.

- [ ] **Step 1: Build `GoPayPaymentScreen` with region keys**
- [ ] **Step 2: Add a widget test asserting each named region renders and can be highlighted**
- [ ] **Step 3: Build slide 44 following the five-step cycle**
- [ ] **Step 4: Commit** — `feat(slide-44): GoPay screen to widget tree decomposition (A35)`

---

## Task 26: §9 Hands-on — slides 45–47, BFF contract reveal (A36) ⭐

**Files:**
- Create: `lib/slides/s09_handson/bff_row_plain_slide.dart`, `bff_row_warning_slide.dart`, `bff_row_error_slide.dart`

Each slide: `GoPayPaymentScreen` left, JSON right, a self-drawing `AnimatedArrow` connecting one row to its fragment, **and** a highlight on the Dart property that JSON drives.

**Slide 45 — `/bff-row-plain`** (4 steps, A36a). Row `row-gopay`. JSON fragment:
```json
{"title": "GoPay", "descriptions": [{"type": "DEFAULT", "value": "Balance: Rp500.000"}],
 "cta": {"type": "radio_button", "value": "true"}}
```
Steps: highlight row → arrow draws → JSON appears → Dart property lights (`cta.type` → `Radio(value:)`).

**Slide 46 — `/bff-row-warning`** (4 steps, A36b). Row `row-cicil`. JSON adds `"descriptions": [{"type": "INFO", "value": "Limit Rp500.000", "attributes": {"color_token": "default"}}]` and `"cta": {"type": "info", "dialog": {"title": "…", "description": "You have exceeded limit for this month"}}`. Final step lights `color_token` → `style: theme.amber` and the info CTA → `showDialog`.

**Slide 47 — `/bff-row-error`** (4 steps, A36c). Row `row-jago`. JSON: `"descriptions": [{"type": "ERROR", "value": "Under maintenance", "attributes": {"color_token": "error"}}]`, `"enabled": false`, and `"cta": {"type": "DEEP_LINK", "value": {"android": "gojek://paymentwidget/card", "ios": "gojek://paymentwidget/card", "web": "…"}}`. Final step lights `color_token: "error"` → `style: theme.error` and the platform action map.
- Notes across all three: "The server decided the colour. The client just rendered it. Ask what happens when design wants a new state — who ships?"

- [ ] **Step 1: Slides 45–47, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-45-47): BFF contract reveal with annotated arrows (A36)`

---

## Task 27: §9 Hands-on — slides 48–49 (A37)

**Files:**
- Create: `lib/slides/s09_handson/bff_vs_nonbff_slide.dart`, `assignment_slide.dart`

**Slide 48 — `/bff-vs-nonbff`** (4 steps, A37). Split screen, identical UI both sides.
- Step 1: left JSON rich, right JSON bare `{"id": "gopay", "type": "wallet", "balance": 500000}`.
- Step 2: left client code is a thin `switch`; right client code starts stacking `if`s.
- Step 3: the right side's line count climbs visibly (step-driven counter).
- Step 4: a new payment type is added — left needs zero client changes; right needs an app release. `Callout`: *"Ships in: 1 day vs 6 weeks."*
- *Cut candidate.*

**Slide 49 — `/assignment`** (3 steps). Tonight's homework, one line per step:
1. Wire your list + detail screens to the real API.
2. Handle loading and error states — both screens.
3. Move the Dio call behind a repository, provide it with `MultiProvider`.

- [ ] **Step 1: Slides 48–49, following the five-step cycle**
- [ ] **Step 2: Commit** — `feat(slides-48-49): BFF vs non-BFF contrast and assignment (A37)`

---

## Task 28: §10 Close and final integration

**Files:**
- Create: `lib/slides/s10_close/references_slide.dart`, `thanks_slide.dart`
- Modify: `lib/main.dart`, `README.md`

**Slide 50 — `/references`** (6 steps). One group per step, official source first, best community resource second. Content verbatim from spec §10: Dart/async · Networking · JSON · Architecture · State management · Performance, BFF, Unsplash, flutter_deck.

**Slide 51 — `/thanks`** (1 step). "Thank you" + Q&A, footer hidden.

- [ ] **Step 1: Slides 50–51, following the five-step cycle**

- [ ] **Step 2: Full-deck verification**

```bash
fvm flutter test                 # Expected: all green, ~200 smoke cases
fvm flutter analyze              # Expected: no issues
```

- [ ] **Step 3: Run the deck end to end**

```bash
fvm flutter run -d chrome --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
```

Arrow through all 51 slides **forward, then all the way back**. Confirm: no slide overflows; every animation reverses cleanly; the header shows the right section throughout; slide numbers are contiguous.

- [ ] **Step 4: Verify the offline path**

Run with no `--dart-define`. Every slide must still render and slides 8/11/22 must show the "offline fixture" chip rather than an error.

- [ ] **Step 5: Verify presenter view**

Open the navigation drawer, launch presenter view, and confirm speaker notes appear on the second screen for at least slides 4, 9, 16, 32 and 36.

- [ ] **Step 6: Write the README**

Cover: prerequisites (`fvm use`), how to run with and without the key, how to present (Chrome primary, macOS backup), how to cut a slide (delete one `SlideSpec` from `registry.dart`), and where the spec and plan live.

- [ ] **Step 7: Build the shareable artifact**

```bash
fvm flutter build web --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
cd build/web && python3 -m http.server 8080
```

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(slides-50-51): references and closing, plus README"
```

---

## Deferred decisions

Recorded so they are made deliberately rather than by drift:

- **Final cut from 51.** Candidates: 23 (codegen), 48 (non-BFF), 13 (three-states code). Cutting is one `SlideSpec` deletion from `registry.dart` — decide after a full rehearsal, not before.
- **A11 length.** Stays at 9 steps. Compress to 6 by merging the authorize/login/code hops only if it drags in rehearsal.
- **A28 fallback.** Task 21 Step 6 is the gate. Whichever path is taken must be reported, not silently chosen.
