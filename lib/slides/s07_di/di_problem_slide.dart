import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _three = '''
final dio = Dio();
final repo = PhotoRepository(dio);
final likes = CounterModel();

runApp(PhotoApp(repo: repo, likes: likes));

// …and then, four levels down:
HomeScreen(repo: repo, likes: likes)
  PhotoGrid(repo: repo, likes: likes)
    PhotoTile(repo: repo, likes: likes)
      LikeButton(likes: likes)''';

const _four = '''
final dio = Dio();
final prefs = await SharedPreferences.getInstance();
final repo = PhotoRepository(dio, prefs);
final likes = CounterModel();
final auth = AuthController(dio, prefs);

runApp(PhotoApp(repo: repo, likes: likes, auth: auth));

// …and then, four levels down:
HomeScreen(repo: repo, likes: likes, auth: auth)
  PhotoGrid(repo: repo, likes: likes, auth: auth)
    PhotoTile(repo: repo, likes: likes, auth: auth)
      LikeButton(likes: likes, auth: auth)''';

/// Slide 37 — `/di-problem` (3 steps, A30). Prop drilling again, but for
/// services rather than data — and this time adding *one* dependency edits
/// every constructor between main and the leaf.
class DiProblemBody extends StatelessWidget {
  const DiProblemBody({required this.step, super.key});

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
                  code: step >= 3 ? _four : _three,
                  fileName: 'lib/main.dart',
                ),
              ),
              SizedBox(height: Tokens.gapMd),
              StepReveal(
                atStep: 2,
                until: 2,
                dimWhenPast: false,
                child: Text(
                  'Nothing in the middle uses these. They are just in the '
                  'way.',
                  style: TextStyle(color: pal.textSecondary, fontSize: 23),
                ),
              ),
              Callout(
                atStep: 3,
                text: 'One new dependency. Six edited constructors. '
                    'Every time.',
                color: Palette.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
