import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../models/beer.dart';
import '../screens/beer_detail_screen.dart';
import '../services/beer_collection_service.dart';
import 'star_rating.dart';

class BeerTile extends StatelessWidget {
  final Beer beer;

  const BeerTile({super.key, required this.beer});

  @override
  Widget build(BuildContext context) {
    final style = findStyleById(beer.styleId);
    final familyColor = style?.family.color ?? Colors.brown;

    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final tried = BeerCollectionService.instance.isTried(beer.id);
        final rating = BeerCollectionService.instance.ratingFor(beer.id);

        return ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundColor: familyColor.withValues(alpha: 0.15),
                foregroundColor: familyColor,
                child: const Icon(Icons.sports_bar_outlined),
              ),
              if (tried)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green[600],
                    ),
                  ),
                ),
            ],
          ),
          title: Text(beer.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${beer.brewery} · ${beer.country}'),
              if (rating != null) ...[
                const SizedBox(height: 2),
                StarRating(rating: rating, size: 14),
              ],
            ],
          ),
          isThreeLine: rating != null,
          trailing: Text(
            '${beer.abv.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BeerDetailScreen(beerId: beer.id),
              ),
            );
          },
        );
      },
    );
  }
}
