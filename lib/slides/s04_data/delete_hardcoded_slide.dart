import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/demos/unsplash_client.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/phone_frame.dart';

const _hardcoded = '''
final photos = const [
  Photo(id: '1', imageUrl: 'assets/a.jpg', author: 'Ansel',  likes: 12),
  Photo(id: '2', imageUrl: 'assets/b.jpg', author: 'Vivian', likes: 48),
  Photo(id: '3', imageUrl: 'assets/c.jpg', author: 'Saul',   likes: 7),
  Photo(id: '4', imageUrl: 'assets/d.jpg', author: 'Fan',    likes: 91),
  Photo(id: '5', imageUrl: 'assets/e.jpg', author: 'Daido',  likes: 33),
  Photo(id: '6', imageUrl: 'assets/f.jpg', author: 'Rinko',  likes: 64),
];''';

const _live = '''
final photos = await repo.getPhotos();''';

/// Slide 22 — `/delete-hardcoded` (3 steps, A16). The emotional peak of
/// session 1: the Day-1 list they each typed by hand collapses into one
/// line, and both screens fill from it.
///
/// The [CodePanel] is deliberately given no `key` and is never swapped for a
/// different widget — only its `code` changes between steps 1 and 2. That is
/// what lets `animateCodeUpdate` morph the exact changed characters instead
/// of cutting.
class DeleteHardcodedBody extends StatelessWidget {
  const DeleteHardcodedBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 640,
                      child: CodePanel(
                        code: step >= 2 ? _live : _hardcoded,
                        fileName: 'lib/screens/home_screen.dart',
                      ),
                    ),
                    const SizedBox(width: Tokens.gapLg),
                    _PhotoPhone(filled: step >= 3, offset: 0),
                    const SizedBox(width: Tokens.gapMd),
                    _PhotoPhone(filled: step >= 3, offset: 2),
                  ],
                ),
                const SizedBox(height: Tokens.gapMd),
                const Callout(
                  atStep: 3,
                  text: 'One list. Two screens. Done.',
                  color: Palette.green,
                ),
              ],
            ),
          ),
        ),
      );
}

/// A phone that holds grey placeholder tiles until [filled], then shows real
/// photos. [offset] rotates which photos this phone starts from, so the two
/// frames don't look like a duplicated screenshot.
class _PhotoPhone extends StatelessWidget {
  const _PhotoPhone({required this.filled, required this.offset});

  final bool filled;
  final int offset;

  @override
  Widget build(BuildContext context) => PhoneFrame(
        width: 180,
        child: ColoredBox(
          color: Palette.surface,
          child: filled
              ? _LivePhotoGrid(offset: offset)
              : const _PlaceholderGrid(),
        ),
      );
}

class _PlaceholderGrid extends StatelessWidget {
  const _PlaceholderGrid();

  @override
  Widget build(BuildContext context) => const _Grid(
        children: [
          _Tile(color: Palette.base),
          _Tile(color: Palette.base),
          _Tile(color: Palette.base),
          _Tile(color: Palette.base),
          _Tile(color: Palette.base),
          _Tile(color: Palette.base),
        ],
      );
}

/// Pulls from the same fixture-backed client as slides 8 and 11, so this
/// never depends on the venue's wifi.
class _LivePhotoGrid extends StatefulWidget {
  const _LivePhotoGrid({required this.offset});

  final int offset;

  @override
  State<_LivePhotoGrid> createState() => _LivePhotoGridState();
}

class _LivePhotoGridState extends State<_LivePhotoGrid> {
  late final Future<PhotoResult> _future = UnsplashClient().getPhotos();

  @override
  Widget build(BuildContext context) => FutureBuilder<PhotoResult>(
        future: _future,
        builder: (context, snapshot) {
          final photos = snapshot.data?.photos ?? const <Photo>[];
          if (photos.isEmpty) return const _PlaceholderGrid();
          return _Grid(
            children: [
              for (var i = 0; i < 6; i++)
                _Tile(
                  color: Palette.base,
                  imageUrl: photos[(i + widget.offset) % photos.length].imageUrl,
                ),
            ],
          );
        },
      );
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Tokens.gapXs),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: Tokens.gapXs,
          crossAxisSpacing: Tokens.gapXs,
          children: children,
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.color, this.imageUrl});

  final Color color;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: color);
    return AnimatedContainer(
      duration: Tokens.travel,
      curve: Tokens.curve,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Tokens.gapXs),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? placeholder
          // errorBuilder is required, not cosmetic: without it a failed image
          // load throws, which would fail the smoke test in an environment
          // with no network.
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : placeholder,
            ),
    );
  }
}
