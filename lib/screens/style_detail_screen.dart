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
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border(bottom: BorderSide(color: color, width: 3)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(style.family.label),
                      backgroundColor: color.withValues(alpha: 0.16),
                      labelStyle: TextStyle(color: color),
                      side: BorderSide(color: color.withValues(alpha: 0.4)),
                    ),
                    Chip(label: Text('Origine : ${style.origin}')),
                    Chip(label: Text('ABV : ${style.abvRange}')),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  style.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
            child: Text(
              'EXEMPLES DE BIÈRES',
              style: Theme.of(context).textTheme.titleSmall,
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
