import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/screens/search_screen.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('shows the empty state before any search', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));

      expect(
        find.text('Search for a city to see its weather.'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('an empty query does not start a search', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchScreen()));

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // Still the empty state: no request was made.
      expect(
        find.text('Search for a city to see its weather.'),
        findsOneWidget,
      );
    });
  });
}
