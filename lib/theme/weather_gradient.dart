import 'package:flutter/material.dart';

/// A vertical background gradient chosen from an OpenWeatherMap icon code
/// (e.g. "01d", "10n").
///
/// The trailing `d`/`n` selects a day or night palette; the two-digit prefix
/// selects the condition family. A null or unknown [icon] falls back to a calm
/// daytime blue.
LinearGradient weatherGradient([String? icon]) {
  final isNight = icon != null && icon.endsWith('n');
  final code = (icon == null || icon.isEmpty)
      ? ''
      : icon.substring(0, icon.length - 1);

  final colors = switch (code) {
    '01' =>
      isNight // clear sky
          ? const [Color(0xFF1A2151), Color(0xFF2C3E75)]
          : const [Color(0xFF2196F3), Color(0xFF6EC6FF)],
    '02' || '03' || '04' =>
      isNight // clouds
          ? const [Color(0xFF373B44), Color(0xFF4A5058)]
          : const [Color(0xFF54717A), Color(0xFF8CA6B4)],
    '09' || '10' => const [Color(0xFF373B44), Color(0xFF4B79A1)], // rain
    '11' => const [Color(0xFF232526), Color(0xFF414345)], // thunderstorm
    '13' => const [Color(0xFF5C7A99), Color(0xFF90AFC6)], // snow
    '50' => const [Color(0xFF3F4C6B), Color(0xFF606C88)], // mist
    _ =>
      isNight
          ? const [Color(0xFF283048), Color(0xFF48566B)]
          : const [Color(0xFF2196F3), Color(0xFF6EC6FF)],
  };

  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );
}
