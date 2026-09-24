// The models for parsing Unsplash's GET /photos: one Dart class per JSON
// object in the response, and only the fields the app actually uses.
//
// Shape and nullability are taken from Unsplash's own SDK types (unsplash-js,
// Photo.Basic and User.Basic), not just the docs page. The docs' example for
// this endpoint leaves out `likes`, but the real response always has it — so
// the docs alone would have given you a wrong model.
//
// Usage with Dio, which has already decoded the JSON for you:
//
//   final response = await dio.get('https://api.unsplash.com/photos');
//   final photos = parsePhotos(response.data).map((p) => p.toPhoto()).toList();

/// GET /photos returns a JSON *array* at the top level, not an object.
///
/// Checked up front so a surprising body fails with a message that says what
/// went wrong. Unsplash's error bodies, for example, are an object —
/// `{"errors": ["..."]}` — and casting one to a List deep inside a widget gives
/// you a type error that says nothing about why.
List<UnsplashPhoto> parsePhotos(Object? body) {
  if (body is! List) {
    throw FormatException(
      'GET /photos should return a JSON array, got ${body.runtimeType}',
    );
  }
  return [
    for (final item in body)
      UnsplashPhoto.fromJson(item as Map<String, dynamic>),
  ];
}

/// One photo. Every field here earns its place in the UI; the response has
/// about twenty more, and none of them belong in a model until a screen needs
/// them.
class UnsplashPhoto {
  const UnsplashPhoto({
    required this.id,
    required this.width,
    required this.height,
    required this.likes,
    required this.urls,
    required this.user,
    this.altDescription,
    this.color,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) => UnsplashPhoto(
    id: json['id'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    likes: json['likes'] as int,
    // Nullable in the API, so nullable here. `as String` on a null value
    // throws; `as String?` accepts it.
    altDescription: json['alt_description'] as String?,
    color: json['color'] as String?,
    // A nested JSON object gets its own class and its own fromJson.
    urls: PhotoUrls.fromJson(json['urls'] as Map<String, dynamic>),
    user: UnsplashUser.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String id;

  /// Width and height let a grid reserve the right space before the image
  /// arrives, so the list does not jump as photos load.
  final int width;
  final int height;

  final int likes;

  /// For screen readers: `Image.network(..., semanticLabel: altDescription)`.
  final String? altDescription;

  /// A hex colour like "#60544D" — the photo's average colour, ideal as the
  /// placeholder behind the image while it downloads.
  final String? color;

  final PhotoUrls urls;
  final UnsplashUser user;

  /// Maps the API's shape onto the Photo the app already has from Day 1. The
  /// screens never see UnsplashPhoto — if Unsplash changes its response, this
  /// one method is what changes, not every widget.
  Photo toPhoto() =>
      Photo(id: id, imageUrl: urls.regular, author: user.name, likes: likes);
}

/// The same image at different sizes. `raw` and `full` are left out on
/// purpose: they are the original file, often many megabytes, and a phone
/// list never needs them.
class PhotoUrls {
  const PhotoUrls({
    required this.regular,
    required this.small,
    required this.thumb,
  });

  factory PhotoUrls.fromJson(Map<String, dynamic> json) => PhotoUrls(
    regular: json['regular'] as String,
    small: json['small'] as String,
    thumb: json['thumb'] as String,
  );

  /// 1080px wide — the detail screen.
  final String regular;

  /// 400px wide — a list or grid tile.
  final String small;

  /// 200px wide — anything smaller.
  final String thumb;
}

/// The photographer.
class UnsplashUser {
  const UnsplashUser({
    required this.username,
    required this.name,
    required this.profileImage,
  });

  factory UnsplashUser.fromJson(Map<String, dynamic> json) => UnsplashUser(
    username: json['username'] as String,
    // `name` is always present. `last_name` is not — plenty of photographers
    // use one name — which is why this reads `name` rather than gluing
    // first_name and last_name together.
    name: json['name'] as String,
    profileImage: ProfileImage.fromJson(
      json['profile_image'] as Map<String, dynamic>,
    ),
  );

  final String username;
  final String name;
  final ProfileImage profileImage;
}

/// Three levels deep: response -> user -> profile_image. Same rule every
/// level down — one JSON object, one class.
class ProfileImage {
  const ProfileImage({
    required this.small,
    required this.medium,
    required this.large,
  });

  factory ProfileImage.fromJson(Map<String, dynamic> json) => ProfileImage(
    small: json['small'] as String,
    medium: json['medium'] as String,
    large: json['large'] as String,
  );

  final String small;
  final String medium;
  final String large;
}

/// The Day 1 model the screens already use. It is here only so this file
/// stands on its own; in your app, `toPhoto` returns your existing Photo.
class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    required this.author,
    required this.likes,
  });

  final String id;
  final String imageUrl;
  final String author;
  final int likes;
}
