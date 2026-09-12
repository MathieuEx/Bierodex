import 'dart:math' as math;

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

/// Écran unique de l'app : le globe est vu comme à travers le hublot en
/// laiton d'une brasserie — on le fait tourner et on zoome dessus pour
/// repérer les brasseries, référencées à leur position réelle. Toucher un
/// repère ouvre la liste des bières de cette brasserie. Styles, recherche,
/// collection et compte restent accessibles via les icônes en haut de
/// l'écran.
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
    final ratio = _progressRatio(country);
    final color = _progressColor(ratio);
    return Point(
      id: country,
      coordinates: GlobeCoordinates(centroid.lat, centroid.lng),
      // La sphère elle-même ne sait dessiner qu'un disque plat : on le
      // laisse transparent (taille conservée pour la zone de tap) et on
      // pose un vrai repère "épingle" par-dessus via labelBuilder. Les pays
      // bien explorés se soulèvent aussi de la sphère (altitude), comme une
      // épingle plantée sur une carte.
      style: PointStyle(
        color: color.withValues(alpha: 0),
        size: 1.7 + ratio * 0.7,
        altitude: ratio * 0.045,
      ),
      label: country,
      isLabelVisible: true,
      labelBuilder: (context, point, isHovering, isVisible) =>
          _CountryMarker(color: color),
      onTap: () => _openCountry(country, centroid),
    );
  }

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
  /// pays augmente : le globe raconte la progression du carnet, plutôt
  /// que de n'être qu'une carte statique.
  Color _progressColor(double ratio) {
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
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [AppColors.stoutDim, AppColors.stout],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final isPhone = size.shortestSide < 600;
                  final radius =
                      size.shortestSide / 2 * (isPhone ? 0.60 : 0.50);
                  final center = Offset(size.width / 2, size.height / 2);
                  return Stack(
                    children: [
                      CustomPaint(
                        size: size,
                        painter: _GlobeAuraPainter(
                          center: center,
                          baseRadius: radius,
                        ),
                      ),
                      GestureDetector(
                        onPanDown: (_) => _controller.stopRotation(),
                        child: FlutterEarthGlobe(
                          radius: radius,
                          controller: _controller,
                        ),
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          size: size,
                          painter: _PortholeFramePainter(
                            center: center,
                            radius: radius * 1.05,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Voile sombre en haut d'écran : garantit la lisibilité du bandeau
          // (icônes/texte) quel que soit ce qu'il y a derrière (étoiles,
          // continent clair...), sans avoir besoin d'une carte opaque.
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
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Repère "épingle" d'un pays sur le globe : un badge circulaire cuivré/or
/// (selon la progression) surmonté d'une chope, avec une pointe basse
/// ancrée aux coordonnées géographiques — remplace le simple point de
/// couleur plat que dessine nativement la sphère.
class _CountryMarker extends StatelessWidget {
  static const double width = 26;
  static const double height = 34;

  final Color color;

  const _CountryMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 18,
            child: Transform.rotate(
              angle: 0.785398, // 45°
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.foam, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_bar,
              size: 13,
              color: AppColors.foam,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lueur ambrée basse (comme la lumière traversant un verre plein) et
/// quelques anneaux concentriques très ténus autour du globe, à la manière
/// d'ondes de sonar qui repèrent les brasseries. Remplace le halo
/// générique par quelque chose de propre au sujet — pas une décoration
/// gratuite.
class _GlobeAuraPainter extends CustomPainter {
  final Offset center;
  final double baseRadius;

  const _GlobeAuraPainter({required this.center, required this.baseRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final glowRadius = baseRadius * 1.85;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.14),
          AppColors.gold.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36);
    canvas.drawCircle(center, glowRadius, glowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      ringPaint.color = AppColors.copper.withValues(alpha: 0.09 / i);
      canvas.drawCircle(center, baseRadius * (1.16 + i * 0.15), ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlobeAuraPainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.baseRadius != baseRadius;
}

/// Cerclage en laiton autour du globe, comme le hublot d'une cuve de
/// brasserie : anneau brossé (dégradé balayant), reflet intérieur et
/// petits rivets — le détail qui rend cet écran reconnaissable au premier
/// coup d'œil, plutôt qu'une sphère nue flottant dans un dégradé.
class _PortholeFramePainter extends CustomPainter {
  final Offset center;
  final double radius;

  const _PortholeFramePainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    final ringRect = Rect.fromCircle(center: center, radius: radius);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const SweepGradient(
        colors: [
          AppColors.copper,
          AppColors.gold,
          AppColors.brassHighlight,
          AppColors.gold,
          AppColors.copper,
          AppColors.walnut,
          AppColors.copper,
        ],
        transform: GradientRotation(-1.1),
      ).createShader(ringRect);
    canvas.drawCircle(center, radius, ringPaint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.brassHighlight.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius - strokeWidth / 2 - 2, highlightPaint);

    final rivetShadow = Paint()..color = const Color(0xFF4A2F16);
    final rivetHighlight =
        Paint()..color = AppColors.brassHighlight.withValues(alpha: 0.85);
    const rivetCount = 14;
    for (var i = 0; i < rivetCount; i++) {
      final angle = (2 * math.pi / rivetCount) * i;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(position, 3.2, rivetShadow);
      canvas.drawCircle(position + const Offset(-0.7, -0.7), 1.0, rivetHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant _PortholeFramePainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.radius != radius;
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
          _GlobeIconButton(
            icon: Icons.search,
            tooltip: 'Rechercher',
            onPressed: onSearch,
          ),
          _GlobeIconButton(
            icon: Icons.qr_code_scanner,
            tooltip: 'Scanner une bière',
            onPressed: onScan,
          ),
          _GlobeIconButton(
            icon: Icons.local_drink_outlined,
            tooltip: 'Styles',
            onPressed: onStyles,
          ),
          _GlobeIconButton(
            icon: Icons.local_bar_outlined,
            tooltip: 'Ma collection',
            onPressed: onCollection,
          ),
          ListenableBuilder(
            listenable: AuthService.instance,
            builder: (context, _) {
              final signedIn = AuthService.instance.isSignedIn;
              return _GlobeIconButton(
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

/// Bouton d'icône sobre posé directement sur le globe (pas de carte, pas de
/// halo) : le voile en haut d'écran suffit à sa lisibilité. Un rivet du
/// hublot, pas un composant standard.
class _GlobeIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _GlobeIconButton({
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
/// pleine : le globe reste visible derrière, la barre ne fait pas écran.
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.foam,
                ),
          ),
        ),
      ),
    );
  }
}
