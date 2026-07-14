// Basic smoke test: verifies the app builds and shows the home screen.

import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('App renders the home screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // The home screen shows a "Weather" app bar title.
    expect(find.text('Weather'), findsOneWidget);
  });
}
