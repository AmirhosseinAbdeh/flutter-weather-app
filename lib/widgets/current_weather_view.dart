import 'package:flutter/material.dart';

import '../models/weather.dart';

/// Renders the current weather for a city on a translucent card: location,
/// icon, temperature, description, and a details row.
///
/// Designed to sit on a [GradientBackground], so its text is white.
/// Shared by the Home and Search screens.
class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({super.key, required this.weather});

  final Weather weather;

  static const Color _translucent = Color(0x26FFFFFF); // 15% white
  static const Color _hairline = Color(0x33FFFFFF); // 20% white

  @override
  Widget build(BuildContext context) {
    final location = weather.country.isEmpty
        ? weather.cityName
        : '${weather.cityName}, ${weather.country}';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Image.network(
              weather.iconUrl,
              width: 140,
              height: 140,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.cloud_outlined,
                size: 96,
                color: Colors.white,
              ),
            ),
            Text(
              '${weather.temperature.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 88,
                fontWeight: FontWeight.w200,
                height: 1,
              ),
            ),
            Text(
              _capitalize(weather.description),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _translucent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Detail(
                    icon: Icons.thermostat,
                    label: 'Feels like',
                    value: '${weather.feelsLike.round()}°',
                  ),
                  const _VerticalDivider(),
                  _Detail(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                  ),
                  const _VerticalDivider(),
                  _Detail(
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

/// A thin vertical rule between two [_Detail]s.
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: CurrentWeatherView._hairline,
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
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
