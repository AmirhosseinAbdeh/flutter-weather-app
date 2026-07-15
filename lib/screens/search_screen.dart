import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/error_view.dart';

/// Lets the user search for a city and see its current weather.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _controller = TextEditingController();

  /// Null until the user runs their first search.
  Future<Weather>? _weatherFuture;

  @override
  void dispose() {
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _weatherFuture = _service.getCurrentWeather(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
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
