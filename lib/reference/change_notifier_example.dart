// The complete ChangeNotifier + Provider version of the photo app — slides 29
// to 31, with nothing left out. It is one file on purpose: copy it whole, and
// put it next to `inherited_widget_example.dart` to see what disappeared.
//
// Run it on its own:
//   fvm flutter run -d chrome -t lib/reference/change_notifier_example.dart
//
// Needs one package:
//   flutter pub add provider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  // Provider puts the model at the top of the tree — the same job PhotoScope
  // did, without the StatefulWidget wrapper around it.
  //
  // `create` means Provider built the model, so Provider also disposes it
  // when this widget goes away. You do not call dispose() yourself here.
  ChangeNotifierProvider(
    create: (_) => PhotoModel(),
    child: const ChangeNotifierExampleApp(),
  ),
);

/// The same immutable model as the InheritedWidget version.
class Photo {
  const Photo({required this.id, required this.author, required this.likes});

  final String id;
  final String author;
  final int likes;

  Photo liked() => Photo(id: id, author: author, likes: likes + 1);
}

// ─── 1. The notifier ─────────────────────────────────────────────────────────

/// One object that holds the photos, and a list of everyone who wants to know
/// when they change. That list is all a ChangeNotifier is (slide 29).
///
/// The photos are private. Nothing outside can change them except by calling
/// [like], so there is exactly one place that calls [notifyListeners] — which
/// is what makes the app easy to reason about when it grows.
class PhotoModel extends ChangeNotifier {
  List<Photo> _photos = const [
    Photo(id: '1', author: 'Alex', likes: 128),
    Photo(id: '2', author: 'Sam', likes: 64),
    Photo(id: '3', author: 'Riya', likes: 32),
  ];

  List<Photo> get photos => _photos;

  int get totalLikes => _photos.fold<int>(0, (sum, photo) => sum + photo.likes);

  void like(String id) {
    _photos = [
      for (final photo in _photos) photo.id == id ? photo.liked() : photo,
    ];
    // Walks the list and rebuilds everyone who is listening. Forget this line
    // and the data changes but the screen does not.
    notifyListeners();
  }
}

// ─── 2. The app ──────────────────────────────────────────────────────────────

class ChangeNotifierExampleApp extends StatelessWidget {
  const ChangeNotifierExampleApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: PhotoListScreen());
}

/// The three ways to read the model from slide 31, each where it belongs.
class PhotoListScreen extends StatelessWidget {
  const PhotoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch — subscribes THIS widget. Every like rebuilds this whole
    // screen, which is fine here because the list really did change.
    final photos = context.watch<PhotoModel>().photos;

    return Scaffold(
      appBar: AppBar(
        // Consumer — subscribes only what is inside `builder`. Just this Text
        // rebuilds, not the AppBar around it.
        title: Consumer<PhotoModel>(
          builder: (context, model, _) =>
              Text('${model.totalLikes} likes in total'),
        ),
      ),
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

class LikeButton extends StatelessWidget {
  const LikeButton({required this.photoId, super.key});

  final String photoId;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.favorite_border),
    tooltip: 'Like',
    // context.read — does NOT subscribe. Right for calling a method. Wrong for
    // showing a value: a number read this way would never redraw.
    onPressed: () => context.read<PhotoModel>().like(photoId),
  );
}
