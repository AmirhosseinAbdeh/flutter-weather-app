import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/forecast.dart';
import '../models/weather.dart';

/// Thrown when a weather request fails, carrying a user-friendly [message].
class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Fetches weather data from the OpenWeatherMap REST API and maps it to models.
class WeatherService {
  WeatherService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? ApiConfig.apiKey;

  final http.Client _client;
  final String _apiKey;

  /// Fetches the current weather for [city].
  ///
  /// Throws a [WeatherException] with a readable message on any failure
  /// (missing key, unknown city, network error, or unexpected status).
  Future<Weather> getCurrentWeather(String city) async {
    final json = await _fetch(ApiConfig.weatherPath, city);
    return Weather.fromJson(json);
  }

  /// Fetches the 5-day / 3-hour forecast for [city].
  ///
  /// Throws a [WeatherException] on failure, as [getCurrentWeather] does.
  Future<Forecast> getForecast(String city) async {
    final json = await _fetch(ApiConfig.forecastPath, city);
    return Forecast.fromJson(json);
  }

  /// Requests [path] for [city] and returns the decoded JSON body.
  ///
  /// Maps every failure onto a [WeatherException] carrying a message that is
  /// safe to show the user.
  Future<Map<String, dynamic>> _fetch(String path, String city) async {
    if (_apiKey.isEmpty) {
      throw const WeatherException(
        'No API key set. Run with --dart-define=OWM_API_KEY=your_key.',
      );
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: {
        'q': city,
        'appid': _apiKey,
        'units': ApiConfig.units,
        'lang': ApiConfig.language,
      },
    );

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (_) {
      throw const WeatherException(
        'Network error. Check your connection and try again.',
      );
    }

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body) as Map<String, dynamic>;
      case 401:
        throw const WeatherException('Invalid API key.');
      case 404:
        throw WeatherException('City "$city" not found.');
      default:
        throw WeatherException(
          'Failed to load weather (HTTP ${response.statusCode}).',
        );
    }
  }

  /// Closes the underlying HTTP client. Call when the service is no longer used.
  void dispose() => _client.close();
}
