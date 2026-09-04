import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer.dart';
import '../services/beer_collection_service.dart';
import '../widgets/beer_tile.dart';

class MyCollectionTab extends StatelessWidget {
  const MyCollectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final service = BeerCollectionService.instance;
        final triedIds = service.triedBeerIds.toSet();
        final triedBeers = beers.where((b) => triedIds.contains(b.id)).toList()
          ..sort((a, b) {
            final ratingA = service.ratingFor(a.id) ?? -1;
            final ratingB = service.ratingFor(b.id) ?? -1;
            if (ratingA != ratingB) return ratingB.compareTo(ratingA);
            return a.name.compareTo(b.name);
          });

        return Column(
          children: [
            _StatsHeader(
              triedCount: service.triedCount,
              total: beers.length,
              averageRating: service.averageRating,
            ),
            Expanded(
              child: triedBeers.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      children: triedBeers
                          .map((Beer b) => BeerTile(beer: b))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int triedCount;
  final int total;
  final double? averageRating;

  const _StatsHeader({
    required this.triedCount,
    required this.total,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : triedCount / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$triedCount / $total bières essayées',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: ratio, minHeight: 6),
          ),
          if (averageRating != null) ...[
            const SizedBox(height: 8),
            Text('Note moyenne donnée : ${averageRating!.toStringAsFixed(1)} / 5'),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_bar_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune bière essayée pour l\'instant.\n'
              'Ouvre une bière et coche "J\'ai bu cette bière" '
              'pour commencer ta collection.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
