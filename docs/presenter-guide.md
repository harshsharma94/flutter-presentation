# Presenter guide

Live-coding scripts and stuck-points, slide by slide. **Not part of the deck** —
keep it on your phone or a second machine. Speaker notes inside the deck cover
*what to say*; this covers *what to type* and *what breaks*.

Covers slides 1–12 (the API section). Extend as the deck settles.

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
screen?"** Most hands go up. That is the setup for slide 18, where one line
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

The URL on tap 3 is `https://picsum.photos/v2/list` — no key, no account. We
do not touch Unsplash until §2 Auth, because a 401 you cannot explain yet is
just noise.

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

  dio.get('https://picsum.photos/v2/list')
      .then((response) => print(response.data));
}
```

**Picsum, not Unsplash.** No key, no account, no `Authorization` header. They
have not met auth yet, and a 401 they cannot explain is noise, not a lesson.
Unsplash arrives in §2 Auth and the exercise there is unchanged.

**Then break it on purpose.** Ask them to put the result in a variable:

```dart
final response = dio.get('https://picsum.photos/v2/list');
print(response);          // Instance of 'Future<Response>'
```

That is the whole setup for the next two slides. They are holding a receipt,
not a photo list.

**Questions you will get, and short answers:**

- *"Why `.then` and not `await`?"* — Two slides away. Ninety seconds.
- *"What type is `response.data`?"* — `dynamic`; Dio already decoded the JSON
  into Dart maps and lists. Turning that into a real object is §3.
- *"Can I use `http` instead of Dio?"* — Yes, and it works fine. We use Dio
  because §2 leans on its interceptors, and because every Dio answer they
  find online will assume Dio. Either is a fine choice for today.

**Stuck-points:**

| Symptom | Cause | Fix |
|---|---|---|
| Hangs forever, no output | Android emulator without the `INTERNET` permission | `AndroidManifest.xml` — this is slide 12 tap 3, put it on screen |
| `SocketException` on macOS | Missing network entitlement | `macos/Runner/*.entitlements`, both debug and release |
| CORS error in Chrome | Browser blocking the cross-origin call | Run on a device or desktop for this exercise |
| Prints `Instance of 'Response'` | Printed `response`, not `response.data` | Point at it and move on |

---

## Slide 8 — `/future-states`

Four taps. Define the word before the next slide animates it.

> A `Future` is a receipt for a value you do not have yet. You get the receipt
> the instant you ask. It settles exactly once, later, exactly one way: a
> value, or an error.

Tap 3 is the one to dwell on — the error branch is *native* to the type, not an
edge case bolted onto it. Every `await` they write is choosing between two
branches whether they think about it or not.

Tap 4: **there is no `cancel()`.** You can stop caring about the answer; you
cannot stop the work. It runs to completion and, if it throws, that error still
has to land somewhere — an unhandled one on a dropped Future surfaces as an
uncaught async error, not silence.

Cancelling the *request* is the HTTP client's job, not the Future's:

```dart
final token = CancelToken();
dio.get('https://picsum.photos/v2/list', cancelToken: token);
token.cancel('user left the screen');   // Dio aborts the request
```

If someone asks about `Stream`: yes, those cancel — `subscription.cancel()`.
That difference is worth one sentence and no more.

---

## Slide 9 — `/async-await`

Five taps, and the one slide in this section worth rehearsing forward *and*
backward before you present it. It exists to break a wrong model, not to
introduce a keyword, so do not rush it.

**Tap 1 — the framing.** One isolate, one thread, one event loop, and a frame
every 16ms. Anything that sits on that thread without yielding stops
everything, spinner included.

**Tap 2 — waiting is free, and this is the surprise.** The request drops onto
the *second* lane, labelled "the socket — the OS, not your thread". The frame
strip keeps flowing and the spinner keeps turning. That is deliberate. Ask the
room why before you explain it.

> **Would the thread be blocked if we fetched photos without `async`/`await`?**
>
> No. And it is not blocked *with* them either.
>
> Dart has no blocking HTTP API. `dio.get(...)` returns a `Future`
> immediately; the socket work is the OS's, and the completion is posted back
> to the event loop. `await` and `.then()` are two spellings of the same
> mechanism — register a continuation, let the event loop call it. Neither is
> "more asynchronous" than the other, and neither moves anything to another
> thread, because there is no other thread to move it to.

**Tap 3 — so what is `await` actually for?** Being told. It is `.then()` with
the callback unwrapped: the next line runs when the answer lands, and
`try`/`catch` works, which it does not across a `.then()` boundary. That is the
whole pitch. It is a readability and error-handling feature, not a threading
one.

**Tap 4 — the honest exception.** A red block lands *on* the main lane:
`jsonDecode(20 MB)`. Now the ticks go red and the spinner dies. This is your
code, on your thread, never yielding — a tight loop, a huge decode, an image
decoded by hand, any `...Sync()` call.

> **`await` cannot help here.** There is nothing to await. The fix is
> `Isolate.run(() => jsonDecode(body))` — or `compute(...)`, which is the same
> thing with an older name.

**Tap 5 — the correlation, and its caveat.** Kotlin `suspend`, Swift
`async/await`, Go goroutines, Java `CompletableFuture`. Same shape, and then
the line that matters for anyone coming from Android:

> Kotlin can hand a `suspend` function to `Dispatchers.IO` and it really does
> land on another thread. A goroutine can land on another core. **Dart has
> neither.** `await` never moves work anywhere — `Isolate.run` does. If they
> take one thing from this slide, take that.

References worth pasting into chat if someone wants to go deeper:

- Concurrency in Dart — <https://dart.dev/language/concurrency>
- Futures, async, await — <https://dart.dev/libraries/async/async-await>
- Isolates — <https://dart.dev/language/isolates>
- Flutter performance best practices — <https://docs.flutter.dev/perf/best-practices>

**Rehearse the spinner.** If it freezes on tap 2, or keeps turning on tap 4,
the slide is teaching the opposite of what you are saying. Check it before you
go on stage.

---

## Slide 10 — `/loading-state`

Interactive, one tap, nothing on screen but the phone.

Hand the keyboard over and make someone click **error**. Then ask: *"what would
a user do here?"* Let the silence sit. The silence is the lesson — that is a
dead end with no way out, and it is what ships when nobody thinks about the
error branch.

No code on this slide on purpose. The three branches get written out on slide
12, and they land better once the room has watched the empty `catch` fail
first.

Note in passing that the data state is coming from a bundled fixture, not a
live request. Nothing on this slide depends on the venue's wifi.

---

## Slide 11 — `/error-swallowed`

Three taps.

Tap 1 is code that compiles, runs, ships, and passes review. No linter flags an
empty `catch`. Tap 2: let the clock actually climb from 5 to 30 while you keep
talking — do not rush it, the discomfort *is* the content. Tap 3 is the
punchline; say it plainly and then stop talking for a second.

---

## Slide 12 — `/three-states-code`

The answer to the slide they just watched fail. Three taps, one per branch.

Three fields, three branches, and each tap lights the field *and* the line in
`build` that reads it. Walk the highlight: loading, error, data. This is
exactly the code in **The whole thing** below — they can type it tonight with
nothing installed.

There is a better shape for this (a `sealed` result type, one `switch`, and a
compiler that will not let you forget a branch). It is deliberately not on this
slide: it is two unfamiliar ideas standing between the room and a screen that
handles its error state. If someone asks, say it exists and that §5 is where it
earns its place.

**Tap 3 — reaching the error branch for real.** Turn wifi off, or point the URL
at a host that does not exist. If an app *hangs* instead of erroring, it is
almost always one of two things — say it and move on:

- **Android:** no `INTERNET` permission in `AndroidManifest.xml`
- **macOS:** no `com.apple.security.network.client` entitlement, in **both**
  `DebugProfile.entitlements` and `Release.entitlements`

---

### The whole thing, with no state-management package

This is the shape they should be able to write by the end of the session. It
uses nothing but `StatefulWidget` and `setState` — no Provider, no Bloc, no
repository yet. Those arrive in §4 and §5, and they land better if the room has
first felt this version getting unwieldy.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({super.key});

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  // Exactly three things can be true, so model exactly three things.
  bool _loading = true;
  String? _error;
  List<dynamic> _photos = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await Dio().get('https://picsum.photos/v2/list');
      if (!mounted) return;                 // the screen may be gone by now
      setState(() {
        _photos = response.data as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load photos.';  // a person reads this, not a log
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            // The branch people forget: a way out.
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _photos.length,
      itemBuilder: (context, i) {
        final photo = _photos[i] as Map<String, dynamic>;
        return ListTile(
          title: Text(photo['author'] as String),
          subtitle: Text(photo['id'] as String),
        );
      },
    );
  }
}
```

**Four things to point at, in this order:**

1. **Three fields, three branches.** `build` reads like the states: loading,
   error, data. If a fourth state shows up later, it goes here too.
2. **`if (!mounted) return;`** — the widget can be disposed while the request
   is in flight, and `setState` after that throws. This is the bug they will
   actually hit tonight.
3. **The retry button.** An error state with no way out is the dead end from
   slide 10. Make them add it.
4. **`response.data as List<dynamic>`** — this cast is doing real work and
   will explode on a malformed response. That is the argument for §3's
   `fromJson` and §5's repository: the cast belongs behind a boundary, not in
   `build`.

**Where this gets uncomfortable — and that is deliberate.** Ask what happens
when the detail screen needs the same list. Right now the answer is "fetch it
again, and write all three branches again". Do not solve it. That is slide 18
(the hardcoded list goes away), §5 (repository), and §6 (Provider).

If someone has already reached for a sealed class or a `switch` over a state
object — good, and tell them so. That is where §5 goes. Do not make the rest of
the room follow them there tonight.
