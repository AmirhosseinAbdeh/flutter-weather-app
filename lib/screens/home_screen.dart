import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

/// The app's landing screen: shows the current weather for the default city.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// City loaded when the app starts, until search lands in a later commit.
  static const String _defaultCity = 'Tehran';

  final WeatherService _service = WeatherService();
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _service.getCurrentWeather(_defaultCity);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _weatherFuture = _service.getCurrentWeather(_defaultCity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<Weather>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = snapshot.error;
          if (error != null) {
            return _ErrorView(
              message: error is WeatherException
                  ? error.message
                  : 'Something went wrong. Please try again.',
              onRetry: _refresh,
            );
          }

          final weather = snapshot.data;
          if (weather == null) {
            return const SizedBox.shrink();
          }
          return _WeatherView(weather: weather);
        },
      ),
    );
  }
}

/// Renders the current weather for a city.
class _WeatherView extends StatelessWidget {
  const _WeatherView({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = weather.country.isEmpty
        ? weather.cityName
        : '${weather.cityName}, ${weather.country}';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Image.network(
              weather.iconUrl,
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.cloud_outlined, size: 96),
            ),
            Text(
              '${weather.temperature.round()}°',
              style: theme.textTheme.displayLarge,
            ),
            Text(
              weather.description,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Detail(
                      icon: Icons.thermostat,
                      label: 'Feels like',
                      value: '${weather.feelsLike.round()}°',
                    ),
                    const SizedBox(width: 32),
                    _Detail(
                      icon: Icons.water_drop_outlined,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                    ),
                    const SizedBox(width: 32),
                    _Detail(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labelled weather statistic (feels like, humidity, wind…).
class _Detail extends StatelessWidget {
  const _Detail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Shown when loading the weather fails, with a retry action.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
