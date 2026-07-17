import 'package:flutter/material.dart';

import '../services/favorites_service.dart';

/// Lists the user's saved cities.
///
/// Tapping a city pops this screen and returns its name to the caller, which
/// then shows that city's weather. Each row can be deleted.
class FavoritesScreen extends StatefulWidget {
  FavoritesScreen({super.key, FavoritesService? favorites})
    : favorites = favorites ?? FavoritesService();

  final FavoritesService favorites;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<String>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    _citiesFuture = widget.favorites.load();
  }

  void _reload() {
    setState(() {
      _citiesFuture = widget.favorites.load();
    });
  }

  Future<void> _remove(String city) async {
    await widget.favorites.remove(city);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite cities')),
      body: FutureBuilder<List<String>>(
        future: _citiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cities = snapshot.data ?? const <String>[];
          if (cities.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(city),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove',
                  onPressed: () => _remove(city),
                ),
                onTap: () => Navigator.of(context).pop(city),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite cities yet.\nSearch for a city and tap the star to save it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
