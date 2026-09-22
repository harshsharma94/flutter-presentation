import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bootcamp_deck/main.dart';

void main() {
  testWidgets('deck boots and shows the title slide', (tester) async {
    await tester.pumpWidget(const BootcampDeckApp());
    await tester.pumpAndSettle();
    // The section name doubles as the slide's persistent header (see
    // `DeckSlide`), so the title slide legitimately renders this text twice:
    // once in the header, once in the slide body.
    expect(find.text('Flutter Bootcamp'), findsWidgets);
  });
}
