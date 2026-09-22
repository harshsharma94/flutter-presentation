# Flutter Bootcamp — Day 2 Deck

A 51-slide, animated Flutter deck for **Day 2: State Management & Architecture**, built
with [flutter_deck](https://github.com/mkobuolys/flutter_deck).

The audience is engineers who are new to Flutter but not new to software — roughly two
months of Android, iOS, Java/Spring or Go behind them. Almost every concept is introduced
by naming what they already call it on their own platform.

## Prerequisites

Flutter **3.47.5** (flutter_deck 0.29.0 needs ≥ 3.32.0 / Dart ≥ 3.8.0). The repo pins it
with [fvm](https://fvm.app):

```bash
fvm use          # installs and pins the version in .fvmrc
fvm flutter pub get
```

Every command below is `fvm flutter …` — a bare `flutter` may resolve to a different SDK.

## Running it

```bash
# with live Unsplash data
fvm flutter run -d chrome --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY

# without a key — everything still renders
fvm flutter run -d chrome
```

**The deck never needs the network.** `UnsplashClient` falls back from the live API to a
bundled fixture to a small in-memory list, so no slide can fail because of venue wifi.
Without a key, the data slides show an "offline fixture" chip instead of an error. Fonts
are bundled too.

The key is read via `String.fromEnvironment` and is never committed.

## Presenting

- **Primary: Chrome.** `FlutterDeckWebClient` gives presenter view — speaker notes on a
  second screen — for free. Open the navigation drawer to launch it.
- **Backup: macOS.** `fvm flutter run -d macos`. Needs the network entitlement in
  `macos/Runner/*.entitlements`, which is itself the teaching moment on slide 14.
- Arrow keys step through animations; every step is reversible, so stepping backward
  re-hides things correctly.

Slides 12, 21, 30, 36 and 38 are **live-coding slides** — they are nearly empty on
purpose. The slide states the goal; the work happens in the editor.

## Cutting a slide

Delete one `SlideSpec` from `lib/slides/registry.dart`. That is the whole operation:
the registry is the single source of truth for both `main.dart` and the smoke test.

Pre-identified cut candidates if you are running long: `/codegen` (23),
`/bff-vs-nonbff` (48), `/three-states-code` (13).

## Tests

```bash
fvm flutter test      # ~780 cases
fvm flutter analyze
```

The bulk is `test/slides_smoke_test.dart`: every slide, at every step, in light and dark,
at 1920×1080 and 1280×720, asserting no exception and no overflow. That is the failure
that actually matters — a slide breaking in front of an audience — and adding a
`SlideSpec` adds its coverage automatically.

## Building a shareable artifact

```bash
fvm flutter build web --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
cd build/web && python3 -m http.server 8080
```

## How it is put together

| Path | What lives there |
|---|---|
| `lib/slides/registry.dart` | the ordered list of all 51 slides |
| `lib/slides/slide_spec.dart` | `SlideSpec` + the flutter_deck wrapper |
| `lib/widgets/step_reveal.dart` | the deck's one animation primitive |
| `lib/widgets/` | shared diagram pieces — arrows, trees, code panels, layer slabs |
| `lib/demos/` | the genuinely interactive bits (rebuild counter, notifier, API client) |
| `lib/theme/` | palette and motion tokens |

Two conventions carry the whole deck:

1. **Every slide is a thin wrapper plus a pure `Body` widget** that takes `step` as a
   plain `int`. That is what lets the smoke test pump any slide with no router, no mocks
   and no codegen.
2. **Visibility is a pure function of `(step, theme)`.** Explanatory motion uses no
   `AnimationController` and no `Timer`, so every animation is presenter-paced and
   reverses cleanly. The exceptions are deliberate and few — an ambient spinner on slide
   9, the notifier pulse on slide 34, the rebuild flashes on slide 36 — where the motion
   *is* the lesson.

Design and implementation notes:

- `docs/superpowers/specs/2026-09-22-flutter-bootcamp-day2-deck-design.md`
- `docs/superpowers/plans/2026-09-22-flutter-bootcamp-day2-deck.md`
