import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/services/favorites_service.dart';

void main() {
  late FavoritesService favorites;

  setUp(() {
    // In-memory store, reset before each test.
    SharedPreferences.setMockInitialValues({});
    favorites = FavoritesService();
  });

  group('FavoritesService', () {
    test('starts empty', () async {
      expect(await favorites.load(), isEmpty);
    });

    test('adds a city and reports it as favorite', () async {
      await favorites.add('Tehran');

      expect(await favorites.load(), ['Tehran']);
      expect(await favorites.isFavorite('Tehran'), isTrue);
    });

    test('does not add duplicates (case-insensitive)', () async {
      await favorites.add('Tehran');
      await favorites.add('tehran');

      expect(await favorites.load(), ['Tehran']);
    });

    test('ignores blank city names', () async {
      await favorites.add('   ');

      expect(await favorites.load(), isEmpty);
    });

    test('removes a city (case-insensitive)', () async {
      await favorites.add('Tehran');
      await favorites.remove('TEHRAN');

      expect(await favorites.load(), isEmpty);
      expect(await favorites.isFavorite('Tehran'), isFalse);
    });

    test('toggle adds then removes, returning the new state', () async {
      expect(await favorites.toggle('Paris'), isTrue);
      expect(await favorites.isFavorite('Paris'), isTrue);

      expect(await favorites.toggle('Paris'), isFalse);
      expect(await favorites.isFavorite('Paris'), isFalse);
    });

    test('preserves insertion order', () async {
      await favorites.add('Tehran');
      await favorites.add('Paris');
      await favorites.add('Tokyo');

      expect(await favorites.load(), ['Tehran', 'Paris', 'Tokyo']);
    });
  });
}
