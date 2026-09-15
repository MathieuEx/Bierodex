import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../data/countries.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import 'country_map_screen.dart';
import 'search_screen.dart';
import '../l10n/l10n.dart';

/// Onglet d'accueil : une carte du monde (tuiles OpenStreetMap), avec un
/// repère par pays ayant au moins une brasserie référencée. Toucher un
/// repère ouvre la carte détaillée du pays (`CountryMapScreen`). Les autres
/// sections sont dans la barre de navigation du bas (`HomeShell`).
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  final _mapController = MapController();

  static const _continentCenters = {
    'Europe': ll.LatLng(50, 15),
    'Amériques': ll.LatLng(10, -75),
    'Asie': ll.LatLng(28, 95),
    'Afrique': ll.LatLng(2, 20),
    'Océanie': ll.LatLng(-25, 140),
  };

  /// Couleur d'un pays sans aucune bière essayée : un ivoire chaud, lisible
  /// aussi bien sur l'océan que sur le désert, mais volontairement peu
  /// saturé — c'est le contraste avec le cuivre/or des pays explorés qui
  /// porte l'information.
  static const _untouchedColor = Color(0xFFEADFC8);

  @override
  void initState() {
    super.initState();
    // Le nombre/la couleur des repères dépend de la progression : un
    // `setState` suffit à reconstruire la liste de marqueurs au prochain
    // build.
    BeerCollectionService.instance.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    BeerCollectionService.instance.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() => setState(() {});

  double _progressRatio(String country) {
    final countryBeers = beersForCountry(country);
    if (countryBeers.isEmpty) return 0;
    final tried = countryBeers
        .where((b) => BeerCollectionService.instance.isTried(b.id))
        .length;
    return tried / countryBeers.length;
  }

  /// Gris pour un pays dont aucune bière n'a été goûtée, puis un dégradé
  /// cuivre → or à mesure que la proportion de bières essayées dans ce
  /// pays augmente : la carte raconte la progression du carnet, plutôt que
  /// de n'être qu'un plan statique.
  Color _progressColor(double ratio) {
    if (ratio <= 0) return _untouchedColor;
    if (ratio < 0.5) {
      return Color.lerp(_untouchedColor, AppColors.copper, ratio / 0.5)!;
    }
    return Color.lerp(AppColors.copper, AppColors.gold, (ratio - 0.5) / 0.5)!;
  }

  void _openCountry(String country) {
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
    final center = _continentCenters[continent];
    if (center == null) return;
    _mapController.move(center, 3.4);
  }

  @override
  Widget build(BuildContext context) {
    final markers = [
      for (final entry in countryMarkers.entries)
        Marker(
          point: ll.LatLng(entry.value.lat, entry.value.lng),
          width: 26,
          height: 26,
          child: GestureDetector(
            onTap: () => _openCountry(entry.key),
            child: _CountryDot(
              color: _progressColor(_progressRatio(entry.key)),
            ),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.stout,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: ll.LatLng(25, 15),
                initialZoom: 2.2,
                minZoom: 2,
                maxZoom: 7,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bierodex.app',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          // Voile sombre en haut d'écran : garantit la lisibilité du bandeau
          // (icônes/texte) quelle que soit la clarté des tuiles en dessous.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.stout.withValues(alpha: 0.9),
                      AppColors.stout.withValues(alpha: 0),
                    ],
                  ),
                ),
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
                ),
                const Spacer(),
                _ContinentChips(onContinent: _goToContinent),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: _AttributionBadge(),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Repère pays : un point dont la taille et la couleur suivent la
/// progression (voir `_progressColor`), avec un liseré clair pour rester
/// visible aussi bien sur l'océan que sur les terres.
class _CountryDot extends StatelessWidget {
  final Color color;

  const _CountryDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: AppColors.foam, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributionBadge extends StatelessWidget {
  const _AttributionBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          '© OpenStreetMap contributors',
          style: TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ),
    );
  }
}

/// Bandeau : le nom de l'app et une barre de recherche pleine largeur.
/// La navigation vers les autres sections vit dans la barre du bas
/// (`HomeShell`), la carte ne garde que ce qui la concerne.
class _TopBar extends StatelessWidget {
  final VoidCallback onSearch;

  const _TopBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_bar, color: AppColors.copper, size: 22),
              const SizedBox(width: 10),
              Text(
                'BIERODEX',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.foam,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Material(
            color: AppColors.stout.withValues(alpha: 0.72),
            shape: StadiumBorder(
              side: BorderSide(color: AppColors.foam.withValues(alpha: 0.18)),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onSearch,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.foam, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.searchBeerHint,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.foamSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final continent in _continents) ...[
            _ContinentChip(
              label: continentName(continent),
              onTap: () => onContinent(continent),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Étiquette légère (contour cuivre, fond translucide) plutôt qu'une carte
/// pleine : la carte reste visible derrière, la barre ne fait pas écran.
class _ContinentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ContinentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.stout.withValues(alpha: 0.55),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.copper.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.foam),
          ),
        ),
      ),
    );
  }
}
