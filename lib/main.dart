import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/age_gate_screen.dart';
import 'screens/login_screen.dart';
import 'screens/shared_profile_screen.dart';
import 'screens/home_shell.dart';
import 'services/achievement_service.dart';
import 'services/auth_service.dart';
import 'services/beer_collection_service.dart';
import 'services/catalog_service.dart';
import 'services/legal_age_service.dart';
import 'services/notification_service.dart';
import 'services/offline_sync_service.dart';
import 'services/secure_session_storage.dart';
import 'services/submission_service.dart';
import 'services/user_beer_service.dart';
import 'theme/app_theme.dart';
import 'theme/brand.dart';
import 'widgets/achievement_unlocked.dart';
import 'l10n/l10n.dart';

void main() => _start();

Future<void> _start() async {
  WidgetsFlutterBinding.ensureInitialized();
  await L10n.initialize();
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
  await LegalAgeService.instance.load();
  await BeerCollectionService.instance.load();
  runApp(
    BierodexApp(
      sharedProfile: kIsWeb ? Uri.base.queryParameters['profil'] : null,
    ),
  );
}

SupabaseClient get supabase => Supabase.instance.client;

class BierodexApp extends StatefulWidget {
  /// Permet aux tests d'injecter un chargement déjà résolu (après avoir
  /// peuplé `beers`/`beerStyles`/`breweryLocations` avec des données de
  /// test), plutôt que d'appeler `CatalogService.instance.load()` qui
  /// interroge Supabase.
  final Future<void>? catalogFuture;

  /// Les tests de widgets ne peuvent pas se connecter (aucun appel réseau) :
  /// ils désactivent l'écran de connexion obligatoire et celui de l'âge.
  final bool requireSignIn;

  /// Pseudo d'un profil public à afficher directement, sans connexion
  /// (lien `?profil=<pseudo>` ouvert dans l'app web, voir `ShareConfig`).
  final String? sharedProfile;

  const BierodexApp({
    super.key,
    this.catalogFuture,
    this.requireSignIn = true,
    this.sharedProfile,
  });

  @override
  State<BierodexApp> createState() => _BierodexAppState();
}

class _BierodexAppState extends State<BierodexApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late Future<void> _catalogFuture;
  bool _wasSignedIn = AuthService.instance.isSignedIn;
  late final StreamSubscription<void> _achievementSubscription;

  /// Les célébrations s'enchaînent une par une si plusieurs badges tombent
  /// d'un coup.
  Future<void> _celebrations = Future.value();

  @override
  void initState() {
    super.initState();
    _catalogFuture = widget.catalogFuture ?? _loadCatalogAndUserBeers();
    AuthService.instance.addListener(_onAuthChanged);
    _achievementSubscription = AchievementService.instance.unlocked.listen((
      achievement,
    ) {
      _celebrations = _celebrations.then((_) async {
        final context = _navigatorKey.currentContext;
        if (context == null || !context.mounted) return;
        await showAchievementUnlocked(context, achievement);
      });
    });
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    _achievementSubscription.cancel();
    super.dispose();
  }

  /// Connexion ou déconnexion (volontaire ou session révoquée/expirée) : on
  /// referme toutes les pages ouvertes par-dessus l'écran d'accueil, sinon
  /// elles resteraient visibles au-dessus de l'app (inscription, mot de
  /// passe oublié) ou de l'écran de connexion.
  void _onAuthChanged() {
    final signedIn = AuthService.instance.isSignedIn;
    if (_wasSignedIn != signedIn) {
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
    OfflineSyncService.instance.start();
    AchievementService.instance.start();
    unawaited(NotificationService.instance.start());
    // Bières proposées par l'utilisateur et acceptées depuis : rattache sa
    // dégustation à la fiche du catalogue. Jamais bloquant pour le démarrage.
    unawaited(
      SubmissionService.instance.adoptApprovedBeers().catchError((_) => 0),
    );
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, _) => resolveAppLocale(locale),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Identité bleu nuit du logo : l'app est sombre quel que soit le
      // réglage du système (le thème clair reste défini).
      themeMode: ThemeMode.dark,
      home: ListenableBuilder(
        // Ordre d'entrée : âge légal (une fois par appareil), connexion
        // (une fois par session), puis l'app.
        listenable: Listenable.merge([
          LegalAgeService.instance,
          AuthService.instance,
        ]),
        builder: (context, catalog) {
          if (!widget.requireSignIn) return catalog!;
          if (!LegalAgeService.instance.isConfirmed) {
            return const AgeGateScreen();
          }
          // Un profil public se consulte sans compte.
          if (widget.sharedProfile != null) return catalog!;
          return AuthService.instance.isSignedIn
              ? catalog!
              : const LoginScreen();
        },
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
            final shared = widget.sharedProfile;
            return shared != null
                ? SharedProfileScreen(username: shared, standalone: true)
                : const HomeShell();
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
            Image.asset('assets/logo_icon.png', height: 88),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const BrandWordmark(size: 30),
            const SizedBox(height: 4),
            Text(
              context.l10n.catalogLoading,
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
                context.l10n.catalogLoadError,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${context.l10n.checkInternetConnection}\n$error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
            ],
          ),
        ),
      ),
    );
  }
}
