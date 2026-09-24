import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/field_flight.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// Fixed canvas the JSON block, the constructor block and the four curved
/// field flights are laid out against, so every arrow's coordinates agree
/// with where the text actually renders.
const _canvasWidth = 1560.0;
const _canvasHeight = 280.0;

const _lineHeight = 26.0;
const _blockTop = 14.0;
const _jsonRight = 560.0;
const _dartLeft = 940.0;

/// The return trip gets its own lane under the block. Drawn at the
/// height of the second field, as it was, the green arrow bowed straight
/// through all four blue ones and read as a mistake rather than as a
/// second journey.
const _returnLaneY = 215.0;

/// Field `i` (0-based) sits on source line `i + 1` — line 0 is the opening
/// brace in both blocks.
double _rowY(int i) => _blockTop + (i + 1) * _lineHeight + _lineHeight / 2;

const _fields = [
  (key: 'id', accessor: "json['id']", param: 'id'),
  (key: 'urls.regular', accessor: "json['urls']['regular']", param: 'imageUrl'),
  (key: 'user.name', accessor: "json['user']['name']", param: 'author'),
  (key: 'likes', accessor: "json['likes']", param: 'likes'),
];

const _jsonLines = [
  (text: '{', consumedAt: null),
  (text: '"id": "a1x9",', consumedAt: 1),
  (text: '"urls": { "regular": "…" },', consumedAt: 2),
  (text: '"user": { "name": "Ansel" },', consumedAt: 3),
  (text: '"likes": 128', consumedAt: 4),
  (text: '}', consumedAt: null),
];

/// Slide 16 — `/json-to-dart` (6 steps, A14 + A15). Four keys lift out of the
/// raw response, fly a curved path, and land as named arguments on a real
/// constructor. Step 5 reverses one — that is `toJson`. Step 6 names the
/// thing they already use on their own platform, and why Dart can't.
class JsonToDartBody extends StatelessWidget {
  const JsonToDartBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Tokens.gapLg),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _canvasWidth,
                child: Text(
                  'One response. One constructor. Four wires.',
                  style: TextStyle(color: pal.textPrimary, fontSize: 29),
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Raw response, left.
                    Positioned(
                      left: 0,
                      top: _blockTop,
                      width: _jsonRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final line in _jsonLines)
                            SizedBox(
                              height: _lineHeight,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: JsonSourceLine(
                                  text: line.text,
                                  consumedAt: line.consumedAt,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Constructor shell, right. The arguments themselves
                    // are placed by each FieldFlight as it lands.
                    Positioned(
                      left: _dartLeft,
                      top: _blockTop,
                      child: const _ConstructorShell(),
                    ),
                    for (var i = 0; i < _fields.length; i++)
                      Positioned.fill(
                        child: FieldFlight(
                          jsonKey: _fields[i].key,
                          jsonValue: _fields[i].accessor,
                          dartParam: _fields[i].param,
                          atStep: i + 1,
                          from: Offset(_jsonRight, _rowY(i)),
                          to: Offset(_dartLeft + 16, _rowY(i)),
                        ),
                      ),
                    // Step 5: the same wire, backwards.
                    Positioned.fill(
                      child: StepReveal(
                        atStep: 5,
                        until: 5,
                        dimWhenPast: false,
                        child: AnimatedArrow(
                          from: Offset(_dartLeft, _returnLaneY),
                          to: Offset(_jsonRight + 8, _returnLaneY),
                          atStep: 5,
                          curved: true,
                          color: Palette.green,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _jsonRight + 20,
                      top: _returnLaneY + 22,
                      child: Callout(
                        atStep: 5,
                        text: 'toJson() — the same wires, backwards',
                        color: Palette.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              SizedBox(
                width: _canvasWidth,
                child: CorrelationPanel(
                  flutterLabel: 'fromJson (by hand)',
                  firstStep: 6,
                  stepsPerRow: 0,
                  rows: [
                    CorrelationRow(
                      platform: 'Android',
                      concept: 'Gson / Moshi / kotlinx',
                    ),
                    CorrelationRow(platform: 'iOS', concept: 'Codable'),
                    CorrelationRow(platform: 'Java/Spring', concept: 'Jackson'),
                    CorrelationRow(platform: 'Go', concept: 'encoding/json'),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              Callout(
                atStep: 6,
                text: "Dart has no runtime reflection. That's why you write this one.",
                color: Palette.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConstructorShell extends StatelessWidget {
  const _ConstructorShell();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ShellLine('Photo('),
      SizedBox(height: _lineHeight * 4),
      _ShellLine(');'),
    ],
  );
}

class _ShellLine extends StatelessWidget {
  const _ShellLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _lineHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 20,
          height: 1.0,
          color: Palette.blue,
        ),
      ),
    ),
  );
}
