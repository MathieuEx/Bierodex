import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';

import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../models/brewery_location.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/beer_tile.dart';
import 'account_screen.dart';
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

  @override
  void initState() {
    super.initState();
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
    )..onLoaded = _addBreweryPoints;
  }

  void _addBreweryPoints() {
    for (final entry in breweryLocations.entries) {
      final brewery = entry.key;
      final location = entry.value;
      _controller.addPoint(
        Point(
          id: brewery,
          coordinates: GlobeCoordinates(location.lat, location.lng),
          style: const PointStyle(color: AppColors.copper, size: 1),
          onTap: () => _showBreweryBeers(brewery, location),
        ),
      );
    }
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

  void _showBreweryBeers(String brewery, BreweryLocation location) {
    final breweryBeers = beersForBrewery(brewery);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.copper,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brewery,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                location.address.isNotEmpty
                                    ? location.address
                                    : location.city,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      children:
                          breweryBeers.map((b) => BeerTile(beer: b)).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                  final radius = constraints.biggest.shortestSide / 2 * 0.62;
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
  final VoidCallback onStyles;
  final VoidCallback onCollection;
  final VoidCallback onAccount;

  const _TopBar({
    required this.onSearch,
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
