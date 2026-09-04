import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../screens/style_detail_screen.dart';

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
    final color = style?.family.color ?? Colors.brown;

    return Scaffold(
      appBar: AppBar(title: Text(beer.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${beer.abv.toStringAsFixed(1)}% ABV')),
              if (style != null) Chip(label: Text(style.family.label)),
            ],
          ),
          const SizedBox(height: 16),
          Text(beer.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          if (style != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_drink_outlined),
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
