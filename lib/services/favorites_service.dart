import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's favorite cities on the device.
///
/// City names are stored trimmed, in insertion order, and de-duplicated
/// case-insensitively (so "Tehran" and "tehran" are the same favorite).
class FavoritesService {
  static const String _key = 'favorite_cities';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Returns the saved cities, oldest first.
  Future<List<String>> load() async {
    final prefs = await _prefs;
    return prefs.getStringList(_key) ?? <String>[];
  }

  /// Whether [city] is already a favorite (case-insensitive).
  Future<bool> isFavorite(String city) async {
    final target = city.trim().toLowerCase();
    final cities = await load();
    return cities.any((c) => c.toLowerCase() == target);
  }

  /// Adds [city] if it is not blank and not already saved.
  Future<void> add(String city) async {
    final name = city.trim();
    if (name.isEmpty) return;

    final cities = await load();
    if (cities.any((c) => c.toLowerCase() == name.toLowerCase())) return;

    cities.add(name);
    await _save(cities);
  }

  /// Removes [city] if present (case-insensitive).
  Future<void> remove(String city) async {
    final target = city.trim().toLowerCase();
    final cities = await load()
      ..removeWhere((c) => c.toLowerCase() == target);
    await _save(cities);
  }

  /// Adds [city] if absent, removes it if present, and returns the new state:
  /// `true` when [city] ends up saved.
  Future<bool> toggle(String city) async {
    if (await isFavorite(city)) {
      await remove(city);
      return false;
    }
    await add(city);
    return true;
  }

  Future<void> _save(List<String> cities) async {
    final prefs = await _prefs;
    await prefs.setStringList(_key, cities);
  }
}
