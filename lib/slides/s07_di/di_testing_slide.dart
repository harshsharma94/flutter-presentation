import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';

const _real = '''
MultiProvider(
  providers: [
    Provider(create: (_) => Dio()),
    Provider(create: (c) => PhotoRepository(c.read<Dio>())),
    ChangeNotifierProvider(create: (_) => CounterModel()),
  ],
  child: const PhotoApp(),
)''';

const _fake = '''
MultiProvider(
  providers: [
    Provider(create: (_) => Dio()),
    Provider<PhotoRepository>(create: (_) => FakePhotoRepository()),
    ChangeNotifierProvider(create: (_) => CounterModel()),
  ],
  child: const PhotoApp(),
)''';

/// Slide 35 — `/di-testing` (2 steps, A32). Slide 27's idea, now at the
/// wiring level: one line, and the entire tree below is under test.
class DiTestingBody extends StatelessWidget {
  const DiTestingBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Tokens.gapLg),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 820,
              child: CodePanel(
                code: step >= 2 ? _fake : _real,
                sizedFor: const [_real, _fake],
                fileName: step >= 2 ? 'test/widget_test.dart' : 'lib/main.dart',
                highlightedLines: step >= 2 ? const [4] : const [],
              ),
            ),
            const SizedBox(height: Tokens.gapMd),
            const Callout(
              atStep: 2,
              text:
                  'One line. The whole tree below is now testable — '
                  'and nothing below it changed.',
              color: Palette.green,
            ),
          ],
        ),
      ),
    ),
  );
}
