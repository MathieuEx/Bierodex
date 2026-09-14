import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

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

/// Écran unique de l'app : une carte du monde (tuiles OpenStreetMap), avec
/// un repère par pays ayant au moins une brasserie référencée. Toucher un
/// repère ouvre la carte détaillée du pays (`CountryMapScreen`). Styles,
/// recherche, collection et compte restent accessibles via les icônes en
/// haut de l'écran.
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
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
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            height: 130,
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
                  onScan: _openScanner,
                  onStyles: _openStyles,
                  onCollection: _openCollection,
                  onAccount: _openAccount,
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
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 0),
      child: Row(
        children: [
          const Icon(Icons.sports_bar, color: AppColors.copper, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'BIERODEX',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.foam,
                letterSpacing: 1.4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _MapIconButton(
            icon: Icons.search,
            tooltip: 'Rechercher',
            onPressed: onSearch,
          ),
          _MapIconButton(
            icon: Icons.qr_code_scanner,
            tooltip: 'Scanner une bière',
            onPressed: onScan,
          ),
          _MapIconButton(
            icon: Icons.local_drink_outlined,
            tooltip: 'Styles',
            onPressed: onStyles,
          ),
          _MapIconButton(
            icon: Icons.local_bar_outlined,
            tooltip: 'Ma collection',
            onPressed: onCollection,
          ),
          ListenableBuilder(
            listenable: AuthService.instance,
            builder: (context, _) {
              final signedIn = AuthService.instance.isSignedIn;
              return _MapIconButton(
                icon: signedIn ? Icons.person : Icons.person_outline,
                tooltip: 'Mon compte',
                onPressed: onAccount,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Bouton d'icône posé directement sur la carte : le voile en haut d'écran
/// suffit à sa lisibilité, pas besoin d'un fond de bouton standard.
class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MapIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: AppColors.foam,
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
              label: continent,
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
