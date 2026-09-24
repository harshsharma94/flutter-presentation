import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/reference/unsplash_photo_models.dart';

/// Unsplash's documented example for GET /photos, plus the fields its own SDK
/// says the real response carries that the example leaves out (`likes`,
/// `alt_description`). The second photo has every nullable field set to null,
/// which is the case a model gets wrong.
const _response = '''
[
  {
    "id": "LBI7cgq3pbM",
    "created_at": "2016-05-03T11:00:28-04:00",
    "updated_at": "2016-07-10T11:00:01-05:00",
    "width": 5245,
    "height": 3497,
    "color": "#60544D",
    "blur_hash": "LoC%a7IoIVxZ_NM|M{s:%hRjWAo0",
    "likes": 12,
    "description": "A man drinking a coffee.",
    "alt_description": "man holding a cup of coffee",
    "user": {
      "id": "pXhwzz1JtQU",
      "username": "poorkane",
      "name": "Gilbert Kane",
      "last_name": "Kane",
      "bio": "XO",
      "profile_image": {
        "small": "https://images.unsplash.com/face.jpg?w=32",
        "medium": "https://images.unsplash.com/face.jpg?w=64",
        "large": "https://images.unsplash.com/face.jpg?w=128"
      }
    },
    "urls": {
      "raw": "https://images.unsplash.com/photo.jpg",
      "full": "https://images.unsplash.com/photo.jpg?q=75",
      "regular": "https://images.unsplash.com/photo.jpg?w=1080",
      "small": "https://images.unsplash.com/photo.jpg?w=400",
      "thumb": "https://images.unsplash.com/photo.jpg?w=200"
    }
  },
  {
    "id": "second",
    "width": 3000,
    "height": 2000,
    "color": null,
    "likes": 0,
    "description": null,
    "alt_description": null,
    "user": {
      "username": "mononym",
      "name": "Mononym",
      "last_name": null,
      "profile_image": {"small": "s", "medium": "m", "large": "l"}
    },
    "urls": {"regular": "r", "small": "sm", "thumb": "t"}
  }
]''';

void main() {
  group('parsePhotos', () {
    test('reads the whole list, nested objects included', () {
      final photos = parsePhotos(jsonDecode(_response));

      expect(photos, hasLength(2));
      final first = photos.first;
      expect(first.id, 'LBI7cgq3pbM');
      expect(first.likes, 12);
      expect(first.width, 5245);
      expect(first.color, '#60544D');
      expect(first.altDescription, 'man holding a cup of coffee');
      expect(first.urls.regular, endsWith('w=1080'));
      expect(first.user.name, 'Gilbert Kane');
      expect(first.user.profileImage.medium, endsWith('w=64'));
    });

    test('accepts null where the API allows null', () {
      final second = parsePhotos(jsonDecode(_response))[1];

      expect(second.color, isNull);
      expect(second.altDescription, isNull);
      expect(second.user.name, 'Mononym');
    });

    test('maps onto the Day 1 Photo the screens already use', () {
      final photo = parsePhotos(jsonDecode(_response)).first.toPhoto();

      expect(photo.id, 'LBI7cgq3pbM');
      expect(photo.imageUrl, endsWith('w=1080'));
      expect(photo.author, 'Gilbert Kane');
      expect(photo.likes, 12);
    });

    test('an error body fails with a message that says why', () {
      // Unsplash error responses are an object, not an array.
      final errorBody = jsonDecode(
        '{"errors": ["OAuth error: invalid token"]}',
      );

      expect(
        () => parsePhotos(errorBody),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('JSON array'),
          ),
        ),
      );
    });
  });
}
