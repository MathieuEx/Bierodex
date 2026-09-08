import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/world_globe_screen.dart';
import 'services/beer_collection_service.dart';
import 'services/catalog_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  await BeerCollectionService.instance.load();
  runApp(const BierodexApp());
}

SupabaseClient get supabase => Supabase.instance.client;

class BierodexApp extends StatefulWidget {
  /// Permet aux tests d'injecter un chargement déjà résolu (après avoir
  /// peuplé `beers`/`beerStyles`/`breweryLocations` avec des données de
  /// test), plutôt que d'appeler `CatalogService.instance.load()` qui
  /// interroge Supabase.
  final Future<void>? catalogFuture;

  const BierodexApp({super.key, this.catalogFuture});

  @override
  State<BierodexApp> createState() => _BierodexAppState();
}

class _BierodexAppState extends State<BierodexApp> {
  late Future<void> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = widget.catalogFuture ?? CatalogService.instance.load();
  }

  void _retry() {
    setState(() {
      _catalogFuture = CatalogService.instance.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bierodex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: FutureBuilder<void>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _CatalogLoadingScreen();
          }
          if (snapshot.hasError) {
            return _CatalogErrorScreen(
              error: snapshot.error,
              onRetry: _retry,
            );
          }
          return const WorldGlobeScreen();
        },
      ),
    );
  }
}

class _CatalogLoadingScreen extends StatelessWidget {
  const _CatalogLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_bar, size: 48, color: AppColors.copper),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Bierodex',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Chargement du catalogue...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogErrorScreen extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _CatalogErrorScreen({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Impossible de charger le catalogue.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifie ta connexion internet.\n$error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
            ],
          ),
        ),
      ),
    );
  }
}
