import 'package:flutter_test/flutter_test.dart';
import 'package:gopay_flutter_deck/main.dart';

void main() {
  testWidgets('deck boots and shows the title slide', (tester) async {
    await tester.pumpWidget(const GoPayDeckApp());
    await tester.pumpAndSettle();
    // The section name doubles as the slide's persistent header (see
    // `DeckSlide`), so the title slide legitimately renders this text twice:
    // once in the header, once in the slide body.
    expect(find.text('GoPay · Flutter Bootcamp'), findsWidgets);
  });
}
