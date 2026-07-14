import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_app/services/weather_service.dart';

void main() {
  group('WeatherService.getCurrentWeather', () {
    test('returns a Weather on a 200 response', () async {
      final client = MockClient((request) async {
        // The requested city is passed as the `q` query parameter.
        expect(request.url.queryParameters['q'], 'Tehran');
        return http.Response(
          jsonEncode({
            'name': 'Tehran',
            'sys': {'country': 'IR'},
            'main': {'temp': 30.0, 'humidity': 20},
            'weather': [
              {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = WeatherService(client: client, apiKey: 'test-key');
      final weather = await service.getCurrentWeather('Tehran');

      expect(weather.cityName, 'Tehran');
      expect(weather.temperature, 30.0);
      expect(weather.condition, 'Clear');
    });

    test('throws a WeatherException when the city is not found (404)', () {
      final client = MockClient(
        (request) async => http.Response('{"cod":"404"}', 404),
      );
      final service = WeatherService(client: client, apiKey: 'test-key');

      expect(
        () => service.getCurrentWeather('Nowhere'),
        throwsA(isA<WeatherException>()),
      );
    });

    test('throws a WeatherException when no API key is configured', () {
      final service = WeatherService(apiKey: '');

      expect(
        () => service.getCurrentWeather('Tehran'),
        throwsA(isA<WeatherException>()),
      );
    });
  });
}
