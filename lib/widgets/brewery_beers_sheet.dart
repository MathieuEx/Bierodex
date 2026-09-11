import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/brewery_location.dart';
import '../theme/app_theme.dart';
import 'beer_tile.dart';

/// Fiche "brasserie" : nom, adresse et liste des bières référencées.
/// Utilisée à la fois depuis le globe et depuis la carte détaillée d'un pays.
void showBreweryBeersSheet(
  BuildContext context,
  String brewery,
  BreweryLocation location,
) {
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
                      const Icon(Icons.location_on, color: AppColors.copper),
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
