import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';
import 'package:flutter_bootcamp_deck/widgets/annotate.dart';
import 'package:flutter_bootcamp_deck/widgets/step_reveal.dart';

/// One entry in the `lib/` assembly (steps 1-6). [role] is null only for the
/// `lib/` root itself, which docks alongside `models/` at step 1 and has no
/// role caption of its own.
class _FolderItem {
  const _FolderItem({required this.name, required this.revealStep, this.role});

  final String name;
  final String? role;
  final int revealStep;
}

const _folders = [
  _FolderItem(name: 'lib/', revealStep: 1),
  _FolderItem(name: 'models/', role: 'what the data is', revealStep: 1),
  _FolderItem(name: 'repo/', role: 'where it comes from', revealStep: 2),
  _FolderItem(name: 'state/', role: 'what changes', revealStep: 3),
  _FolderItem(name: 'screens/', role: 'what you route to', revealStep: 4),
  _FolderItem(name: 'widgets/', role: 'what you reuse', revealStep: 5),
  _FolderItem(name: 'main.dart', role: 'wiring', revealStep: 6),
];

/// The Android-side counterparts, in the same order as `_folders.skip(1)` —
/// `_androidItems[j]` is what `_folders[j + 1]` correlates to.
const _androidItems = [
  'data/model',
  'data/repository',
  'ui/viewmodel',
  'ui/screen',
  'ui/component',
  'Application.kt',
];

const _canvasWidth = 1120.0;
const _canvasHeight = 340.0;

const _folderBoxWidth = 95.0;
const _folderBoxPitch = 103.0;
const _folderRowLeft = 10.0;
const _folderRowTop = 40.0;
const _folderRowBottom = 100.0;

const _androidColumnLeft = 850.0;
const _androidColumnWidth = 260.0;
const _androidRowHeight = 40.0;
const _androidRowGap = 8.0;
const _androidColumnTop = 40.0;
const _androidRowPitch = _androidRowHeight + _androidRowGap;

double _folderLeft(int i) => _folderRowLeft + i * _folderBoxPitch;
double _folderCenterX(int i) => _folderLeft(i) + _folderBoxWidth / 2;
double _androidRowCenterY(int j) =>
    _androidColumnTop + j * _androidRowPitch + _androidRowHeight / 2;

/// Slide 40 — `/structure` (8 steps, A3). `lib/` assembles feature-first,
/// folder by folder; step 7 draws the same shape out of the Android project
/// they already know; steps 8-9 land the two rules that matter.
class StructureBody extends StatelessWidget {
  const StructureBody({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(Tokens.gapLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _canvasWidth,
            height: _canvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < _folders.length; i++)
                  Positioned(
                    left: _folderLeft(i),
                    top: _folderRowTop,
                    width: _folderBoxWidth,
                    child: StepReveal(
                      atStep: _folders[i].revealStep,
                      slideFrom: Offset(-0.08, 0),
                      dimWhenPast: false,
                      child: _FolderBox(item: _folders[i]),
                    ),
                  ),
                Positioned(
                  left: _androidColumnLeft,
                  top: _androidColumnTop,
                  width: _androidColumnWidth,
                  child: StepReveal(
                    atStep: 7,
                    dimWhenPast: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var j = 0; j < _androidItems.length; j++) ...[
                          if (j > 0) SizedBox(height: _androidRowGap),
                          _AndroidRow(label: _androidItems[j]),
                        ],
                      ],
                    ),
                  ),
                ),
                for (var j = 0; j < _androidItems.length; j++)
                  Positioned.fill(
                    child: AnimatedArrow(
                      from: Offset(_folderCenterX(j + 1), _folderRowBottom),
                      to: Offset(_androidColumnLeft, _androidRowCenterY(j)),
                      atStep: 7,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: Tokens.gapMd),
          // The two aphorisms that used to close this slide are gone:
          // they read as filler next to the diagram and cost two extra
          // steps of animation for no new information. Say them out
          // loud if they land in the room; they are in the notes.
          Callout(
            atStep: 8,
            text: 'Same structure you used in Android. Renamed.',
          ),
        ],
      ),
    ),
  );
}

class _FolderBox extends StatelessWidget {
  const _FolderBox({required this.item});

  final _FolderItem item;

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final color = item.role == null ? pal.textSecondary : Palette.blue;
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: Tokens.strokeWidth),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.role case final role?) ...[
            SizedBox(height: 4),
            Text(
              role,
              textAlign: TextAlign.center,
              style: TextStyle(color: pal.textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _AndroidRow extends StatelessWidget {
  const _AndroidRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: _androidRowHeight,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Palette.green, width: Tokens.strokeWidth),
      borderRadius: BorderRadius.circular(Tokens.radius),
    ),
    child: Text(label, style: TextStyle(color: Palette.green, fontSize: 16)),
  );
}
