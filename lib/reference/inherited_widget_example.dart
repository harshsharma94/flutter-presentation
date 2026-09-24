// The complete InheritedWidget version of the photo app — slides 27 and 28,
// with nothing left out. It is one file on purpose: copy it whole.
//
// Run it on its own:
//   fvm flutter run -d chrome -t lib/reference/inherited_widget_example.dart
//
// No packages. Everything here is in the Flutter SDK.

import 'package:flutter/material.dart';

void main() => runApp(const InheritedWidgetExampleApp());

/// The model. Immutable: a like makes a *new* Photo rather than changing this
/// one. That is not style — see [PhotoScope.updateShouldNotify] for why the
/// scope depends on it.
class Photo {
  const Photo({required this.id, required this.author, required this.likes});

  final String id;
  final String author;
  final int likes;

  Photo liked() => Photo(id: id, author: author, likes: likes + 1);
}

// ─── 1. The scope ────────────────────────────────────────────────────────────

/// Puts the photos at the top of the tree, where any widget below can ask for
/// them. This is the whole of slide 27.
///
/// It is a widget, so it is immutable: `photos` is `final` and cannot change.
/// That is the limit slide 28 is about, and [PhotoScopeHost] below is the
/// workaround.
class PhotoScope extends InheritedWidget {
  const PhotoScope({
    required this.photos,
    required this.onLike,
    required super.child,
    super.key,
  });

  final List<Photo> photos;
  final void Function(String id) onLike;

  /// How every descendant finds the scope. Calling this also *subscribes* the
  /// caller: when the scope is rebuilt with different photos, every widget
  /// that called `of` rebuilds, and no other widget does.
  ///
  /// `Theme.of(context)` and `MediaQuery.of(context)` are this same method on
  /// Flutter's own InheritedWidgets.
  static PhotoScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PhotoScope>();
    assert(scope != null, 'No PhotoScope above this widget in the tree.');
    return scope!;
  }

  /// Flutter asks this every time the scope is rebuilt: "do the widgets that
  /// read me need to rebuild too?"
  ///
  /// It compares the list *references*. That is why [PhotoScopeHost] builds a
  /// new list on every like instead of changing the old one — change a list in
  /// place and this sees the same list, returns false, and the screen never
  /// updates. A classic first bug.
  @override
  bool updateShouldNotify(PhotoScope oldWidget) => photos != oldWidget.photos;
}

// ─── 2. The wrapper you are forced to write ──────────────────────────────────

/// The scope cannot change its own photos, so something *above* it has to
/// hold them and rebuild it with new ones. That something is a plain
/// StatefulWidget whose only job is to call setState.
///
/// Every scope needs one of these. That boilerplate is what ChangeNotifier
/// and Provider remove — compare `change_notifier_example.dart`.
class PhotoScopeHost extends StatefulWidget {
  const PhotoScopeHost({required this.child, super.key});

  final Widget child;

  @override
  State<PhotoScopeHost> createState() => _PhotoScopeHostState();
}

class _PhotoScopeHostState extends State<PhotoScopeHost> {
  List<Photo> _photos = const [
    Photo(id: '1', author: 'Alex', likes: 128),
    Photo(id: '2', author: 'Sam', likes: 64),
    Photo(id: '3', author: 'Riya', likes: 32),
  ];

  void _like(String id) {
    setState(() {
      // A new list, not an edit of the old one. See updateShouldNotify.
      _photos = [
        for (final photo in _photos) photo.id == id ? photo.liked() : photo,
      ];
    });
  }

  @override
  Widget build(BuildContext context) =>
      PhotoScope(photos: _photos, onLike: _like, child: widget.child);
}

// ─── 3. The app ──────────────────────────────────────────────────────────────

class InheritedWidgetExampleApp extends StatelessWidget {
  const InheritedWidgetExampleApp({super.key});

  // The host goes *above* MaterialApp, so every screen you navigate to is
  // still underneath it and can read the scope.
  @override
  Widget build(BuildContext context) =>
      const PhotoScopeHost(child: MaterialApp(home: PhotoListScreen()));
}

/// Notice what this screen does *not* take: no `photos` parameter, no
/// `onLike` callback. Nothing is passed down through the constructors in the
/// middle — that was the whole problem on slide 26.
class PhotoListScreen extends StatelessWidget {
  const PhotoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = PhotoScope.of(context).photos;

    return Scaffold(
      appBar: AppBar(title: const TotalLikes()),
      body: ListView(
        children: [for (final photo in photos) PhotoTile(photo: photo)],
      ),
    );
  }
}

class PhotoTile extends StatelessWidget {
  const PhotoTile({required this.photo, super.key});

  final Photo photo;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(photo.author),
    subtitle: Text('${photo.likes} likes'),
    trailing: LikeButton(photoId: photo.id),
  );
}

/// The leaf. It reaches straight up to the scope for the callback, four
/// levels above it, without any widget in between knowing.
class LikeButton extends StatelessWidget {
  const LikeButton({required this.photoId, super.key});

  final String photoId;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.favorite_border),
    tooltip: 'Like',
    onPressed: () => PhotoScope.of(context).onLike(photoId),
  );
}

/// A second reader somewhere else in the tree. It rebuilds on every like
/// because it called `PhotoScope.of` — it is subscribed.
class TotalLikes extends StatelessWidget {
  const TotalLikes({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = PhotoScope.of(context).photos;
    final total = photos.fold<int>(0, (sum, photo) => sum + photo.likes);
    return Text('$total likes in total');
  }
}
