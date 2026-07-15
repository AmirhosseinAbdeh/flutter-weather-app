/// Lenient readers for OpenWeatherMap JSON payloads.
///
/// The API returns numbers as either `int` or `double` depending on the value,
/// and a malformed or partial payload should degrade to defaults rather than
/// throw, so models read through these instead of casting directly.
library;

/// Converts a JSON number to a [double], defaulting to `0.0` when absent or
/// not numeric.
double jsonToDouble(Object? value) => value is num ? value.toDouble() : 0.0;

/// Converts a JSON number to an [int], defaulting to `0` when absent or not
/// numeric.
int jsonToInt(Object? value) => value is num ? value.toInt() : 0;

/// Reads a nested JSON object, defaulting to an empty map when absent or not
/// an object.
Map<String, dynamic> jsonToMap(Object? value) =>
    value is Map ? value.cast<String, dynamic>() : const {};

/// Reads a nested JSON array, defaulting to an empty list when absent or not
/// an array.
List<dynamic> jsonToList(Object? value) => value is List ? value : const [];

/// Reads a JSON string, defaulting to `''` when absent or not a string.
String jsonToString(Object? value) => value is String ? value : '';
