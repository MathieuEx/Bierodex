import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer.dart';
import '../services/beer_collection_service.dart';
import '../theme/brand.dart';
import '../widgets/badges_row.dart';
import '../widgets/beer_tile.dart';
import 'stats_screen.dart';
import '../l10n/l10n.dart';

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
              tabs: [
                Tab(
                  text: '${context.l10n.tastedSection} (${triedBeers.length})',
                ),
                Tab(
                  text:
                      '${context.l10n.wishlistLabel} (${wishlistBeers.length})',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  triedBeers.isEmpty
                      ? _EmptyState(
                          icon: Icons.local_bar_outlined,
                          message: context.l10n.collectionEmptyTasted,
                        )
                      : ListView(
                          children: triedBeers
                              .map((Beer b) => BeerTile(beer: b))
                              .toList(),
                        ),
                  wishlistBeers.isEmpty
                      ? _EmptyState(
                          icon: Icons.bookmark_outline,
                          message: context.l10n.collectionEmptyWishlist,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: BrandFrame(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.collectionTitle.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            GradientText(
              context.l10n.collectionProgress(triedCount, total),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            GradientProgressBar(value: ratio),
            if (averageRating != null) ...[
              const SizedBox(height: 10),
              Text(
                context.l10n.collectionAverageRating(
                  formatDecimal(averageRating!),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (lastTried != null) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.collectionLastTasting(
                  lastTriedAt != null
                      ? '${lastTried!.name} · ${formatDate(lastTriedAt!)}'
                      : lastTried!.name,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.insights_outlined, size: 18),
              label: Text(context.l10n.collectionStatsButton),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
            ),
          ],
        ),
      ),
    );
  }
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
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
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
