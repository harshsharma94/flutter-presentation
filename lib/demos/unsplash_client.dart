import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'photo.dart';

export 'photo.dart' show Photo;

/// Result of a [UnsplashClient.getPhotos] call.
///
/// [fromFixture] records whether [photos] came from the live Unsplash API or
/// the bundled offline fixture, so callers (slide 11) can show an honest
/// "offline fixture" chip instead of pretending every photo is live.
class PhotoResult {
  const PhotoResult({required this.photos, required this.fromFixture});

  final List<Photo> photos;
  final bool fromFixture;
}

/// Fetches photos from the Unsplash API, falling back to a bundled offline
/// fixture whenever no access key is configured or the request fails.
///
/// This runs live, in front of an audience: a forgotten
/// `--dart-define=UNSPLASH_ACCESS_KEY=...` or a flaky venue wifi must render
/// real-looking photos, not an error. [getPhotos] therefore never throws.
class UnsplashClient {
  UnsplashClient({
    this.accessKey = const String.fromEnvironment('UNSPLASH_ACCESS_KEY'),
    Dio? dio,
    Future<String> Function(String)? loadAsset,
  })  : _dio = dio ?? Dio(),
        _loadAsset = loadAsset ?? rootBundle.loadString;

  static const _fixtureAssetPath = 'assets/fixtures/unsplash_photos.json';
  static const _endpoint = 'https://api.unsplash.com/photos?per_page=12';

  final String accessKey;
  final Dio _dio;
  final Future<String> Function(String) _loadAsset;

  /// Returns 12 photos from the live Unsplash API.
  ///
  /// Falls back to the bundled fixture — without ever throwing — when
  /// [accessKey] is empty or the request raises any [DioException].
  Future<PhotoResult> getPhotos() async {
    if (accessKey.isEmpty) {
      return _fromFixture();
    }

    try {
      final response = await _dio.get<dynamic>(
        _endpoint,
        options: Options(
          headers: {'Authorization': 'Client-ID $accessKey'},
        ),
      );
      return PhotoResult(
        photos: _parsePhotos(response.data),
        fromFixture: false,
      );
    } on DioException {
      return _fromFixture();
    }
  }

  Future<PhotoResult> _fromFixture() async {
    final raw = await _loadAsset(_fixtureAssetPath);
    return PhotoResult(photos: _parsePhotos(raw), fromFixture: true);
  }

  List<Photo> _parsePhotos(Object? data) {
    final decoded = data is String ? jsonDecode(data) : data;
    return (decoded as List<dynamic>)
        .map((item) => Photo.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
