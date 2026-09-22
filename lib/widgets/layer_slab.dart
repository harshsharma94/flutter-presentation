import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// One colour-coded concern. The *same* [Band] values are reused across
/// slide 21 and 24 so the sort reads as the same bands moving, not new
/// bands appearing.
class Band {
  Band({required this.label, required this.color});

  final String label;
  final Color color;
}

/// The four concerns tangled together in one file on slide 21 and sorted
/// into three layers on slide 22.
final uiBand = Band(label: 'build() — Column, ListView', color: Palette.blue);
final uiBand2 = Band(
  label: 'build() — error Text, spinner',
  color: Palette.blue,
);
final networkBand = Band(label: 'dio.get(…)', color: Palette.green);
final networkBand2 = Band(label: 'retry + timeout', color: Palette.green);
final parseBand = Band(label: "json['urls']['regular']", color: Palette.amber);
final rulesBand = Band(
  label: 'if (likes > 100) featured = true',
  color: Palette.red,
);
final rulesBand2 = Band(label: 'sort by likes desc', color: Palette.red);

/// A named layer holding [bands]. [onFire] tints the slab red — used on
/// slide 23 when the dependency rule is broken and the Domain layer stops
/// being independently testable.
class LayerSlab extends StatelessWidget {
  const LayerSlab({
    required this.name,
    required this.bands,
    this.onFire = false,
    this.width = 380,
    this.subtitle,
    super.key,
  });

  final String name;
  final List<Band> bands;
  final bool onFire;
  final double width;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);

    return AnimatedContainer(
      duration: Tokens.travel,
      curve: Tokens.curve,
      width: width,
      padding: EdgeInsets.all(Tokens.gapSm),
      decoration: BoxDecoration(
        color: onFire
            ? Color.alphaBlend(Palette.red.withValues(alpha: 0.18), pal.surface)
            : pal.surface,
        border: Border.all(
          color: onFire ? Palette.red : pal.textSecondary,
          width: Tokens.strokeWidth,
        ),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onFire ? Palette.red : pal.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: Tokens.gapXs),
                Flexible(
                  child: Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: pal.textSecondary, fontSize: 17),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: Tokens.gapXs),
          for (final band in bands) ...[
            BandRow(band: band),
            SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// A single band, rendered identically wherever it appears — that visual
/// identity is what carries the continuity between slide 21 and 24.
class BandRow extends StatelessWidget {
  const BandRow({required this.band, super.key});

  final Band band;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: Tokens.gapXs, vertical: 6),
    decoration: BoxDecoration(
      color: band.color.withValues(alpha: 0.14),
      border: Border(left: BorderSide(color: band.color, width: 3)),
    ),
    child: Text(
      band.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 16,
        color: band.color,
      ),
    ),
  );
}
