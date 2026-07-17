import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/error_view.dart';
import '../widgets/gradient_background.dart';
import 'favorites_screen.dart';
import 'forecast_screen.dart';
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const SearchScreen()));
  }

  void _openForecast() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ForecastScreen(city: _defaultCity),
      ),
    );
  }

  /// Opens the favorites list; if the user taps a city there, shows its weather
  /// in the search screen.
  Future<void> _openFavorites() async {
    final city = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => FavoritesScreen()),
    );
    if (!mounted || city == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchScreen(initialCity: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Weather'),
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Search city',
          ),
          IconButton(
            onPressed: _openForecast,
            icon: const Icon(Icons.calendar_month),
            tooltip: '5-day forecast',
          ),
          IconButton(
            onPressed: _openFavorites,
            icon: const Icon(Icons.star),
            tooltip: 'Favorite cities',
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
          final loaded =
              snapshot.connectionState != ConnectionState.waiting &&
              snapshot.error == null;
          return GradientBackground(
            icon: loaded ? snapshot.data?.icon : null,
            child: SafeArea(child: _buildContent(snapshot)),
          );
        },
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<Weather> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
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
  }
}
