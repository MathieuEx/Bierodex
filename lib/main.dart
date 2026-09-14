import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/world_map_screen.dart';
import 'services/auth_service.dart';
import 'services/beer_collection_service.dart';
import 'services/catalog_service.dart';
import 'services/secure_session_storage.dart';
import 'services/user_beer_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: useSecureSessionStorage
          ? SecureSessionStorage(
              persistSessionKey: supabaseSessionKey(SupabaseConfig.url),
            )
          : null,
    ),
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

  /// Les tests de widgets ne peuvent pas se connecter (aucun appel réseau) :
  /// ils désactivent l'écran de connexion obligatoire.
  final bool requireSignIn;

  const BierodexApp({super.key, this.catalogFuture, this.requireSignIn = true});

  @override
  State<BierodexApp> createState() => _BierodexAppState();
}

class _BierodexAppState extends State<BierodexApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late Future<void> _catalogFuture;
  bool _wasSignedIn = AuthService.instance.isSignedIn;

  @override
  void initState() {
    super.initState();
    _catalogFuture = widget.catalogFuture ?? _loadCatalogAndUserBeers();
    AuthService.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Déconnexion (volontaire ou session révoquée/expirée) : on referme
  /// toutes les pages ouvertes par-dessus l'accueil, sinon elles
  /// resteraient visibles au-dessus de l'écran de connexion.
  void _onAuthChanged() {
    final signedIn = AuthService.instance.isSignedIn;
    if (_wasSignedIn && !signedIn) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    _wasSignedIn = signedIn;
  }

  /// Charge le catalogue partagé puis y fusionne les bières ajoutées par
  /// l'utilisateur (voir [UserBeerService]) : dans cet ordre, sans quoi le
  /// catalogue écraserait les ajouts personnels déjà fusionnés.
  Future<void> _loadCatalogAndUserBeers() async {
    await CatalogService.instance.load();
    await UserBeerService.instance.load();
  }

  void _retry() {
    setState(() {
      _catalogFuture = _loadCatalogAndUserBeers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Bierodex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, catalog) =>
            !widget.requireSignIn || AuthService.instance.isSignedIn
            ? catalog!
            : const LoginScreen(),
        child: FutureBuilder<void>(
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
            return const WorldMapScreen();
          },
        ),
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
            Text('Bierodex', style: Theme.of(context).textTheme.headlineSmall),
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
