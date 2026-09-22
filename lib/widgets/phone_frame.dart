import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// A rounded 9:19.5 phone silhouette around [child], for slides that show a
/// screenshot or live demo "on a phone" rather than floating in space.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({required this.child, this.width = 300, super.key});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 19.5 / 9;
    final outerRadius = width * 0.12;
    final innerRadius = outerRadius - Tokens.strokeWidth;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(Tokens.strokeWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: Palette.textSecondary,
          width: Tokens.strokeWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: width * 0.025),
                width: width * 0.32,
                height: width * 0.07,
                decoration: BoxDecoration(
                  color: Palette.textSecondary,
                  borderRadius: BorderRadius.circular(width * 0.035),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
