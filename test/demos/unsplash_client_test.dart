import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/demos/unsplash_client.dart';

class _FailingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(o, s, f) async => throw DioException(
        requestOptions: RequestOptions(path: '/photos'),
        type: DioExceptionType.connectionError,
      );
}

/// Simulates a successful HTTP call whose body isn't the Unsplash photo
/// shape — a rate-limit message, a maintenance page, or similar served
/// with a 200. No DioException is thrown; the failure only shows up once
/// the body is parsed.
class _BadShapeAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(o, s, f) async => ResponseBody.fromString(
        '{"errors":["Rate Limit Exceeded"]}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

const _fixture = '''
[{"id":"a1","urls":{"regular":"https://x/a1.jpg"},
  "user":{"name":"Ansel"},"likes":42}]
''';

void main() {
  test('parses a photo from the Unsplash shape', () {
    final photo = Photo.fromJson({
      'id': 'a1',
      'urls': {'regular': 'https://x/a1.jpg'},
      'user': {'name': 'Ansel'},
      'likes': 42,
    });
    expect(photo.id, 'a1');
    expect(photo.imageUrl, 'https://x/a1.jpg');
    expect(photo.author, 'Ansel');
    expect(photo.likes, 42);
  });

  test('falls back to the fixture when the network fails', () async {
    final dio = Dio()..httpClientAdapter = _FailingAdapter();
    final client = UnsplashClient(
      dio: dio,
      loadAsset: (_) async => _fixture,
    );
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
    expect(result.photos.single.author, 'Ansel');
  });

  test('falls back to the fixture when no key is configured', () async {
    final client = UnsplashClient(
      accessKey: '',
      loadAsset: (_) async => _fixture,
    );
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
  });

  test(
      'falls back to the fixture when a 200 response has an unexpected '
      'shape', () async {
    final dio = Dio()..httpClientAdapter = _BadShapeAdapter();
    final client = UnsplashClient(
      accessKey: 'test-key',
      dio: dio,
      loadAsset: (_) async => _fixture,
    );
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
    expect(result.photos.single.author, 'Ansel');
  });

  test(
      'falls back to the in-code last-resort photos when the fixture '
      'itself cannot be loaded', () async {
    final client = UnsplashClient(
      accessKey: '',
      loadAsset: (_) async => throw Exception('asset bundle unavailable'),
    );
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
    expect(result.photos, isNotEmpty);
    expect(result.photos.first.author, 'Flutter Bootcamp');
  });

  test('loads the real bundled fixture via the default asset loader',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final client = UnsplashClient(accessKey: '');
    final result = await client.getPhotos();
    expect(result.fromFixture, isTrue);
    expect(result.photos, hasLength(12));
  });
}
