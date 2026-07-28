import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/error_view.dart';
import '../widgets/gradient_background.dart';
import 'favorites_screen.dart';
import 'forecast_screen.dart';
import 'search_screen.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';

/// The app's landing screen: shows the current weather for the default city.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _fallbackCity = 'Tehran';

  final WeatherService _weatherService = WeatherService();
  final SettingsService _settingsService = SettingsService();
  final LocationService _locationService = LocationService();

  late Future<Weather> _weatherFuture;

  String _currentCity = _fallbackCity;

  /// When the displayed weather finished loading; null until the first success.
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();

    _weatherFuture = _initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationOnFirstLaunch();
    });
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  /// Starts a request and stamps [_updatedAt] once it succeeds.
  Future<Weather> _load() {
    final future = _weatherService.getCurrentWeather(_currentCity);
    // Errors are surfaced by the FutureBuilder; this listener only timestamps.
    future.then<void>((_) {
      if (mounted) setState(() => _updatedAt = DateTime.now());
    }, onError: (Object _) {});
    return future;
  }

  void _refresh() {
    _reloadWeather();
  }

  void _reloadWeather() {
    setState(() {
      _weatherFuture = _load();
    });
  }

  /// Pull-to-refresh handler: completes when the new request settles.
  Future<void> _handleRefresh() async {
    final future = _load();

    setState(() {
      _weatherFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // The FutureBuilder renders the error.
    }
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const SearchScreen()));
  }

  void _openForecast() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ForecastScreen(city: _currentCity),
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

  Future<Weather> _initialize() async {
    final savedCity = await _settingsService.getDefaultCity();

    if (savedCity != null && savedCity.isNotEmpty) {
      _currentCity = savedCity;
    }

    return _load();
  }

  Future<void> _changeCity(String city, {Weather? weather}) async {
    final normalizedCity = city.trim();

    _currentCity = normalizedCity;

    await _settingsService.setDefaultCity(normalizedCity);

    if (!mounted) return;

    setState(() {
      _updatedAt = DateTime.now();

      if (weather != null) {
        _weatherFuture = Future.value(weather);
      } else {
        _weatherFuture = _load();
      }
    });
  }

  Future<void> _checkLocationOnFirstLaunch() async {
    final savedCity = await _settingsService.getDefaultCity();

    if (savedCity != null && savedCity.isNotEmpty) {
      return;
    }

    final asked = await _settingsService.hasRequestedLocation();

    if (asked || !mounted) {
      return;
    }

    _showLocationDialog();
  }

  Future<void> _useCurrentLocation() async {
    await _settingsService.setLocationRequested(true);

    if (!mounted) return;

    debugPrint('1');

    final location = await _locationService.getCurrentLocation();

    debugPrint('2');

    debugPrint(location.status.toString());

    debugPrint(location.latitude.toString());
    debugPrint(location.longitude.toString());

    if (!mounted) return;

    debugPrint('3');
    switch (location.status) {
      case LocationStatus.success:
        debugPrint('SUCCESS');
        try {
          debugPrint('Latitude: ${location.latitude}');
          debugPrint('Longitude: ${location.longitude}');
          final weather = await _weatherService.getCurrentWeatherByLocation(
            location.latitude!,
            location.longitude!,
          );
          debugPrint('Weather city: ${weather.cityName}');

          final city = weather.cityName.trim();

          if (city.isEmpty) {
            _showMessage('Unable to determine your city.');
            return;
          }

          if (city == _currentCity) {
            _reloadWeather();
            _showMessage('Weather updated for $city.');
            return;
          }

          await _changeCity(city, weather: weather);

          if (!mounted) return;

          _showMessage('Weather updated for $city.');
        } on WeatherException catch (e) {
          _showMessage(e.message);
        } catch (_) {
          _showMessage('Failed to load weather.');
        }
        break;

      case LocationStatus.permissionDenied:
        _showMessage(location.message ?? 'Permission denied.');
        break;

      case LocationStatus.permissionDeniedForever:
        _showPermissionDeniedDialog();
        break;

      case LocationStatus.serviceDisabled:
        _showLocationServiceDialog();
        break;

      case LocationStatus.timeout:
        _showMessage(location.message ?? 'Location request timed out.');
        break;

      case LocationStatus.error:
        _showMessage(location.message ?? 'Failed to get current location.');
        break;
    }
  }

  Future<void> _showLocationDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Use Current Location'),
          content: const Text(
            'Would you like to use your current location as the default city?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _settingsService.setLocationRequested(true);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);

                await _useCurrentLocation();
              },
              child: const Text('Use Current Location'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationServiceDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location Disabled'),
          content: const Text(
            'Location services are turned off. Please enable GPS.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _locationService.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Location permission has been permanently denied. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _locationService.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            onPressed: _useCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Use current location',
          ),
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
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CurrentWeatherView(weather: weather, updatedAt: _updatedAt),
    );
  }
}
