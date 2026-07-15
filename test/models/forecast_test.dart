import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/forecast.dart';

/// Builds one 3-hour entry as the API would return it.
///
/// [dt] is a UTC unix timestamp in seconds.
Map<String, dynamic> entryJson({
  required int dt,
  required double temp,
  required double tempMin,
  required double tempMax,
  String description = 'clear sky',
  String icon = '01d',
}) {
  return {
    'dt': dt,
    'main': {
      'temp': temp,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'humidity': 30,
    },
    'weather': [
      {'main': 'Clear', 'description': description, 'icon': icon},
    ],
  };
}

/// UTC seconds for a given local date/time, so grouping lands on the day we
/// expect regardless of the machine's time zone.
int localSeconds(int year, int month, int day, int hour) =>
    DateTime(year, month, day, hour).millisecondsSinceEpoch ~/ 1000;

void main() {
  group('Forecast.fromJson', () {
    test('parses the city and its entries', () {
      final forecast = Forecast.fromJson({
        'city': {'name': 'Tehran', 'country': 'IR'},
        'list': [
          entryJson(
            dt: localSeconds(2026, 7, 15, 12),
            temp: 30,
            tempMin: 28,
            tempMax: 32,
          ),
        ],
      });

      expect(forecast.cityName, 'Tehran');
      expect(forecast.country, 'IR');
      expect(forecast.entries, hasLength(1));
      expect(forecast.entries.first.temperature, 30);
      expect(forecast.entries.first.description, 'clear sky');
    });

    test('returns empty entries when the payload has no list', () {
      final forecast = Forecast.fromJson({'city': {}});

      expect(forecast.entries, isEmpty);
      expect(forecast.dailySummaries, isEmpty);
    });
  });

  group('Forecast.dailySummaries', () {
    test('groups entries by day with that day-s min and max temps', () {
      final forecast = Forecast.fromJson({
        'city': {'name': 'Tehran', 'country': 'IR'},
        'list': [
          entryJson(
            dt: localSeconds(2026, 7, 15, 9),
            temp: 26,
            tempMin: 24,
            tempMax: 27,
          ),
          entryJson(
            dt: localSeconds(2026, 7, 15, 15),
            temp: 33,
            tempMin: 30,
            tempMax: 35,
          ),
          entryJson(
            dt: localSeconds(2026, 7, 16, 12),
            temp: 20,
            tempMin: 18,
            tempMax: 22,
          ),
        ],
      });

      final days = forecast.dailySummaries;

      expect(days, hasLength(2));
      // Day one spans both of its entries.
      expect(days.first.date, DateTime(2026, 7, 15));
      expect(days.first.minTemp, 24);
      expect(days.first.maxTemp, 35);
      // Day two stands alone.
      expect(days.last.date, DateTime(2026, 7, 16));
      expect(days.last.minTemp, 18);
      expect(days.last.maxTemp, 22);
    });

    test('takes icon and description from the entry nearest midday', () {
      final forecast = Forecast.fromJson({
        'city': {'name': 'Tehran', 'country': 'IR'},
        'list': [
          entryJson(
            dt: localSeconds(2026, 7, 15, 3),
            temp: 20,
            tempMin: 19,
            tempMax: 21,
            description: 'clear sky',
            icon: '01n',
          ),
          entryJson(
            dt: localSeconds(2026, 7, 15, 13),
            temp: 30,
            tempMin: 29,
            tempMax: 31,
            description: 'light rain',
            icon: '10d',
          ),
        ],
      });

      final day = forecast.dailySummaries.single;

      expect(day.description, 'light rain');
      expect(day.icon, '10d');
      expect(day.iconUrl, 'https://openweathermap.org/img/wn/10d@2x.png');
    });

    test('orders days oldest first even when entries arrive out of order', () {
      final forecast = Forecast.fromJson({
        'city': {'name': 'Tehran', 'country': 'IR'},
        'list': [
          entryJson(
            dt: localSeconds(2026, 7, 17, 12),
            temp: 20,
            tempMin: 18,
            tempMax: 22,
          ),
          entryJson(
            dt: localSeconds(2026, 7, 15, 12),
            temp: 30,
            tempMin: 28,
            tempMax: 32,
          ),
        ],
      });

      final days = forecast.dailySummaries;

      expect(days.first.date, DateTime(2026, 7, 15));
      expect(days.last.date, DateTime(2026, 7, 17));
    });
  });
}
