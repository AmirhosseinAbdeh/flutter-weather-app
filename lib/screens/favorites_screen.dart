import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/favorites_service.dart';
import '../services/weather_service.dart';
import '../widgets/gradient_background.dart';

/// Lists the user's saved cities, each with its current temperature.
///
/// Tapping a city pops this screen and returns its name to the caller, which
/// then shows that city's weather. Each row can be deleted.
class FavoritesScreen extends StatefulWidget {
  FavoritesScreen({
    super.key,
    FavoritesService? favorites,
    WeatherService? weather,
  }) : favorites = favorites ?? FavoritesService(),
       weather = weather ?? WeatherService();

  final FavoritesService favorites;
  final WeatherService weather;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<String>> _citiesFuture;

  /// One in-flight request per city, kept so rebuilds do not refetch.
  final Map<String, Future<Weather>> _weatherByCity = {};

  @override
  void initState() {
    super.initState();
    _citiesFuture = widget.favorites.load();
  }

  @override
  void dispose() {
    widget.weather.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _weatherByCity.clear();
      _citiesFuture = widget.favorites.load();
    });
  }

  Future<void> _remove(String city) async {
    await widget.favorites.remove(city);
    _reload();
  }

  Future<Weather> _weatherFor(String city) =>
      _weatherByCity[city] ??= widget.weather.getCurrentWeather(city);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Favorite cities'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: FutureBuilder<List<String>>(
            future: _citiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final cities = snapshot.data ?? const <String>[];
              if (cities.isEmpty) {
                return const _EmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  kToolbarHeight + 8,
                  16,
                  16,
                ),
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return _FavoriteTile(
                    city: city,
                    weather: _weatherFor(city),
                    onTap: () => Navigator.of(context).pop(city),
                    onRemove: () => _remove(city),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One saved city: name, its current temperature and icon, and a remove button.
class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.city,
    required this.weather,
    required this.onTap,
    required this.onRemove,
  });

  final String city;
  final Future<Weather> weather;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.location_city, color: Colors.white),
        title: Text(
          city,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: _WeatherSummary(weather: weather),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white70),
          tooltip: 'Remove',
          onPressed: onRemove,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Resolves [weather] into a one-line "24° · clear sky" summary.
///
/// Failures (no API key, unknown city, offline) collapse to a dash rather than
/// an error, so one bad row never breaks the list.
class _WeatherSummary extends StatelessWidget {
  const _WeatherSummary({required this.weather});

  final Future<Weather> weather;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Weather>(
      future: weather,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          );
        }

        final data = snapshot.data;
        if (snapshot.error != null || data == null) {
          return const Text('—', style: TextStyle(color: Colors.white70));
        }

        return Text(
          '${data.temperature.round()}° · ${data.description}',
          style: const TextStyle(color: Colors.white70),
        );
      },
    );
  }
}

/// Shown when no cities have been saved yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'No favorite cities yet.\n'
              'Search for a city and tap the star to save it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
