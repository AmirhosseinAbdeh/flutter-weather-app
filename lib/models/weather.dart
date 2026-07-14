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
    final main = json['main'] as Map<String, dynamic>? ?? const {};
    final wind = json['wind'] as Map<String, dynamic>? ?? const {};
    final sys = json['sys'] as Map<String, dynamic>? ?? const {};
    final weatherList = json['weather'] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};

    return Weather(
      cityName: json['name'] as String? ?? '',
      country: sys['country'] as String? ?? '',
      temperature: _toDouble(main['temp']),
      feelsLike: _toDouble(main['feels_like']),
      tempMin: _toDouble(main['temp_min']),
      tempMax: _toDouble(main['temp_max']),
      humidity: _toInt(main['humidity']),
      pressure: _toInt(main['pressure']),
      windSpeed: _toDouble(wind['speed']),
      condition: weather['main'] as String? ?? '',
      description: weather['description'] as String? ?? '',
      icon: weather['icon'] as String? ?? '',
    );
  }

  /// Safely converts a JSON number (int or double) to a [double].
  static double _toDouble(Object? value) =>
      value is num ? value.toDouble() : 0.0;

  /// Safely converts a JSON number to an [int].
  static int _toInt(Object? value) => value is num ? value.toInt() : 0;
}
