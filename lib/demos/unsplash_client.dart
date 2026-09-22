import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'photo.dart';

export 'photo.dart' show Photo;

/// Result of a [UnsplashClient.getPhotos] call.
///
/// [fromFixture] records whether [photos] came from the live Unsplash API or
/// the bundled offline fixture, so callers (slide 10) can show an honest
/// "offline fixture" chip instead of pretending every photo is live.
class PhotoResult {
  const PhotoResult({required this.photos, required this.fromFixture});

  final List<Photo> photos;
  final bool fromFixture;
}

/// Fetches photos from the Unsplash API, falling back to a bundled offline
/// fixture whenever no access key is configured, the request fails, or the
/// response can't be parsed into [Photo]s.
///
/// This runs live, in front of an audience: a forgotten
/// `--dart-define=UNSPLASH_ACCESS_KEY=...`, a flaky venue wifi, or a 200
/// response whose body isn't the shape we expect (a rate-limit or
/// maintenance message, a captive-portal page from a proxy, a changed
/// field) must all render real-looking photos, not an error. [getPhotos]
/// therefore never throws — even the fixture fallback has its own guard,
/// dropping to a small in-code [_lastResortPhotos] constant if the bundled
/// fixture itself can't be loaded or parsed.
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
  /// [accessKey] is empty, the request raises a [DioException], or the
  /// response body can't be parsed into [Photo]s (wrong shape, rate-limit
  /// or maintenance body served with a 200, a captive-portal page, etc.).
  /// The fallback wraps the whole fetch-and-parse sequence on purpose: a
  /// response we cannot parse is a failed request in every sense this
  /// audience cares about.
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
    } catch (_) {
      return _fromFixture();
    }
  }

  /// Loads the bundled fixture, with its own guard: this is the fallback
  /// itself, so it must not be able to throw. If the asset is missing, the
  /// loader fails, or the bundled JSON doesn't parse, this drops one more
  /// rung to [_lastResortPhotos] — an in-code constant with no file I/O and
  /// no decoding, so there is nothing left in that path that can fail.
  Future<PhotoResult> _fromFixture() async {
    try {
      final raw = await _loadAsset(_fixtureAssetPath);
      return PhotoResult(photos: _parsePhotos(raw), fromFixture: true);
    } catch (_) {
      return const PhotoResult(
        photos: _lastResortPhotos,
        fromFixture: true,
      );
    }
  }

  List<Photo> _parsePhotos(Object? data) {
    final decoded = data is String ? jsonDecode(data) : data;
    return (decoded as List<dynamic>)
        .map((item) => Photo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// The floor beneath the fixture: hardcoded [Photo]s used only when even
  /// the bundled fixture can't be loaded or parsed. Deliberately small —
  /// it only has to make the slide render something rather than crash.
  static const _lastResortPhotos = <Photo>[
    Photo(
      id: 'last-resort-1',
      imageUrl: 'https://picsum.photos/seed/deck-last-resort-1/800/600',
      author: 'Flutter Bootcamp',
      likes: 1,
    ),
    Photo(
      id: 'last-resort-2',
      imageUrl: 'https://picsum.photos/seed/deck-last-resort-2/800/600',
      author: 'Flutter Bootcamp',
      likes: 1,
    ),
    Photo(
      id: 'last-resort-3',
      imageUrl: 'https://picsum.photos/seed/deck-last-resort-3/800/600',
      author: 'Flutter Bootcamp',
      likes: 1,
    ),
  ];
}
