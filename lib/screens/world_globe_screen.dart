import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';

import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../services/auth_service.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import 'account_screen.dart';
import 'barcode_scanner_screen.dart';
import 'country_map_screen.dart';
import 'my_collection_tab.dart';
import 'search_screen.dart';
import 'styles_tab.dart';

/// Écran unique de l'app : un globe 3D qu'on fait tourner et sur lequel on
/// zoome pour repérer les brasseries, référencées à leur position réelle.
/// Toucher un repère ouvre la liste des bières de cette brasserie. Styles,
/// recherche, collection et compte restent accessibles via les icônes en
/// haut de l'écran.
class WorldGlobeScreen extends StatefulWidget {
  const WorldGlobeScreen({super.key});

  @override
  State<WorldGlobeScreen> createState() => _WorldGlobeScreenState();
}

class _WorldGlobeScreenState extends State<WorldGlobeScreen> {
  late final FlutterEarthGlobeController _controller;

  static const _continentCenters = {
    'Europe': GlobeCoordinates(50, 15),
    'Amériques': GlobeCoordinates(10, -75),
    'Asie': GlobeCoordinates(28, 95),
    'Afrique': GlobeCoordinates(2, 20),
    'Océanie': GlobeCoordinates(-25, 140),
  };

  /// Couleur d'un pays sans aucune bière essayée (gris neutre, distinct du
  /// cuivre/or utilisés pour la progression).
  static const _untouchedColor = Color(0xFF8A8272);

  bool _pointsReady = false;

  @override
  void initState() {
    super.initState();
    BeerCollectionService.instance.addListener(_recolorCountryPoints);
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.04,
      isRotating: true,
      zoom: 1,
      minZoom: 0.5,
      maxZoom: 4,
      zoomSensitivity: 0.35,
      surface: const AssetImage('assets/globe/2k_earth-day.jpg'),
      background: const AssetImage('assets/globe/2k_stars.jpg'),
      isBackgroundFollowingSphereRotation: true,
      showAtmosphere: true,
      atmosphereColor: AppColors.gold,
      atmosphereOpacity: 0.35,
    )..onLoaded = _addCountryPoints;
  }

  @override
  void dispose() {
    BeerCollectionService.instance.removeListener(_recolorCountryPoints);
    super.dispose();
  }

  void _addCountryPoints() {
    for (final entry in countryMarkers.entries) {
      _controller.addPoint(_buildCountryPoint(entry.key, entry.value));
    }
    _pointsReady = true;
  }

  /// Recolore chaque marqueur pays selon la progression courante. Le
  /// contrôleur n'expose pas de mise à jour de style fiable (son
  /// `updatePoint` ne réapplique pas le style) : on retire et rajoute
  /// chaque point, ce qui reste bon marché vu leur nombre.
  void _recolorCountryPoints() {
    if (!_pointsReady) return;
    for (final entry in countryMarkers.entries) {
      _controller.removePoint(entry.key);
      _controller.addPoint(_buildCountryPoint(entry.key, entry.value));
    }
  }

  Point _buildCountryPoint(String country, ({double lat, double lng}) centroid) {
    return Point(
      id: country,
      coordinates: GlobeCoordinates(centroid.lat, centroid.lng),
      style: PointStyle(color: _progressColor(country), size: 1.6),
      onTap: () => _openCountry(country, centroid),
    );
  }

  /// Gris pour un pays dont aucune bière n'a été goûtée, puis un dégradé
  /// cuivre → or à mesure que la proportion de bières essayées dans ce
  /// pays augmente : le globe raconte la progression du carnet, plutôt
  /// que de n'être qu'une carte statique.
  Color _progressColor(String country) {
    final countryBeers = beersForCountry(country);
    if (countryBeers.isEmpty) return _untouchedColor;
    final tried = countryBeers
        .where((b) => BeerCollectionService.instance.isTried(b.id))
        .length;
    final ratio = tried / countryBeers.length;
    if (ratio <= 0) return _untouchedColor;
    if (ratio < 0.5) {
      return Color.lerp(_untouchedColor, AppColors.copper, ratio / 0.5)!;
    }
    return Color.lerp(AppColors.copper, AppColors.gold, (ratio - 0.5) / 0.5)!;
  }

  void _openCountry(String country, ({double lat, double lng}) centroid) {
    _controller.stopRotation();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => CountryMapScreen(country: country),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.97, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _goToContinent(String continent) {
    final coordinates = _continentCenters[continent];
    if (coordinates == null) return;
    _controller.stopRotation();
    _controller.focusOnCoordinates(
      coordinates,
      animate: true,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
    _controller.setZoom(1.6);
  }

  void _openStyles() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Styles de bières')),
          body: const StylesTab(),
        ),
      ),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
  }

  void _openCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Ma collection')),
          body: const MyCollectionTab(),
        ),
      ),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stout,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    AppColors.stoutDim,
                    AppColors.stout,
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final radius = constraints.biggest.shortestSide / 2 * 0.48;
                  return GestureDetector(
                    onPanDown: (_) => _controller.stopRotation(),
                    child: FlutterEarthGlobe(
                      radius: radius,
                      controller: _controller,
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  onSearch: () => showSearch(
                    context: context,
                    delegate: BeerSearchDelegate(),
                  ),
                  onScan: _openScanner,
                  onStyles: _openStyles,
                  onCollection: _openCollection,
                  onAccount: _openAccount,
                ),
                const SizedBox(height: 10),
                _ContinentChips(onContinent: _goToContinent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onScan;
  final VoidCallback onStyles;
  final VoidCallback onCollection;
  final VoidCallback onAccount;

  const _TopBar({
    required this.onSearch,
    required this.onScan,
    required this.onStyles,
    required this.onCollection,
    required this.onAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.sports_bar, color: AppColors.copper),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BIERODEX',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            letterSpacing: 1.2,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _Pill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Rechercher',
                  onPressed: onSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scanner une bière',
                  onPressed: onScan,
                ),
                IconButton(
                  icon: const Icon(Icons.local_drink_outlined),
                  tooltip: 'Styles',
                  onPressed: onStyles,
                ),
                IconButton(
                  icon: const Icon(Icons.local_bar_outlined),
                  tooltip: 'Ma collection',
                  onPressed: onCollection,
                ),
                ListenableBuilder(
                  listenable: AuthService.instance,
                  builder: (context, _) {
                    final signedIn = AuthService.instance.isSignedIn;
                    return IconButton(
                      icon:
                          Icon(signedIn ? Icons.person : Icons.person_outline),
                      tooltip: 'Mon compte',
                      onPressed: onAccount,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinentChips extends StatelessWidget {
  final ValueChanged<String> onContinent;

  const _ContinentChips({required this.onContinent});

  static const _continents = [
    'Europe',
    'Amériques',
    'Asie',
    'Afrique',
    'Océanie',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final continent in _continents) ...[
            _Pill(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onContinent(continent),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    continent,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;

  const _Pill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(24),
      child: child,
    );
  }
}
