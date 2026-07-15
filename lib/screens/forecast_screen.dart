import 'package:flutter/material.dart';

import '../models/forecast.dart';
import '../services/weather_service.dart';
import '../widgets/error_view.dart';

/// Shows the 5-day forecast for a city, one card per day.
class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key, required this.city});

  /// City to forecast, passed in by the screen that opened this one.
  final String city;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _service = WeatherService();
  late Future<Forecast> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = _service.getForecast(widget.city);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _forecastFuture = _service.getForecast(widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.city} · 5-day forecast')),
      body: FutureBuilder<Forecast>(
        future: _forecastFuture,
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
              onRetry: _refresh,
            );
          }

          final forecast = snapshot.data;
          if (forecast == null) {
            return const SizedBox.shrink();
          }

          final days = forecast.dailySummaries;
          if (days.isEmpty) {
            return const Center(child: Text('No forecast data available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            itemBuilder: (context, index) => _DayCard(day: days[index]),
          );
        },
      ),
    );
  }
}

/// One day of the forecast: weekday, icon, description, and low/high temps.
class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final DailyForecast day;

  /// Weekday abbreviations indexed by [DateTime.weekday] (1 = Monday).
  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                _weekdays[day.date.weekday - 1],
                style: theme.textTheme.titleMedium,
              ),
            ),
            Image.network(
              day.iconUrl,
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.cloud_outlined, size: 36),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                day.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '${day.maxTemp.round()}° / ${day.minTemp.round()}°',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
