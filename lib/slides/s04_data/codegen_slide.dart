import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _byHand = '''
factory Photo.fromJson(Map<String, dynamic> json) => Photo(
      id: json['id'] as String,
      imageUrl: json['urls']['regular'] as String,
      author: json['user']['name'] as String,
      likes: json['likes'] as int,
    );

Map<String, dynamic> toJson() => {
      'id': id,
      'urls': {'regular': imageUrl},
      'user': {'name': author},
      'likes': likes,
    };''';

/// The whole file, not an elision. They are expected to type this one, so
/// every line it needs is on it — the import, the `part`, the annotations and
/// the two one-line bodies that call into the generated file.
///
/// The two `readValue` helpers are the honest part. `@JsonSerializable` maps
/// a flat key to a field for free, but Unsplash nests the two fields that
/// matter — the image lives at `urls.regular` and the photographer at
/// `user.name` (see unsplash.com/documentation#get-a-photo). Codegen cannot
/// guess a path, so those two get a reader function each. Without them this
/// snippet compiles and then throws at runtime, which is a bad thing to hand
/// a room.
const _generated = '''
import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

@JsonSerializable()
class Photo {
  const Photo({
    required this.id,
    required this.imageUrl,
    required this.author,
    required this.likes,
  });

  final String id;

  @JsonKey(readValue: _regularUrl)
  final String imageUrl;

  @JsonKey(readValue: _userName)
  final String author;

  final int likes;

  factory Photo.fromJson(Map<String, dynamic> json) =>
      _\$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _\$PhotoToJson(this);
}''';

/// The rest of the same file. Split out only so the slide is wider than it is
/// tall — the caption says it is the same file, and it is.
const _readers = '''
// Unsplash nests these two, and codegen
// cannot guess a path — so point at it.

Object? _regularUrl(Map json, String key) =>
    (json['urls']
        as Map<String, dynamic>)['regular'];

Object? _userName(Map json, String key) =>
    (json['user']
        as Map<String, dynamic>)['name'];''';

/// Slide 19 — `/codegen` (3 steps, A17). Optional. Frame it as "you now know
/// exactly what this generates" — which is the only reason it was worth
/// writing by hand first.
///
/// Step 2 is the packages. It was missing: slide 6 tells them exactly how to
/// add Dio and this slide used to jump straight to `build_runner build`,
/// which fails on a project that has none of the three packages installed.
class CodegenBody extends StatelessWidget {
  const CodegenBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(Tokens.gapMd),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 940,
              child: CodePanel(
                code: step >= 1 ? _generated : _byHand,
                sizedFor: const [_byHand, _generated],
                fileName: 'lib/models/photo.dart',
              ),
            ),
            SizedBox(width: Tokens.gapMd),
            SizedBox(
              width: 660,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepReveal(
                    atStep: 1,
                    dimWhenPast: false,
                    child: CodePanel(
                      code: _readers,
                      fileName: '… same file, under the class',
                    ),
                  ),
                  SizedBox(height: Tokens.gapMd),
                  StepReveal(
                    atStep: 2,
                    dimWhenPast: false,
                    child: _AddPackagesPanel(),
                  ),
                  SizedBox(height: Tokens.gapMd),
                  StepReveal(atStep: 3, dimWhenPast: false, child: _Terminal()),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The three packages, stated the same way slide 6 states Dio — because the
/// room that stalls on "add the dependency" is the same room either time, and
/// two of these three are dev dependencies, which is the bit people get wrong.
class _AddPackagesPanel extends StatelessWidget {
  const _AddPackagesPanel();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      padding: EdgeInsets.all(Tokens.gapMd),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border.all(color: Palette.blue, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            r'$ flutter pub add json_annotation'
            '\n'
            r'$ flutter pub add dev:json_serializable dev:build_runner',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: Palette.green,
              fontSize: 19,
              height: 1.5,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'pubspec.yaml  →  dependencies:\n'
            '                  json_annotation: ^4.9.0\n'
            '                dev_dependencies:\n'
            '                  json_serializable: ^6.9.0\n'
            '                  build_runner: ^2.4.13',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: pal.textSecondary,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            'Two of the three are dev dependencies — they run on your '
            'machine, not on the phone, so they never ship.',
            style: TextStyle(color: pal.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _Terminal extends StatelessWidget {
  const _Terminal();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: pal.base,
        border: Border.all(color: pal.textSecondary, width: 1),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            r'$ dart run build_runner build'
            '\n'
            r'      --delete-conflicting-outputs',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              height: 1.4,
              color: Palette.green,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            '[INFO] Succeeded after 1.2s with 1 output (photo.g.dart)',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 19,
              color: pal.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
