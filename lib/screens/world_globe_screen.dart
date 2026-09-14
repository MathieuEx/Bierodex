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

  /// Couleur d'un pays sans aucune bière essayée : un ivoire chaud, lisible
  /// aussi bien sur l'océan que sur le désert, mais volontairement peu
  /// saturé — c'est le contraste avec le cuivre/or des pays explorés qui
  /// porte l'information.
  static const _untouchedColor = Color(0xFFEADFC8);

  /// Zoom initial du globe. Attention : le package rend la sphère à
  /// `radius * 2^zoom` (voir `RotatingGlobe.convertedRadius`), donc tout
  /// calcul de taille à l'écran doit passer par cette constante — sinon le
  /// cadre et la sphère ne coïncident pas.
  static const _initialZoom = 1.0;

  bool _pointsReady = false;

  @override
  void initState() {
    super.initState();
    BeerCollectionService.instance.addListener(_recolorCountryPoints);
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.04,
      isRotating: true,
      zoom: _initialZoom,
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

  Point _buildCountryPoint(
    String country,
    ({double lat, double lng}) centroid,
  ) {
    final ratio = _progressRatio(country);
    return Point(
      id: country,
      coordinates: GlobeCoordinates(centroid.lat, centroid.lng),
      // `size` est une unité relative : le diamètre dessiné vaut
      // `size / 150` du diamètre du globe (voir `_drawPoint` du package).
      // À 1.7 les repères faisaient 1 % du globe — invisibles. Ici ~3 %
      // pour un pays vierge, ~4,7 % pour un pays entièrement exploré, qui
      // se soulève en plus de la sphère comme une épingle plantée.
      style: PointStyle(
        color: _progressColor(ratio),
        size: 4.5 + ratio * 2.5,
        altitude: ratio * 0.05,
      ),
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
    return Scaffold(
      backgroundColor: AppColors.stout,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                // Le hublot est un cadre fixe à l'écran : la sphère vit
                // derrière et est détourée par lui. Elle peut donc zoomer
                // sans que le cadre ne bouge — contrairement à un anneau
                // collé au bord de la sphère, qui se décale dès qu'on zoome.
                final glassRadius = size.shortestSide / 2 - 12;
                final glassSize = Size.square(glassRadius * 2);
                // La sphère occupe 94 % du verre, pour qu'il reste un liseré
                // d'espace (et d'étoiles) entre son limbe et le laiton.
                final globeRadius =
                    glassRadius * 0.94 / math.pow(2, _initialZoom);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: size,
                      painter: _PanelBackdropPainter(
                        center: Offset(size.width / 2, size.height / 2),
                        glassRadius: glassRadius,
                      ),
                    ),
                    SizedBox.fromSize(
                      size: glassSize,
                      child: ClipOval(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onPanDown: (_) => _controller.stopRotation(),
                              child: FlutterEarthGlobe(
                                radius: globeRadius,
                                controller: _controller,
                              ),
                            ),
                            IgnorePointer(
                              child: CustomPaint(
                                size: glassSize,
                                painter: const _GlassPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: SizedBox.fromSize(
                        size: glassSize,
                        child: const CustomPaint(painter: _BezelPainter()),
                      ),
                    ),
                  ],
                );
              },
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

/// Le panneau sombre dans lequel le hublot est serti : dégradé vertical
/// sobre, plus une lueur ambrée qui déborde derrière le verre, comme la
/// lumière chaude d'une salle de brassage passant autour de l'instrument.
class _PanelBackdropPainter extends CustomPainter {
  final Offset center;
  final double glassRadius;

  const _PanelBackdropPainter({
    required this.center,
    required this.glassRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final panelPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.stoutDim, AppColors.stout],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, panelPaint);

    final bloomRadius = glassRadius * 1.32;
    final bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.20),
          AppColors.copper.withValues(alpha: 0.07),
          AppColors.gold.withValues(alpha: 0),
        ],
        stops: const [0.62, 0.82, 1],
      ).createShader(Rect.fromCircle(center: center, radius: bloomRadius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, bloomRadius, bloomPaint);
  }

  @override
  bool shouldRepaint(covariant _PanelBackdropPainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.glassRadius != glassRadius;
}

/// Ce qui se passe *sous* le verre : l'ombre portée du cerclage sur le
/// bord intérieur, et un reflet diffus en haut à gauche. C'est ce qui
/// donne l'impression de regarder à travers quelque chose plutôt que de
/// voir une image ronde collée à l'écran.
class _GlassPainter extends CustomPainter {
  const _GlassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final innerShadow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.30),
          Colors.black.withValues(alpha: 0.62),
        ],
        stops: const [0.74, 0.93, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, innerShadow);

    final sheenCenter = center + Offset(-radius * 0.34, -radius * 0.42);
    final sheenRect = Rect.fromCenter(
      center: sheenCenter,
      width: radius * 1.25,
      height: radius * 0.78,
    );
    final sheenPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(sheenRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(sheenRect, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) => false;
}

/// Le cerclage en laiton du hublot. Le métal se lit à son dégradé
/// perpendiculaire à la lumière (claire en haut à gauche, sombre en bas à
/// droite) et à son unique reflet spéculaire — pas à un arc-en-ciel de
/// couleurs. Une gorge fine gravée à l'intérieur remplace les rivets, qui
/// se lisaient comme des poussières.
class _BezelPainter extends CustomPainter {
  const _BezelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outerRadius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final band = (outerRadius * 0.075).clamp(13.0, 26.0);
    final midRadius = outerRadius - band / 2;
    final bounds = Rect.fromCircle(center: center, radius: outerRadius);

    // Ombre portée : assoit l'instrument sur le panneau.
    final dropShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = band * 0.9
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, midRadius + band * 0.35, dropShadow);

    // Le laiton lui-même, éclairé du haut-gauche.
    final brass = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = band
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.brassHighlight,
          AppColors.gold,
          AppColors.copper,
          Color(0xFF7A4A20),
          Color(0xFF4A2E14),
        ],
        stops: [0, 0.28, 0.55, 0.8, 1],
      ).createShader(bounds);
    canvas.drawCircle(center, midRadius, brass);

    // Reflet spéculaire : un seul arc vif, en haut à gauche.
    final specular = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = band * 0.3
      ..shader = SweepGradient(
        colors: [
          AppColors.brassHighlight.withValues(alpha: 0),
          AppColors.brassHighlight.withValues(alpha: 0.85),
          AppColors.brassHighlight.withValues(alpha: 0),
          AppColors.brassHighlight.withValues(alpha: 0),
          AppColors.brassHighlight.withValues(alpha: 0.18),
          AppColors.brassHighlight.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.09, 0.2, 0.55, 0.66, 0.78],
        transform: const GradientRotation(math.pi * 1.08),
      ).createShader(bounds);
    canvas.drawCircle(center, midRadius - band * 0.26, specular);

    // Arêtes : une gorge sombre côté verre, un filet clair côté panneau.
    final innerGroove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF3A2410).withValues(alpha: 0.9);
    canvas.drawCircle(center, outerRadius - band + 1, innerGroove);

    final outerEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.brassHighlight.withValues(alpha: 0.35);
    canvas.drawCircle(center, outerRadius - 0.5, outerEdge);
  }

  @override
  bool shouldRepaint(covariant _BezelPainter oldDelegate) => false;
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
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.foam),
          ),
        ),
      ),
    );
  }
}
