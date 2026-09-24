import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bootcamp_deck/reference/change_notifier_example.dart'
    as cn;
import 'package:flutter_bootcamp_deck/reference/inherited_widget_example.dart'
    as iw;

/// These files are handed to a room to copy. Each test runs the whole app and
/// taps Like, so "the reference implementation works" is a checked fact rather
/// than a hope — and it stays checked in CI, because the Pages deploy runs the
/// suite first.
void main() {
  group('inherited_widget_example.dart', () {
    testWidgets('a like reaches both the tile and the total', (tester) async {
      await tester.pumpWidget(const iw.InheritedWidgetExampleApp());

      expect(find.text('128 likes'), findsOneWidget);
      expect(find.text('224 likes in total'), findsOneWidget);

      await tester.tap(find.byTooltip('Like').first);
      await tester.pump();

      expect(find.text('129 likes'), findsOneWidget);
      expect(find.text('225 likes in total'), findsOneWidget);
    });

    testWidgets('the leaf finds the scope without being handed anything', (
      tester,
    ) async {
      await tester.pumpWidget(const iw.InheritedWidgetExampleApp());
      final button = tester.element(find.byType(iw.LikeButton).first);

      // The point of slide 27: the scope is reachable from four levels down.
      expect(iw.PhotoScope.of(button).photos, hasLength(3));
    });
  });

  group('change_notifier_example.dart', () {
    Widget app() => ChangeNotifierProvider(
      create: (_) => cn.PhotoModel(),
      child: const cn.ChangeNotifierExampleApp(),
    );

    testWidgets('a like reaches both the tile and the total', (tester) async {
      await tester.pumpWidget(app());

      expect(find.text('128 likes'), findsOneWidget);
      expect(find.text('224 likes in total'), findsOneWidget);

      await tester.tap(find.byTooltip('Like').first);
      await tester.pump();

      expect(find.text('129 likes'), findsOneWidget);
      expect(find.text('225 likes in total'), findsOneWidget);
    });

    test('like() replaces the list and notifies', () {
      final model = cn.PhotoModel();
      addTearDown(model.dispose);
      final before = model.photos;
      var notified = 0;
      model.addListener(() => notified++);

      model.like('2');

      expect(notified, 1);
      // A new list, not an edit — the same rule the InheritedWidget version
      // depends on.
      expect(identical(model.photos, before), isFalse);
      expect(model.photos[1].likes, 65);
    });
  });
}
