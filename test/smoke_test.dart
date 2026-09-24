import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/main.dart';
import 'package:flutter_bootcamp_deck/slides/s00_open/beautiful_lie_slide.dart';
import 'package:flutter_bootcamp_deck/slides/s00_open/title_slide.dart';

void main() {
  testWidgets('deck boots and shows the title slide', (tester) async {
    await tester.pumpWidget(const BootcampDeckApp());
    await tester.pumpAndSettle();
    // The section name doubles as the slide's persistent header (see
    // `DeckSlide`), so the title slide legitimately renders this text twice:
    // once in the header, once in the slide body.
    expect(find.text('Flutter Bootcamp'), findsWidgets);
  });

  // A presentation clicker is a USB keyboard, and nearly every model sends
  // Page Down / Page Up — the keys PowerPoint listens for. flutter_deck binds
  // only the arrow keys by default, so a clicker did nothing at all.
  group('presentation clicker', () {
    Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('Page Down advances and Page Up goes back', (tester) async {
      await tester.pumpWidget(const BootcampDeckApp());
      await tester.pumpAndSettle();
      expect(find.byType(TitleBody), findsOneWidget);

      await press(tester, LogicalKeyboardKey.pageDown);
      expect(find.byType(BeautifulLieBody), findsOneWidget);

      await press(tester, LogicalKeyboardKey.pageUp);
      expect(find.byType(TitleBody), findsOneWidget);
    });

    testWidgets('the arrow keys still work alongside it', (tester) async {
      await tester.pumpWidget(const BootcampDeckApp());
      await tester.pumpAndSettle();

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(find.byType(BeautifulLieBody), findsOneWidget);

      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(find.byType(TitleBody), findsOneWidget);
    });
  });
}
