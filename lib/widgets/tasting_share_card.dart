import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../models/beer.dart';
import '../models/beer_user_status.dart';
import '../theme/app_theme.dart';
import '../theme/brand.dart';
import 'globe_painter.dart';
import '../l10n/l10n.dart';
import '../data/countries.dart';

/// Format de l'image partagée : 4:5, le format portrait des publications
/// Instagram, rendu à 1080 × 1350 px (voir `ShareTastingCardScreen`).
const tastingShareCardSize = Size(360, 450);

/// Carte de dégustation à poster sur les réseaux : la bière, la note, les
/// arômes et un globe pointant la brasserie. Couleurs fixes (pas celles du
/// thème) : l'image doit être identique en mode clair et sombre.
class TastingShareCard extends StatelessWidget {
  final Beer beer;
  final BeerUserStatus status;
  final String? username;

  /// Brasseries de toutes les bières goûtées, en doré sur le globe.
  final Set<String> triedBreweries;

  const TastingShareCard({
    super.key,
    required this.beer,
    required this.status,
    this.username,
    this.triedBreweries = const {},
  });

  @override
  Widget build(BuildContext context) {
    final style = findStyleById(beer.styleId);
    final location = breweryLocations[beer.brewery];
    final highlight = location == null
        ? null
        : (lat: location.lat, lng: location.lng);
    // Légèrement décalé vers le sud-ouest du repère : le globe paraît
    // incliné plutôt que parfaitement centré.
    final center = highlight == null
        ? (lat: 30.0, lng: 10.0)
        : (
            lat: (highlight.lat - 12).clamp(-60.0, 60.0),
            lng: highlight.lng - 18,
          );

    const display = TextStyle(
      fontFamily: AppTheme.displayFont,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w900,
      color: AppColors.foam,
      height: 1,
    );
    const body = TextStyle(
      fontFamily: AppTheme.bodyFont,
      color: AppColors.foamSoft,
    );
    final aromas = [
      for (final id in status.aromas.take(4))
        if (tastingAromas[id] != null) tastingAromas[id]!,
    ];

    return SizedBox.fromSize(
      size: tastingShareCardSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF123A66), AppColors.night],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -70,
              top: 26,
              width: 270,
              height: 270,
              child: CustomPaint(
                painter: GlobePainter(
                  center: center,
                  highlight: highlight,
                  knownPoints: [
                    for (final l in breweryLocations.values)
                      (lat: l.lat, lng: l.lng),
                  ],
                  triedPoints: [
                    for (final brewery in triedBreweries)
                      if (breweryLocations[brewery] case final l?)
                        (lat: l.lat, lng: l.lng),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo_icon.png', height: 22),
                      const SizedBox(width: 8),
                      const BrandWordmark(size: 16),
                    ],
                  ),
                  const Spacer(),
                  if (location != null && location.city.isNotEmpty)
                    Text(
                      '${location.city.toUpperCase()} · ${countryName(beer.country).toUpperCase()}',
                      style: body.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.amber,
                      ),
                    )
                  else
                    Text(
                      countryName(beer.country).toUpperCase(),
                      style: body.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.amber,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    beer.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: display.copyWith(
                      fontSize: beer.name.length > 22 ? 34 : 44,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    beer.brewery,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foam,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (style != null) style.name,
                      '${formatDecimal(beer.abv)} %',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        Icon(
                          i < (status.rating ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 28,
                          color: i < (status.rating ?? 0)
                              ? AppColors.gold
                              : AppColors.outlineDark,
                        ),
                    ],
                  ),
                  if (aromas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final aroma in aromas)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              child: Text(
                                aroma,
                                style: body.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foam,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(height: 1, color: AppColors.outlineDark),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          status.triedAt != null
                              ? context.l10n.tastedOn(
                                  formatDate(status.triedAt!),
                                )
                              : context.l10n.tasted,
                          style: body.copyWith(fontSize: 11),
                        ),
                      ),
                      if (username != null)
                        Text(
                          '@$username',
                          style: body.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.foam,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brasseries des bières marquées comme bues, à passer à [TastingShareCard].
Set<String> triedBreweriesFrom(Iterable<String> triedBeerIds) => {
  for (final id in triedBeerIds)
    if (findBeerById(id) case final beer?) beer.brewery,
};
