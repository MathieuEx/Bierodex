import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../data/countries.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import '../theme/brand.dart';
import 'country_map_screen.dart';
import 'search_screen.dart';
import '../l10n/l10n.dart';

/// Style vectoriel gratuit, sans clé API (OpenFreeMap, données
/// OpenStreetMap) : https://openfreemap.org. Le bouton d'attribution natif
/// de MapLibre (`attributionEnabled`, activé par défaut) reste visible,
/// c'est lui qui porte la mention légale requise par la licence OSM.
const _styleUrl = 'https://tiles.openfreemap.org/styles/liberty';

/// Onglet d'accueil : une carte du monde (MapLibre, style vectoriel), avec
/// un repère par pays ayant au moins une brasserie référencée. Toucher un
/// repère ouvre la carte détaillée du pays (`CountryMapScreen`). Les autres
/// sections sont dans la barre de navigation du bas (`HomeShell`).
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;

  /// Un repère par pays, gardé pour retrouver le pays touché (callback
  /// `onCircleTapped`, qui ne donne que l'annotation) et pour recolorer
  /// sans tout recréer quand la progression change.
  final Map<String, Circle> _countryCircles = {};
  final Map<Circle, String> _circleCountries = {};

  static const _continentCenters = {
    'Europe': LatLng(50, 15),
    'Amériques': LatLng(10, -75),
    'Asie': LatLng(28, 95),
    'Afrique': LatLng(2, 20),
    'Océanie': LatLng(-25, 140),
  };

  /// Couleur d'un pays sans aucune bière essayée : un ivoire chaud, lisible
  /// aussi bien sur l'océan que sur le désert, mais volontairement peu
  /// saturé — c'est le contraste avec le cuivre/or des pays explorés qui
  /// porte l'information.
  static const _untouchedColor = Color(0xFFEADFC8);

  @override
  void initState() {
    super.initState();
    BeerCollectionService.instance.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    BeerCollectionService.instance.removeListener(_onProgressChanged);
    _controller?.onCircleTapped.remove(_onCircleTapped);
    super.dispose();
  }

  void _onProgressChanged() => _syncCountryCircles();

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
      return Color.lerp(_untouchedColor, AppColors.amber, ratio / 0.5)!;
    }
    return Color.lerp(AppColors.amber, AppColors.gold, (ratio - 0.5) / 0.5)!;
  }

  /// `CircleOptions.circleColor` attend une chaîne CSS (`#rrggbb`), pas un
  /// `Color` Flutter.
  String _hex(Color color) {
    int channel(double v) => (v * 255).round().clamp(0, 255);
    final r = channel(color.r).toRadixString(16).padLeft(2, '0');
    final g = channel(color.g).toRadixString(16).padLeft(2, '0');
    final b = channel(color.b).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    controller.onCircleTapped.add(_onCircleTapped);
  }

  void _onCircleTapped(Circle circle) {
    final country = _circleCountries[circle];
    if (country != null) _openCountry(country);
  }

  Future<void> _onStyleLoaded() async {
    _styleLoaded = true;
    await _syncCountryCircles();
  }

  /// Crée les repères manquants et recolore les existants selon la
  /// progression courante — plutôt que de tout détruire/recréer à chaque
  /// changement, pour garder la même identité d'annotation (et donc le
  /// bon lien vers le pays au tap).
  Future<void> _syncCountryCircles() async {
    final controller = _controller;
    if (controller == null || !_styleLoaded) return;

    for (final entry in countryMarkers.entries) {
      final country = entry.key;
      final color = _hex(_progressColor(_progressRatio(country)));
      final existing = _countryCircles[country];
      if (existing == null) {
        final circle = await controller.addCircle(
          CircleOptions(
            geometry: LatLng(entry.value.lat, entry.value.lng),
            circleRadius: 8,
            circleColor: color,
            circleOpacity: 1,
            circleStrokeColor: _hex(AppColors.foam),
            circleStrokeWidth: 1.5,
          ),
        );
        _countryCircles[country] = circle;
        _circleCountries[circle] = country;
      } else {
        await controller.updateCircle(
          existing,
          CircleOptions(circleColor: color),
        );
      }
    }
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
    final controller = _controller;
    if (center == null || controller == null) return;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(center, 3.4),
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLibreMap(
              styleString: _styleUrl,
              initialCameraPosition: const CameraPosition(
                target: LatLng(25, 15),
                zoom: 2.2,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(2, 7),
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
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
                      AppColors.night.withValues(alpha: 0.9),
                      AppColors.night.withValues(alpha: 0),
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
              ],
            ),
          ),
        ],
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
              Image.asset('assets/logo_icon.png', height: 28),
              const SizedBox(width: 10),
              const BrandWordmark(size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Material(
            color: AppColors.night.withValues(alpha: 0.72),
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
      color: AppColors.night.withValues(alpha: 0.55),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.amber.withValues(alpha: 0.6)),
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
