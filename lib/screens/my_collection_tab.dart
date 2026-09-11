import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/badges_row.dart';
import '../widgets/beer_tile.dart';

class MyCollectionTab extends StatefulWidget {
  const MyCollectionTab({super.key});

  @override
  State<MyCollectionTab> createState() => _MyCollectionTabState();
}

class _MyCollectionTabState extends State<MyCollectionTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final service = BeerCollectionService.instance;
        final triedIds = service.triedBeerIds.toSet();
        final wishlistIds = service.wishlistBeerIds.toSet();

        final triedBeers = beers.where((b) => triedIds.contains(b.id)).toList()
          ..sort((a, b) {
            final dateA = service.triedAtFor(a.id);
            final dateB = service.triedAtFor(b.id);
            if (dateA != null && dateB != null) return dateB.compareTo(dateA);
            if (dateA != null) return -1;
            if (dateB != null) return 1;
            return a.name.compareTo(b.name);
          });
        final wishlistBeers =
            beers.where((b) => wishlistIds.contains(b.id)).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        return Column(
          children: [
            _StatsHeader(
              triedCount: service.triedCount,
              total: beers.length,
              averageRating: service.averageRating,
              lastTried: findBeerById(service.mostRecentTriedId ?? ''),
              lastTriedAt: service.triedAtFor(service.mostRecentTriedId ?? ''),
            ),
            const BadgesRow(),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.copper,
              indicatorColor: AppColors.copper,
              tabs: [
                Tab(text: 'Bues (${triedBeers.length})'),
                Tab(text: 'À goûter (${wishlistBeers.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  triedBeers.isEmpty
                      ? const _EmptyState(
                          icon: Icons.local_bar_outlined,
                          message: 'Aucune bière essayée pour l\'instant.\n'
                              'Ouvre une bière et coche "J\'ai bu cette bière" '
                              'pour commencer ta collection.',
                        )
                      : ListView(
                          children: triedBeers
                              .map((Beer b) => BeerTile(beer: b))
                              .toList(),
                        ),
                  wishlistBeers.isEmpty
                      ? const _EmptyState(
                          icon: Icons.bookmark_outline,
                          message: 'Aucune bière à goûter pour l\'instant.\n'
                              'Ouvre une bière et coche "À goûter" pour '
                              'la garder sous le coude.',
                        )
                      : ListView(
                          children: wishlistBeers
                              .map((Beer b) => BeerTile(beer: b))
                              .toList(),
                        ),
                ],
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
  final Beer? lastTried;
  final DateTime? lastTriedAt;

  const _StatsHeader({
    required this.triedCount,
    required this.total,
    required this.averageRating,
    required this.lastTried,
    required this.lastTriedAt,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : triedCount / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MA COLLECTION',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            '$triedCount / $total bières essayées',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor:
                  Theme.of(context).colorScheme.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
              valueColor: const AlwaysStoppedAnimation(AppColors.copper),
            ),
          ),
          if (averageRating != null) ...[
            const SizedBox(height: 10),
            Text(
              'Note moyenne donnée : ${averageRating!.toStringAsFixed(1)} / 5',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (lastTried != null) ...[
            const SizedBox(height: 4),
            Text(
              'Dernière dégustation : ${lastTried!.name}'
              '${lastTriedAt != null ? ' · ${_formatDate(lastTriedAt!)}' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
