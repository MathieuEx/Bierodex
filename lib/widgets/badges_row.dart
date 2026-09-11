import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../models/beer_style.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';

/// Rangée de badges de progression : styles goûtés, pays visités, et une
/// jauge par famille de fermentation. Dérivé du catalogue courant et de la
/// collection de l'utilisateur, sans état propre.
class BadgesRow extends StatelessWidget {
  const BadgesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final triedIds = BeerCollectionService.instance.triedBeerIds.toSet();
        final triedBeers =
            beers.where((b) => triedIds.contains(b.id)).toList();

        final triedStyles = <String>{for (final b in triedBeers) b.styleId};
        final triedCountries = <String>{
          for (final b in triedBeers) b.country,
        };

        final badges = <_Badge>[
          _Badge(
            icon: Icons.local_drink_outlined,
            label: 'Styles',
            achieved: triedStyles.length,
            total: beerStyles.length,
            color: AppColors.copper,
          ),
          _Badge(
            icon: Icons.public,
            label: 'Pays',
            achieved: triedCountries.length,
            total: allCountries.length,
            color: AppColors.gold,
          ),
          for (final family in BeerFamily.values)
            _Badge(
              icon: Icons.emoji_events_outlined,
              label: family.shortLabel,
              achieved: triedBeers
                  .where((b) => findStyleById(b.styleId)?.family == family)
                  .length,
              total: beers
                  .where((b) => findStyleById(b.styleId)?.family == family)
                  .length,
              color: family.color,
            ),
        ];

        return SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
          ),
        );
      },
    );
  }
}

class _Badge {
  final IconData icon;
  final String label;
  final int achieved;
  final int total;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.achieved,
    required this.total,
    required this.color,
  });

  double get ratio => total == 0 ? 0 : achieved / total;
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final locked = badge.achieved == 0;
    final color =
        locked ? Theme.of(context).colorScheme.outline : badge.color;

    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(badge.icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '${badge.achieved}/${badge.total}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.label,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: badge.ratio,
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
