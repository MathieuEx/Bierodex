import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../widgets/beer_tile.dart';

class StyleDetailScreen extends StatelessWidget {
  final String styleId;

  const StyleDetailScreen({super.key, required this.styleId});

  @override
  Widget build(BuildContext context) {
    final style = findStyleById(styleId);
    if (style == null) {
      return const Scaffold(body: Center(child: Text('Style introuvable')));
    }
    final beersOfStyle = beersForStyle(styleId);
    final color = style.family.color;

    return Scaffold(
      appBar: AppBar(title: Text(style.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            width: double.infinity,
            color: color.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(style.family.label)),
                    Chip(label: Text('Origine : ${style.origin}')),
                    Chip(label: Text('ABV : ${style.abvRange}')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  style.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Exemples de bières',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (beersOfStyle.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Aucun exemple pour ce style pour le moment.'),
            )
          else
            ...beersOfStyle.map((b) => BeerTile(beer: b)),
        ],
      ),
    );
  }
}
