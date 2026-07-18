import 'package:flutter/material.dart';

import '../models/weather.dart';

/// Renders the current weather for a city: location, icon, temperature,
/// description, and a translucent card of detail statistics.
///
/// Designed to sit on a [GradientBackground], so its text is white. Content
/// fades and slides in when it first appears.
/// Shared by the Home and Search screens.
class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({super.key, required this.weather, this.updatedAt});

  final Weather weather;

  /// When the data was last loaded; shown as a footnote if given.
  final DateTime? updatedAt;

  static const Color _translucent = Color(0x26FFFFFF); // 15% white
  static const Color _hairline = Color(0x33FFFFFF); // 20% white

  @override
  Widget build(BuildContext context) {
    final location = weather.country.isEmpty
        ? weather.cityName
        : '${weather.cityName}, ${weather.country}';
    final updated = updatedAt;

    return _FadeSlideIn(
      child: ListView(
        // AlwaysScrollable keeps pull-to-refresh working when the content fits.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.cloud_outlined, size: 96, color: Colors.white),
          ),
          Text(
            '${weather.temperature.round()}°',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 88,
              fontWeight: FontWeight.w200,
              height: 1,
            ),
          ),
          Text(
            _capitalize(weather.description),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'H: ${weather.tempMax.round()}°   L: ${weather.tempMin.round()}°',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 28),
          _DetailsCard(weather: weather),
          if (updated != null) ...[
            const SizedBox(height: 16),
            Text(
              'Updated ${_formatTime(updated)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  /// Formats [time] as 24-hour `HH:MM`.
  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// The translucent card of weather statistics below the temperature.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final sunrise = weather.sunrise;
    final sunset = weather.sunset;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: CurrentWeatherView._translucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CurrentWeatherView._hairline),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 20,
        children: [
          _Detail(
            icon: Icons.thermostat,
            label: 'Feels like',
            value: '${weather.feelsLike.round()}°',
          ),
          _Detail(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: '${weather.humidity}%',
          ),
          _Detail(
            icon: Icons.air,
            label: 'Wind',
            value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
          ),
          _Detail(
            icon: Icons.speed,
            label: 'Pressure',
            value: '${weather.pressure} hPa',
          ),
          if (sunrise != null)
            _Detail(
              icon: Icons.wb_twilight,
              label: 'Sunrise',
              value: CurrentWeatherView._formatTime(sunrise),
            ),
          if (sunset != null)
            _Detail(
              icon: Icons.nightlight_outlined,
              label: 'Sunset',
              value: CurrentWeatherView._formatTime(sunset),
            ),
        ],
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
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
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
      ),
    );
  }
}

/// Fades [child] in while sliding it up slightly, once, on first build.
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
