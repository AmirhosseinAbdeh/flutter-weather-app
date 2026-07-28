import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  error,
}

class LocationResult {
  const LocationResult({
    required this.status,
    this.latitude,
    this.longitude,
    this.message,
  });

  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? message;

  bool get isSuccess => status == LocationStatus.success;
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    debugPrint('A - getCurrentLocation');
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('B - serviceEnabled = $serviceEnabled');

      if (!serviceEnabled) {
        return const LocationResult(
          status: LocationStatus.serviceDisabled,
          message: 'Location services are disabled.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('C - permission = $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return const LocationResult(
            status: LocationStatus.permissionDenied,
            message: 'Location permission denied.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationStatus.permissionDeniedForever,
          message: 'Location permission permanently denied.',
        );
      }

      LocationSettings locationSettings;

      if (kIsWeb) {
        locationSettings = WebSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
      }
      debugPrint('E - before getCurrentPosition');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      debugPrint('F - after getCurrentPosition');
      debugPrint('Latitude = ${position.latitude}');
      debugPrint('Longitude = ${position.longitude}');

      return LocationResult(
        status: LocationStatus.success,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      debugPrint('TIMEOUT');
      return const LocationResult(
        status: LocationStatus.timeout,
        message: 'Location request timed out. Please try again.',
      );
    } catch (e, s) {
      debugPrint('ERROR');
      debugPrint(e.toString());
      debugPrint(s.toString());
      return const LocationResult(
        status: LocationStatus.error,
        message: 'Failed to get current location.',
      );
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
