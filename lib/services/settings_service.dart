import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _defaultCityKey = 'default_city';
  static const String _locationRequestedKey = 'location_requested';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getDefaultCity() async {
    final prefs = await _prefs;
    return prefs.getString(_defaultCityKey);
  }

  Future<void> setDefaultCity(String city) async {
    final normalized = city.trim();
    if (normalized.isEmpty) return;

    final prefs = await _prefs;
    await prefs.setString(_defaultCityKey, normalized);
  }

  Future<bool> hasRequestedLocation() async {
    final prefs = await _prefs;
    return prefs.getBool(_locationRequestedKey) ?? false;
  }

  Future<void> setLocationRequested(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_locationRequestedKey, value);
  }

  Future<void> clearDefaultCity() async {
    final prefs = await _prefs;
    await prefs.remove(_defaultCityKey);
  }
}
