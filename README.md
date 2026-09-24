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
  `macos/Runner/*.entitlements`, which is itself the teaching moment on slide 11.
- Arrow keys step through animations; every step is reversible, so stepping backward
  re-hides things correctly.

Slides 4, 7, 18, 25 and 33 are **live-coding slides** — they are nearly empty on
purpose. The slide states the goal; the work happens in the editor.

## Cutting a slide

Delete one `SlideSpec` from `lib/slides/registry.dart`. That is the whole operation:
the registry is the single source of truth for both `main.dart` and the smoke test.

Pre-identified cut candidates if you are running long: `/codegen` (19),
`/state-decision` (31), `/three-states-code` (11).

## Tests

```bash
fvm flutter test      # ~780 cases
fvm flutter analyze
```

The bulk is `test/slides_smoke_test.dart`: every slide, at every step, in light and dark,
at 1920×1080 and 1280×720, asserting no exception and no overflow. That is the failure
that actually matters — a slide breaking in front of an audience — and adding a
`SlideSpec` adds its coverage automatically.

## Publishing

The deck is on GitHub Pages at
<https://harshsharma94.github.io/flutter-presentation/>, built and deployed by
`.github/workflows/pages.yml` on every push to `main`.

**One-time setup:** repository → Settings → Pages → *Source* → **GitHub
Actions**. Left on "Deploy from a branch" it serves the repository root, which
holds a README and no `index.html` — which is why github.io renders the README.

The flag that matters is `--base-href "/flutter-presentation/"`. A project page
is served from `/<repo>/`, not from the domain root, so without it every asset
path resolves one level too high and the page loads blank with a console full
of 404s. The workflow derives it from the repository name, so a rename cannot
break it.

The build passes no `--dart-define`. `UNSPLASH_ACCESS_KEY` would be compiled
into a public JavaScript bundle that anyone could read; the deck falls back to
a bundled fixture without it, which is what the live-demo slides use anyway.

### Publishing without Actions

Pages can serve a folder on `main` instead — at the cost of committing the
compiled output, about 3 MB of JavaScript, and rebuilding by hand on every
content change:

```bash
fvm flutter build web --release \
  --base-href "/flutter-presentation/" --pwa-strategy=none
rm -rf docs && cp -R build/web docs && touch docs/.nojekyll
git add -f docs
```

Commit and push that, then set Settings → Pages → *Source* → **Deploy from a
branch** → `main` → `/docs`. The `-f` is needed because `build/` is gitignored,
and `.nojekyll` stops Pages running Jekyll over the output.

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
   9, the notifier pulse on slide 29, the rebuild flashes on slide 31 — where the motion
   *is* the lesson.

Presenter material:

- `docs/presenter-guide.md` — live-coding scripts, exact commands, and the
  stuck-points for each slide. Not part of the deck; keep it on a second
  screen. Covers slides 1–12 (the whole API section) so far.

Design and implementation notes:

- `docs/superpowers/specs/2026-09-22-flutter-bootcamp-day2-deck-design.md`
- `docs/superpowers/plans/2026-09-22-flutter-bootcamp-day2-deck.md`
