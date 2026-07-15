import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/error_view.dart';
import 'search_screen.dart';

/// The app's landing screen: shows the current weather for the default city.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// City loaded when the app starts.
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

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Search city',
          ),
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
            return ErrorView(
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
          return CurrentWeatherView(weather: weather);
        },
      ),
    );
  }
}
