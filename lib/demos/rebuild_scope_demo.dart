import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/notifier_demo.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/rebuild_flash.dart';

/// Which reader the demo is currently wired with. The three are not styles —
/// they are three different answers to "how much of my tree rebuilds?".
enum ReadMode { watch, read, consumer }

/// Slide 36's live demo. The same widget tree, rendered as real widgets
/// under a real [CounterModel], rebuilt through whichever reader is
/// selected. Nothing here is staged: the flashes come from
/// [RebuildFlash.build], the readout from [RebuildTally].
class RebuildScopeDemo extends StatefulWidget {
  const RebuildScopeDemo({super.key});

  @override
  State<RebuildScopeDemo> createState() => _RebuildScopeDemoState();
}

class _RebuildScopeDemoState extends State<RebuildScopeDemo> {
  final _model = CounterModel();
  final _tally = RebuildTally();
  var _mode = ReadMode.watch;

  @override
  void dispose() {
    _model.dispose();
    _tally.dispose();
    super.dispose();
  }

  void _setMode(ReadMode mode) {
    setState(() {
      _mode = mode;
      _tally.reset();
    });
  }

  @override
  Widget build(BuildContext context) => RebuildTallyScope(
        tally: _tally,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<ReadMode>(
                  segments: const [
                    ButtonSegment(
                      value: ReadMode.watch,
                      label: Text('context.watch (root)'),
                    ),
                    ButtonSegment(
                      value: ReadMode.read,
                      label: Text('context.read'),
                    ),
                    ButtonSegment(
                      value: ReadMode.consumer,
                      label: Text('Consumer (leaf)'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => _setMode(s.first),
                ),
                const SizedBox(width: Tokens.gapMd),
                FilledButton.icon(
                  key: const ValueKey('rebuild-increment'),
                  onPressed: _model.increment,
                  icon: const Icon(Icons.favorite),
                  label: const Text('like'),
                ),
                const SizedBox(width: Tokens.gapMd),
                // The model's own value, read live and rendered *outside*
                // the tree. Without this, `read` mode looks broken rather
                // than instructive: the tap genuinely changes the model,
                // and the lesson is that the tree below did not hear about
                // it. You cannot see that unless you can see both numbers.
                ListenableBuilder(
                  listenable: _model,
                  builder: (context, _) => Text(
                    'model.likes = ${_model.likes}',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: Palette.green,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tokens.gapMd),
            // `watch` at the root means the whole subtree is inside the
            // listening builder. `read` and `consumer` leave the subtree
            // outside it — which is the entire difference.
            if (_mode == ReadMode.watch)
              ListenableBuilder(
                listenable: _model,
                builder: (context, _) => _Tree(likes: _model.likes, liveLeafOnly: false),
              )
            else if (_mode == ReadMode.read)
              _Tree(likes: _model.likes, liveLeafOnly: false)
            else
              _Tree(likes: _model.likes, liveLeafOnly: true, model: _model),
            const SizedBox(height: Tokens.gapMd),
            ListenableBuilder(
              listenable: _tally,
              builder: (context, _) => Text(
                'widget builds since you switched: ${_tally.total}',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: Palette.textPrimary,
                  fontSize: 20,
                ),
              ),
            ),
            if (_mode == ReadMode.read)
              Padding(
                padding: const EdgeInsets.only(top: Tokens.gapXs),
                child: ListenableBuilder(
                  listenable: _model,
                  builder: (context, _) => Text(
                    'read() never subscribes. The model says '
                    '${_model.likes}; the tree still says 0, nothing '
                    'rebuilt, and no flash fired.',
                    style: const TextStyle(color: Palette.amber, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// The demo tree as real widgets. [liveLeafOnly] puts the listening builder
/// around one leaf instead of the whole tree — the `Consumer` case.
class _Tree extends StatelessWidget {
  const _Tree({
    required this.likes,
    required this.liveLeafOnly,
    this.model,
  });

  final int likes;
  final bool liveLeafOnly;
  final CounterModel? model;

  @override
  Widget build(BuildContext context) => RebuildFlash(
        id: 'photo-app',
        child: _Node(
          label: 'PhotoApp',
          child: RebuildFlash(
            id: 'home-screen',
            child: _Node(
              label: 'HomeScreen',
              child: RebuildFlash(
                id: 'photo-grid',
                child: _Node(
                  label: 'PhotoGrid',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _tile('tile-1', 'like-1'),
                      const SizedBox(width: Tokens.gapSm),
                      _tile('tile-2', 'like-2'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _tile(String tileId, String leafId) => RebuildFlash(
        id: tileId,
        child: _Node(
          label: 'PhotoTile',
          child: liveLeafOnly && leafId == 'like-1' && model != null
              ? ListenableBuilder(
                  listenable: model!,
                  builder: (context, _) => RebuildFlash(
                    id: leafId,
                    child: _Leaf(likes: model!.likes),
                  ),
                )
              : RebuildFlash(id: leafId, child: _Leaf(likes: likes)),
        ),
      );
}

class _Node extends StatelessWidget {
  const _Node({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Tokens.gapXs),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.textSecondary, width: 1),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Palette.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            child,
          ],
        ),
      );
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.likes});

  final int likes;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Tokens.gapSm, vertical: 6),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.blue, width: 1),
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Text(
          'LikeButton  $likes',
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            color: Palette.blue,
            fontSize: 13,
          ),
        ),
      );
}
