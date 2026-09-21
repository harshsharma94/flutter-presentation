import 'package:flutter_test/flutter_test.dart';
import 'package:gopay_flutter_deck/main.dart';

void main() {
  testWidgets('deck boots and shows the title slide', (tester) async {
    await tester.pumpWidget(const GoPayDeckApp());
    await tester.pumpAndSettle();
    expect(find.text('GoPay · Flutter Bootcamp'), findsOneWidget);
  });
}
