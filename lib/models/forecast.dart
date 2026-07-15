import 'json_helpers.dart';

/// A single 3-hour data point from the OpenWeatherMap `/forecast` endpoint.
class ForecastEntry {
  const ForecastEntry({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.condition,
    required this.description,
    required this.icon,
  });

  /// Time of this data point, in the device's local time zone.
  final DateTime dateTime;

  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;

  /// Short condition group, e.g. "Rain".
  final String condition;

  /// Human-readable description, e.g. "light rain".
  final String description;

  /// Icon code, e.g. "10d".
  final String icon;

  factory ForecastEntry.fromJson(Map<String, dynamic> json) {
    final main = jsonToMap(json['main']);
    final weatherList = jsonToList(json['weather']);
    final weather = weatherList.isEmpty
        ? const <String, dynamic>{}
        : jsonToMap(weatherList.first);

    return ForecastEntry(
      // `dt` is a UTC unix timestamp in seconds.
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        jsonToInt(json['dt']) * 1000,
        isUtc: true,
      ).toLocal(),
      temperature: jsonToDouble(main['temp']),
      tempMin: jsonToDouble(main['temp_min']),
      tempMax: jsonToDouble(main['temp_max']),
      humidity: jsonToInt(main['humidity']),
      condition: jsonToString(weather['main']),
      description: jsonToString(weather['description']),
      icon: jsonToString(weather['icon']),
    );
  }
}

/// One calendar day of the forecast, aggregated from its [ForecastEntry] points.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
  });

  /// Midnight of the day this summary covers.
  final DateTime date;

  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;

  /// Full URL of the weather icon served by OpenWeatherMap.
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

/// A 5-day / 3-hour forecast for a city.
class Forecast {
  const Forecast({
    required this.cityName,
    required this.country,
    required this.entries,
  });

  final String cityName;
  final String country;

  /// Raw 3-hour data points, in the order the API returned them.
  final List<ForecastEntry> entries;

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final city = jsonToMap(json['city']);

    return Forecast(
      cityName: jsonToString(city['name']),
      country: jsonToString(city['country']),
      entries: [
        for (final item in jsonToList(json['list']))
          if (item is Map) ForecastEntry.fromJson(jsonToMap(item)),
      ],
    );
  }

  /// [entries] collapsed into one summary per calendar day, oldest first.
  ///
  /// Each day reports the lowest and highest temperature across its points,
  /// and takes its icon and description from the point nearest midday, which
  /// represents the day better than an arbitrary night-time reading.
  List<DailyForecast> get dailySummaries {
    final byDay = <DateTime, List<ForecastEntry>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.dateTime.year,
        entry.dateTime.month,
        entry.dateTime.day,
      );
      byDay.putIfAbsent(day, () => []).add(entry);
    }

    final days = byDay.keys.toList()..sort();
    return [for (final day in days) _summarize(day, byDay[day]!)];
  }

  static DailyForecast _summarize(DateTime day, List<ForecastEntry> entries) {
    var minTemp = entries.first.tempMin;
    var maxTemp = entries.first.tempMax;
    for (final entry in entries) {
      if (entry.tempMin < minTemp) minTemp = entry.tempMin;
      if (entry.tempMax > maxTemp) maxTemp = entry.tempMax;
    }

    final midday = entries.reduce(
      (a, b) =>
          (a.dateTime.hour - 12).abs() <= (b.dateTime.hour - 12).abs() ? a : b,
    );

    return DailyForecast(
      date: day,
      minTemp: minTemp,
      maxTemp: maxTemp,
      description: midday.description,
      icon: midday.icon,
    );
  }
}
