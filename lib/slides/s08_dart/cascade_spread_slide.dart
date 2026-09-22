import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/code_panel.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

const _repeated = '''
final dio = Dio();
dio.options.baseUrl = 'https://api.unsplash.com';
dio.options.connectTimeout = const Duration(seconds: 10);
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(LogInterceptor());''';

const _cascade = '''
final dio = Dio()
  ..options.baseUrl = 'https://api.unsplash.com'
  ..options.connectTimeout = const Duration(seconds: 10)
  ..interceptors.add(AuthInterceptor())
  ..interceptors.add(LogInterceptor());''';

const _spread = '''
Column(
  children: [
    const Header(),
    ...photos.map(PhotoTile.new),
    if (isLoading) const CircularProgressIndicator(),
  ],
)''';

/// Slide 42 — `/cascade-spread` (2 steps, A34). Ninety seconds. They will
/// meet both in the codebase today; they do not need a lecture.
class CascadeSpreadBody extends StatelessWidget {
  const CascadeSpreadBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gapLg),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '..  cascade — same object, no repeated variable',
                  style: TextStyle(color: Palette.textSecondary, fontSize: 22),
                ),
                const SizedBox(height: Tokens.gapXs),
                SizedBox(
                  width: 820,
                  child: CodePanel(code: step >= 1 ? _cascade : _repeated),
                ),
                const SizedBox(height: Tokens.gapLg),
                const StepReveal(
                  atStep: 2,
                  dimWhenPast: false,
                  child: Text(
                    '...  spread — a list, flattened into a child list',
                    style:
                        TextStyle(color: Palette.textSecondary, fontSize: 22),
                  ),
                ),
                const SizedBox(height: Tokens.gapXs),
                const StepReveal(
                  atStep: 2,
                  dimWhenPast: false,
                  child: SizedBox(
                    width: 820,
                    child: CodePanel(code: _spread),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
