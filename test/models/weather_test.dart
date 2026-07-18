import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather.dart';

void main() {
  group('Weather.fromJson', () {
    test('parses a full OpenWeatherMap response', () {
      final json = <String, dynamic>{
        'name': 'Tehran',
        'sys': {'country': 'IR'},
        'main': {
          'temp': 30.5,
          'feels_like': 29.8,
          'temp_min': 28.0,
          'temp_max': 32.0,
          'humidity': 24,
          'pressure': 1012,
        },
        'wind': {'speed': 3.6},
        'weather': [
          {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
        ],
      };

      final weather = Weather.fromJson(json);

      expect(weather.cityName, 'Tehran');
      expect(weather.country, 'IR');
      expect(weather.temperature, 30.5);
      expect(weather.feelsLike, 29.8);
      expect(weather.tempMin, 28.0);
      expect(weather.tempMax, 32.0);
      expect(weather.humidity, 24);
      expect(weather.pressure, 1012);
      expect(weather.windSpeed, 3.6);
      expect(weather.condition, 'Clear');
      expect(weather.description, 'clear sky');
      expect(weather.icon, '01d');
      expect(weather.iconUrl, 'https://openweathermap.org/img/wn/01d@2x.png');
    });

    test('converts sunrise and sunset to local time', () {
      // 2026-07-15 05:30 and 20:15 UTC, as unix seconds.
      final sunriseUtc = DateTime.utc(2026, 7, 15, 5, 30);
      final sunsetUtc = DateTime.utc(2026, 7, 15, 20, 15);

      final weather = Weather.fromJson({
        'name': 'Tehran',
        'sys': {
          'country': 'IR',
          'sunrise': sunriseUtc.millisecondsSinceEpoch ~/ 1000,
          'sunset': sunsetUtc.millisecondsSinceEpoch ~/ 1000,
        },
        'main': {'temp': 30.0},
        'weather': <dynamic>[],
      });

      expect(weather.sunrise, sunriseUtc.toLocal());
      expect(weather.sunset, sunsetUtc.toLocal());
    });

    test('leaves sunrise and sunset null when the API omits them', () {
      final weather = Weather.fromJson({
        'name': 'Tehran',
        'main': {'temp': 30.0},
        'weather': <dynamic>[],
      });

      expect(weather.sunrise, isNull);
      expect(weather.sunset, isNull);
    });

    test('handles integer temperatures and missing fields gracefully', () {
      final json = <String, dynamic>{
        'name': 'Paris',
        'main': {'temp': 20, 'humidity': 50},
        'weather': <dynamic>[],
      };

      final weather = Weather.fromJson(json);

      expect(weather.cityName, 'Paris');
      expect(weather.country, '');
      expect(weather.temperature, 20.0);
      expect(weather.humidity, 50);
      expect(weather.description, '');
      expect(weather.windSpeed, 0.0);
    });
  });
}
