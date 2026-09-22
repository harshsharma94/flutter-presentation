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

const _generated = '''
part 'photo.g.dart';

@JsonSerializable()
class Photo { ... }''';

/// Slide 20 — `/codegen` (2 steps, A17). Optional. Frame it as "you now know
/// exactly what this generates" — which is the only reason it was worth
/// writing by hand first.
class CodegenBody extends StatelessWidget {
  const CodegenBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(Tokens.gapLg),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 720,
              child: CodePanel(
                code: step >= 1 ? _generated : _byHand,
                fileName: 'lib/models/photo.dart',
              ),
            ),
            SizedBox(height: Tokens.gapMd),
            StepReveal(atStep: 2, dimWhenPast: false, child: _Terminal()),
          ],
        ),
      ),
    ),
  );
}

class _Terminal extends StatelessWidget {
  const _Terminal();

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Container(
      width: 720,
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: pal.base,
        border: Border.all(color: pal.textSecondary, width: 1),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r'$ dart run build_runner build',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              color: Palette.green,
            ),
          ),
          SizedBox(height: Tokens.gapXs),
          Text(
            '[INFO] Succeeded after 1.2s with 1 output (photo.g.dart)',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 17,
              color: pal.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
