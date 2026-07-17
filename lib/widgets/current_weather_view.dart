import 'package:flutter/material.dart';

import '../models/weather.dart';

/// Renders the current weather for a city: location, icon, temperature,
/// description, and a details card.
///
/// Shared by the Home and Search screens.
class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({super.key, required this.weather});

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
  const _Detail({required this.icon, required this.label, required this.value});

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
