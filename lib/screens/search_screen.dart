import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/favorites_service.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/error_view.dart';

/// Lets the user search for a city, see its current weather, and save it as a
/// favorite.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialCity});

  /// When set, this city is loaded automatically as the screen opens (used when
  /// arriving from the favorites list).
  final String? initialCity;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final WeatherService _service = WeatherService();
  final FavoritesService _favorites = FavoritesService();
  final TextEditingController _controller = TextEditingController();

  /// Null until the first search runs; drives the loading/error/result view.
  Future<Weather>? _weatherFuture;

  /// The successfully-loaded weather, or null while loading / on error.
  Weather? _currentWeather;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCity;
    if (initial != null && initial.trim().isNotEmpty) {
      _controller.text = initial;
      _load(initial);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  void _search() => _load(_controller.text);

  Future<void> _load(String rawCity) async {
    final city = rawCity.trim();
    if (city.isEmpty) return;

    final future = _service.getCurrentWeather(city);
    setState(() {
      _weatherFuture = future;
      _currentWeather = null;
      _isFavorite = false;
    });

    try {
      final weather = await future;
      final isFavorite = await _favorites.isFavorite(weather.cityName);
      if (!mounted) return;
      setState(() {
        _currentWeather = weather;
        _isFavorite = isFavorite;
      });
    } catch (_) {
      // The FutureBuilder renders the error; nothing else to do here.
    }
  }

  Future<void> _toggleFavorite() async {
    final weather = _currentWeather;
    if (weather == null) return;

    final nowFavorite = await _favorites.toggle(weather.cityName);
    if (!mounted) return;
    setState(() => _isFavorite = nowFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFavorite
              ? '${weather.cityName} added to favorites'
              : '${weather.cityName} removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          if (_currentWeather != null)
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
              tooltip: _isFavorite ? 'Remove favorite' : 'Add to favorites',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Enter a city name',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Search',
                ),
              ),
            ),
          ),
          Expanded(child: _buildResult(context)),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final future = _weatherFuture;
    if (future == null) {
      return Center(
        child: Text(
          'Search for a city to see its weather.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return FutureBuilder<Weather>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = snapshot.error;
        if (error != null) {
          return ErrorView(
            message: error is WeatherException
                ? error.message
                : 'Something went wrong. Please try again.',
            onRetry: _search,
          );
        }

        final weather = snapshot.data;
        if (weather == null) {
          return const SizedBox.shrink();
        }
        return CurrentWeatherView(weather: weather);
      },
    );
  }
}
