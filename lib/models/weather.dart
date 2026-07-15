import 'json_helpers.dart';

/// Current weather for a single city, parsed from the OpenWeatherMap
/// `/weather` endpoint response.
class Weather {
  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.icon,
  });

  /// City name, e.g. "Tehran".
  final String cityName;

  /// Two-letter country code, e.g. "IR".
  final String country;

  /// Current temperature, in the configured units (e.g. °C for metric).
  final double temperature;

  /// "Feels like" temperature.
  final double feelsLike;

  /// Minimum observed temperature at request time.
  final double tempMin;

  /// Maximum observed temperature at request time.
  final double tempMax;

  /// Humidity as a percentage (0–100).
  final int humidity;

  /// Atmospheric pressure in hPa.
  final int pressure;

  /// Wind speed (m/s for metric units).
  final double windSpeed;

  /// Short condition group, e.g. "Clear", "Rain".
  final String condition;

  /// Human-readable description, e.g. "clear sky".
  final String description;

  /// Icon code, e.g. "01d". See [iconUrl].
  final String icon;

  /// Full URL of the weather icon served by OpenWeatherMap.
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Builds a [Weather] from the decoded JSON of the `/weather` endpoint.
  ///
  /// Missing or malformed fields fall back to sensible defaults so parsing
  /// never throws on an unexpected payload.
  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = jsonToMap(json['main']);
    final wind = jsonToMap(json['wind']);
    final sys = jsonToMap(json['sys']);
    final weatherList = jsonToList(json['weather']);
    final weather = weatherList.isEmpty
        ? const <String, dynamic>{}
        : jsonToMap(weatherList.first);

    return Weather(
      cityName: jsonToString(json['name']),
      country: jsonToString(sys['country']),
      temperature: jsonToDouble(main['temp']),
      feelsLike: jsonToDouble(main['feels_like']),
      tempMin: jsonToDouble(main['temp_min']),
      tempMax: jsonToDouble(main['temp_max']),
      humidity: jsonToInt(main['humidity']),
      pressure: jsonToInt(main['pressure']),
      windSpeed: jsonToDouble(wind['speed']),
      condition: jsonToString(weather['main']),
      description: jsonToString(weather['description']),
      icon: jsonToString(weather['icon']),
    );
  }
}
