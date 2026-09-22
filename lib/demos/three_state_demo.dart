import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/unsplash_client.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';

enum _DemoState { loading, error, data }

const _phoneWidth = 200.0;
const _codeWidth = 470.0;

/// The `sealed` declaration is carried here rather than on a slide of its
/// own: an earlier `/three-states-code` slide reprinted this same `switch`
/// one beat later, which taught nothing the live demo had not already shown.
const _demoCode = '''
sealed class ApiResult {}

switch (result) {
  case Loading():
    return Spinner();
  case ApiError(:final message):
    return ErrorView(message);
  case Data(:final photos):
    return PhotoGrid(photos);
}''';

/// 0-indexed line numbers, one branch per [_DemoState] — see
/// `FlutterDeckCodeHighlight.highlightedLines`.
const _loadingLines = [3, 4];
const _errorLines = [5, 6];
const _dataLines = [7, 8];

/// Slide 10's live centerpiece (A8) — genuinely interactive, unlike every
/// other slide in the deck. A real [PhoneFrame] plus three [FilledButton]s
/// drive a real [AnimatedSwitcher] between the three states a `Future<T>`
/// can render as, with a [CodePanel] beside it whose `highlightedLines`
/// track whichever branch is on screen. This is deliberately **not**
/// step-driven — the presenter hands the keyboard to a bootcamper, so the
/// state has to be genuine `State`, not a function of the ambient step.
///
/// The `data` state calls the real [UnsplashClient], which never throws (it
/// falls back to a bundled fixture), so this is safe to run live without
/// risking a dead request in front of an audience.
class ThreeStateDemo extends StatefulWidget {
  const ThreeStateDemo({super.key});

  @override
  State<ThreeStateDemo> createState() => _ThreeStateDemoState();
}

class _ThreeStateDemoState extends State<ThreeStateDemo> {
  final _client = UnsplashClient();

  _DemoState _state = _DemoState.loading;
  Photo? _photo;
  bool _fromFixture = false;

  List<int> get _highlightedLines => switch (_state) {
    _DemoState.loading => _loadingLines,
    _DemoState.error => _errorLines,
    _DemoState.data => _dataLines,
  };

  void _selectLoading() => setState(() => _state = _DemoState.loading);

  void _selectError() => setState(() => _state = _DemoState.error);

  Future<void> _selectData() async {
    // Reuses the loading visual while the (fast, never-throwing) fetch is in
    // flight — this is genuinely what a `FutureBuilder`'s loading state
    // looks like too.
    setState(() => _state = _DemoState.loading);
    final result = await _client.getPhotos();
    if (!mounted) return;
    setState(() {
      _photo = result.photos.isNotEmpty ? result.photos.first : null;
      _fromFixture = result.fromFixture;
      _state = _DemoState.data;
    });
  }

  Widget _content() {
    switch (_state) {
      case _DemoState.loading:
        return const _LoadingView(key: ValueKey('state-loading'));
      case _DemoState.error:
        return const _ErrorView(key: ValueKey('state-error'));
      case _DemoState.data:
        return _DataView(
          key: ValueKey('state-data'),
          photo: _photo,
          fromFixture: _fromFixture,
        );
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhoneFrame(
            width: _phoneWidth,
            child: AnimatedSwitcher(duration: Tokens.fade, child: _content()),
          ),
          SizedBox(height: Tokens.gapMd),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(onPressed: _selectLoading, child: Text('loading')),
              SizedBox(width: Tokens.gapSm),
              FilledButton(onPressed: _selectError, child: Text('error')),
              SizedBox(width: Tokens.gapSm),
              FilledButton(onPressed: _selectData, child: Text('data')),
            ],
          ),
        ],
      ),
      SizedBox(width: Tokens.gapLg),
      SizedBox(
        width: _codeWidth,
        child: CodePanel(
          code: _demoCode,
          fileName: 'photo_view.dart',
          highlightedLines: _highlightedLines,
        ),
      ),
    ],
  );
}

/// The loading state's spinner. Never [CircularProgressIndicator] — an
/// indeterminate animation never settles, which hangs `pumpAndSettle` and
/// kills the smoke test outright. Instead the target angle is a large but
/// finite number of turns, reached over a few real seconds — enough to read
/// as genuinely spinning while the presenter talks, while remaining an
/// animation the framework knows has an end. Because [AnimatedSwitcher]
/// fully unmounts the outgoing state and mounts a fresh one, re-selecting
/// `loading` after `error` or `data` restarts this from zero rather than
/// resuming a stale animation.
class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  static const _spinDuration = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: math.pi * 2 * 6),
        duration: _spinDuration,
        curve: Tokens.curve,
        builder: (context, angle, child) =>
            Transform.rotate(angle: angle, child: child),
        child: Icon(Icons.autorenew, size: 32, color: pal.textSecondary),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Palette.red, size: 32),
        SizedBox(height: Tokens.gapSm),
        Text(
          'Something went wrong.',
          style: TextStyle(color: Palette.red, fontSize: 17),
        ),
      ],
    ),
  );
}

class _DataView extends StatelessWidget {
  const _DataView({required this.photo, required this.fromFixture, super.key});

  final Photo? photo;
  final bool fromFixture;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final photo = this.photo;
    if (photo == null) {
      return Center(
        child: Text('No photos.', style: TextStyle(color: pal.textSecondary)),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: pal.surface),
        Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                photo.author,
                style: TextStyle(color: pal.textPrimary, fontSize: 20),
              ),
              Text(
                '${photo.likes} ♥',
                style: TextStyle(color: pal.textSecondary, fontSize: 16),
              ),
              if (fromFixture) ...[
                SizedBox(height: 4),
                Text(
                  '(offline fixture)',
                  style: TextStyle(color: pal.textSecondary, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
