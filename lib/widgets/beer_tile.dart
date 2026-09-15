import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../models/beer.dart';
import '../screens/beer_detail_screen.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import '../theme/brand.dart';
import 'star_rating.dart';
import '../l10n/l10n.dart';
import '../data/countries.dart';

/// Une bière, présentée comme une carte du Bierodex : vignette encadrée
/// aux couleurs de sa famille, photo si disponible, degré en pastille.
class BeerTile extends StatelessWidget {
  final Beer beer;

  const BeerTile({super.key, required this.beer});

  @override
  Widget build(BuildContext context) {
    final style = findStyleById(beer.styleId);
    final familyColor = style?.family.color ?? AppColors.walnut;

    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final tried = BeerCollectionService.instance.isTried(beer.id);
        final wishlist = BeerCollectionService.instance.isWishlist(beer.id);
        final rating = BeerCollectionService.instance.ratingFor(beer.id);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: BrandTileSurface(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BeerDetailScreen(beerId: beer.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FamilyThumbnail(
                          color: familyColor,
                          imageUrl: beer.imageUrl,
                          icon: Icons.sports_bar_outlined,
                        ),
                        if (tried || wishlist)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tried ? Icons.check_circle : Icons.bookmark,
                                size: 16,
                                color: tried
                                    ? AppColors.success
                                    : AppColors.gold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            beer.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${beer.brewery} · ${countryName(beer.country)}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (rating != null) ...[
                            const SizedBox(height: 4),
                            StarRating(rating: rating, size: 14),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValuePill(
                      label: '${formatDecimal(beer.abv)}%',
                      color: familyColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
