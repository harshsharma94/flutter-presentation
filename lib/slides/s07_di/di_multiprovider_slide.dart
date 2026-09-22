import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/correlation_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _tangled = '''
runApp(PhotoApp(repo: repo, likes: likes, auth: auth));

HomeScreen(repo: repo, likes: likes, auth: auth)
  PhotoGrid(repo: repo, likes: likes, auth: auth)
    PhotoTile(repo: repo, likes: likes, auth: auth)
      LikeButton(likes: likes, auth: auth)''';

const _wired = '''
runApp(
  MultiProvider(
    providers: [
      Provider(create: (_) => Dio()),
      Provider(create: (c) => PhotoRepository(c.read<Dio>())),
      ChangeNotifierProvider(create: (_) => CounterModel()),
    ],
    child: PhotoApp(),
  ),
);

// anywhere below, at any depth:
final repo = context.read<PhotoRepository>();''';

/// Slide 39 — `/di-multiprovider` (5 steps, A31). The spaghetti collapses
/// into a list. Provider is already in the app for state, so this costs zero
/// new packages.
class DiMultiproviderBody extends StatelessWidget {
  const DiMultiproviderBody({required this.step, super.key});

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
                width: 820,
                child: CodePanel(
                  code: step >= 2 ? _wired : _tangled,
                  fileName: 'lib/main.dart',
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 2,
                until: 5,
                dimWhenPast: false,
                child: Text(
                  'Declared once, at the top. Read where it is used. '
                  'Nothing in between changes.',
                  style: TextStyle(color: Palette.green, fontSize: 23),
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              SizedBox(
                width: 900,
                child: CorrelationPanel(
                  flutterLabel: 'MultiProvider',
                  firstStep: 3,
                  stepsPerRow: 0,
                  rows: [
                    CorrelationRow(
                      platform: 'Android',
                      concept: 'Hilt @Module / Koin module {}',
                    ),
                    CorrelationRow(platform: 'iOS', concept: 'init injection'),
                    CorrelationRow(
                      platform: 'Java/Spring',
                      concept: '@Bean / @Configuration',
                    ),
                    CorrelationRow(platform: 'Go', concept: 'wire'),
                  ],
                ),
              ),
              SizedBox(height: Tokens.gapSm),
              StepReveal(
                atStep: 5,
                dimWhenPast: false,
                child: Text(
                  'get_it exists and is fine. You do not need it today — '
                  'Provider is already here.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 21),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
