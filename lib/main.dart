import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/world_globe_screen.dart';
import 'services/beer_collection_service.dart';
import 'services/catalog_service.dart';

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
    const seedColor = Color(0xFFC9752B);
    return MaterialApp(
      title: 'Bierodex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_bar, size: 48, color: Color(0xFFC9752B)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement du catalogue...'),
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
              const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger le catalogue.',
                style: TextStyle(fontWeight: FontWeight.bold),
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
