# Presenter guide

Live-coding scripts and stuck-points, slide by slide. **Not part of the deck** —
keep it on your phone or a second machine. Speaker notes inside the deck cover
*what to say*; this covers *what to type* and *what breaks*.

Covers slides 1–7 so far. Extend as the deck settles.

---

## Slide 1 — `/title`

Nothing to type. Thirty seconds: names, then move.

Ask them to pick dark or light. The toggle is in the navigation drawer — press
`.` to open it. Do this now rather than mid-session; switching themes later
costs you the room's attention for a minute.

---

## Slide 2 — `/beautiful-lie`

Nothing to type. This is the hook.

Ask, before advancing: **"how many of you copy-pasted the list into the second
screen?"** Most hands go up. That is the setup for slide 21, where one line
replaces it.

Do not explain the fix here. The whole point is that they sit with the problem
for a moment.

---

## Slide 3 — `/roadmap`

Nothing to type. Five stops, in order. Do not teach anything.

---

## Slide 4 — `/homework`

15 minutes, 2–3 volunteers on the projector. What to look for, in priority
order:

1. **A reusable row widget** — or the same `Container` pasted six times.
2. **`ListView` vs `GridView`** — ask why they chose it.
3. **What navigation passes.** Whole model, or just an id? This is the one to
   dwell on. If they pass the whole model, ask what happens when the detail
   screen needs a field the list never loaded. That is the repository
   discussion in session 2, and it lands much harder if they hit it themselves
   here.

Do not fix their code live. Note the issue, move on.

---

## Slide 5 — `/api-gap`

Nothing to type. Three taps.

If someone asks "what's between them?" — that is the next two slides. Don't
name Dio yet; they have no reason to care about it until they have felt the
gap.

---

## Slide 6 — `/http-clients`

The correlation lands on tap 4, then the setup panel appears.

**Everyone runs this now, together.** A third of the room stalls here, and a
stalled room cannot follow slide 7.

```bash
flutter pub add dio
```

This writes into `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.8.0
```

Then:

```bash
flutter pub get
```

**Version note.** Dio 5.x runs on Flutter 3.29.3 (Dart 3.7). If someone is on
an older Flutter and `pub get` refuses, the fastest unblock is pinning a 5.x
release rather than debugging their SDK mid-session — they can upgrade later.

**Stuck-points:**

| Symptom | Cause | Fix |
|---|---|---|
| `Because <app> depends on dio ... version solving failed` | Their Flutter/Dart is older than the constraint | Pin an older 5.x, or have them pair with a neighbour for now |
| `Target of URI doesn't exist: 'package:dio/dio.dart'` | `pub get` hasn't run, or the IDE hasn't reindexed | Re-run `flutter pub get`, then restart the analysis server |
| Added under `dev_dependencies` | Wrong section | Move it to `dependencies` |

Say explicitly: **no build_runner, no codegen.** It is a plain package. Some of
them will have heard Retrofit needs an annotation processor and will be bracing
for it.

---

## Slide 7 — `/live-first-request`

**Goal:** one GET, print what comes back.
**Constraint:** Dio only. No `async`, no `await`.

Tap 2 reveals the hints — hold it back and let them try first. The constraint
is deliberate: a `Future` they cannot `await` is exactly the discomfort slide 8
resolves. If someone already knows `async`/`await` and writes it, let them, but
ask them to also write the `.then()` version so the room sees both.

Type this live. Do not paste — they need to see it built.

```dart
import 'package:dio/dio.dart';

void main() {
  final dio = Dio();

  dio.get('https://api.unsplash.com/photos')
      .then((response) => print(response.data));
}
```

**Run it and let it fail first.** With no credential, Unsplash answers `401`.
That is not a mistake — it sets up slide 14. When someone points it out, say
"good, hold that thought" and add the header:

```dart
final dio = Dio();

dio.get(
  'https://api.unsplash.com/photos',
  options: Options(
    headers: {'Authorization': 'Client-ID $accessKey'},
  ),
).then((response) => print(response.data));
```

**Where the key comes from.** Have your own ready. Do not put it in source —
pass it in and say why in one sentence:

```bash
flutter run --dart-define=UNSPLASH_ACCESS_KEY=xxxx
```

```dart
const accessKey = String.fromEnvironment('UNSPLASH_ACCESS_KEY');
```

**Questions you will get, and short answers:**

- *"Why `.then` and not `await`?"* — Next slide. One minute.
- *"What type is `response.data`?"* — `dynamic`; Dio decoded the JSON into
  Dart maps and lists already. Turning that into a real object is §3.
- *"Can I use `http` instead of Dio?"* — Yes, and it works fine. We use Dio
  because interceptors matter in §2, and that is where it earns its place.

**Stuck-points:**

| Symptom | Cause | Fix |
|---|---|---|
| Hangs forever, no output | Android emulator without the `INTERNET` permission | `AndroidManifest.xml` — this is slide 13, put it on screen |
| `SocketException` on macOS | Missing network entitlement | `macos/Runner/*.entitlements`, both debug and release |
| CORS error in Chrome | Browser blocking the cross-origin call | Run on a device or desktop for this exercise |
| Prints `Instance of 'Response'` | Printed `response`, not `response.data` | Point at it and move on |
