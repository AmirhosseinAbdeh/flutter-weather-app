import 'package:flutter/material.dart';

/// The app's landing screen.
///
/// Will display the current weather for the default or last-searched city.
/// For now it is an empty placeholder that we build out in later commits.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: const Center(
        child: Text('Home screen'),
      ),
    );
  }
}
