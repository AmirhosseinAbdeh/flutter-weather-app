/// Configuration for the OpenWeatherMap REST API.
///
/// The API key is supplied at build/run time as a compile-time constant so it
/// never has to be committed to source control. Pass it like this:
///
/// ```
/// flutter run -d chrome --dart-define=OWM_API_KEY=your_api_key_here
/// ```
///
/// Get a free key at https://openweathermap.org/api.
class ApiConfig {
  ApiConfig._(); // This class only holds static constants.

  /// Base URL for the OpenWeatherMap 2.5 API.
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Current-weather endpoint, relative to [baseUrl].
  static const String weatherPath = '/weather';

  /// 5-day / 3-hour forecast endpoint, relative to [baseUrl].
  static const String forecastPath = '/forecast';

  /// API key, injected via `--dart-define=OWM_API_KEY=...`.
  static const String apiKey = String.fromEnvironment('OWM_API_KEY');

  /// Units of measurement: `metric` = Celsius, `imperial` = Fahrenheit.
  static const String units = 'metric';

  /// Language code for weather descriptions (e.g. `en`, `fa`).
  static const String language = 'en';

  /// Whether an API key was provided at build time.
  static bool get hasApiKey => apiKey.isNotEmpty;
}
