import 'package:flutter/material.dart';

import '../theme/weather_gradient.dart';

/// Fills the screen with a weather-based gradient behind [child].
///
/// Used as the body of each screen so the (transparent) app bar floats over a
/// full-bleed background.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, this.icon, required this.child});

  /// OpenWeatherMap icon code selecting the gradient; null uses the default.
  final String? icon;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: weatherGradient(icon)),
      child: SizedBox.expand(child: child),
    );
  }
}
