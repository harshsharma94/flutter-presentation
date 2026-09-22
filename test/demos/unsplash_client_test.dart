import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gopay_flutter_deck/demos/unsplash_client.dart';

class _FailingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(o, s, f) async => throw DioException(
        requestOptions: RequestOptions(path: '/photos'),
        type: DioExceptionType.connectionError,
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
}
