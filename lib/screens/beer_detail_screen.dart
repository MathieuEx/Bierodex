import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../screens/style_detail_screen.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';

class BeerDetailScreen extends StatelessWidget {
  final String beerId;

  const BeerDetailScreen({super.key, required this.beerId});

  @override
  Widget build(BuildContext context) {
    final beer = findBeerById(beerId);
    if (beer == null) {
      return const Scaffold(body: Center(child: Text('Bière introuvable')));
    }
    final style = findStyleById(beer.styleId);
    final color = style?.family.color ?? AppColors.walnut;

    return Scaffold(
      appBar: AppBar(title: Text(beer.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (beer.imageUrl != null)
            _BeerPhoto(imageUrl: beer.imageUrl!, color: color)
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: color, width: 4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.2),
                    foregroundColor: color,
                    child: const Icon(Icons.sports_bar_outlined, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beer.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text('${beer.brewery} · ${beer.country}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (beer.imageUrl != null) ...[
            Text(
              beer.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text('${beer.brewery} · ${beer.country}'),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${beer.abv.toStringAsFixed(1)}% ABV')),
              if (style != null)
                Chip(
                  label: Text(style.family.label),
                  backgroundColor: color.withValues(alpha: 0.16),
                  labelStyle: TextStyle(color: color),
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(beer.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          _MyOpinionCard(beerId: beer.id),
          const SizedBox(height: 16),
          if (style != null)
            Card(
              child: ListTile(
                leading: Icon(Icons.local_drink_outlined, color: color),
                title: Text('Style : ${style.name}'),
                subtitle: Text(style.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StyleDetailScreen(styleId: style.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BeerPhoto extends StatelessWidget {
  final String imageUrl;
  final Color color;

  const _BeerPhoto({required this.imageUrl, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 260,
            color: color.withValues(alpha: 0.08),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stack) => Center(
                child: Icon(
                  Icons.sports_bar_outlined,
                  size: 48,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Photo : Open Food Facts (CC BY-SA)',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _MyOpinionCard extends StatelessWidget {
  final String beerId;

  const _MyOpinionCard({required this.beerId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final service = BeerCollectionService.instance;
        final tried = service.isTried(beerId);
        final rating = service.ratingFor(beerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon avis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('J\'ai bu cette bière'),
                  value: tried,
                  onChanged: (value) {
                    service.setTried(beerId, value);
                    if (!value) service.setRating(beerId, null);
                  },
                ),
                if (tried) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Ma note :'),
                      const SizedBox(width: 8),
                      StarRating(
                        rating: rating,
                        size: 28,
                        onChanged: (value) => service.setRating(beerId, value),
                      ),
                      if (rating != null)
                        IconButton(
                          tooltip: 'Effacer la note',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => service.setRating(beerId, null),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
