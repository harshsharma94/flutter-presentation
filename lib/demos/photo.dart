/// The model the bootcampers already have from Day 1, now fed by the API.
class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    required this.author,
    required this.likes,
  });

  /// Hand-written on purpose — writing this mapping is the lesson (spec §4).
  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as String,
        imageUrl: (json['urls'] as Map<String, dynamic>)['regular'] as String,
        author: (json['user'] as Map<String, dynamic>)['name'] as String,
        likes: json['likes'] as int,
      );

  final String id;
  final String imageUrl;
  final String author;
  final int likes;
}
