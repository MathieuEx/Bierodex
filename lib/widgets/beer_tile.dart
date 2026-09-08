import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../models/beer.dart';
import '../screens/beer_detail_screen.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';

/// Une bière, présentée comme une fiche de carnet : liseré coloré par
/// famille sur le bord gauche, photo si disponible, sinon initiale stylisée.
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
        final rating = BeerCollectionService.instance.ratingFor(beer.id);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BeerDetailScreen(beerId: beer.id),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: familyColor, width: 4),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: familyColor.withValues(alpha: 0.16),
                          foregroundColor: familyColor,
                          backgroundImage: beer.imageUrl != null
                              ? NetworkImage(beer.imageUrl!)
                              : null,
                          child: beer.imageUrl == null
                              ? const Icon(Icons.sports_bar_outlined)
                              : null,
                        ),
                        if (tried)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.success,
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
                            '${beer.brewery} · ${beer.country}',
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
                    Text(
                      '${beer.abv.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: familyColor,
                          ),
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
