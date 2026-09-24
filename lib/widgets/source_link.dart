import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where the repository lives. One constant, so a fork or rename is a
/// one-line change rather than a hunt through every slide.
const repoBlobUrl =
    'https://github.com/harshsharma94/flutter-presentation/blob/main';

/// Opens [url] in a new browser tab, so the deck stays exactly where it was.
/// Shared by every clickable link in the deck — the "full source" chips and
/// the references slide.
Future<bool> openInNewTab(Uri url) =>
    launchUrl(url, webOnlyWindowName: '_blank');

/// A small "full source" chip that opens a reference file on GitHub in a new
/// tab.
///
/// Click, not hover, deliberately. On a projected deck the audience watches
/// the screen rather than the presenter's cursor, a hover popup vanishes the
/// moment the mouse moves, cannot be scrolled or copied from, and does not
/// exist at all on a phone viewing the Pages build. A new tab keeps the deck
/// where it was.
///
/// It links to the files under `lib/reference/`, never to the slide's own
/// source: a slide file is animation code that draws a diagram of a
/// ChangeNotifier, and a learner who opens it finds four hundred lines of
/// `StepReveal` instead of the thing they wanted to copy.
class SourceLink extends StatelessWidget {
  const SourceLink({required this.path, super.key});

  /// Repository-relative path, e.g. `lib/reference/change_notifier_example.dart`.
  final String path;

  Uri get url => Uri.parse('$repoBlobUrl/$path');

  String get _fileName => path.split('/').last;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return Material(
      color: pal.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Palette.blue, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radius),
        onTap: () => openInNewTab(url),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Tokens.gapSm,
            vertical: Tokens.gapXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.code_rounded, color: Palette.blue, size: 20),
              SizedBox(width: Tokens.gapXs),
              Text(
                'full source · $_fileName',
                style: TextStyle(
                  color: Palette.blue,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded, color: Palette.blue, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
