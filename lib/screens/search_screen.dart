import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../models/beer.dart';
import '../widgets/beer_tile.dart';

class BeerSearchDelegate extends SearchDelegate<void> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _SearchResults(query: query);

  @override
  Widget buildSuggestions(BuildContext context) =>
      _SearchResults(query: query);
}

class _SearchResults extends StatelessWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Cherche une bière, une brasserie, un style ou un pays'),
      );
    }
    final q = query.trim().toLowerCase();
    final results = beers.where((Beer b) {
      final style = findStyleById(b.styleId);
      return b.name.toLowerCase().contains(q) ||
          b.brewery.toLowerCase().contains(q) ||
          b.country.toLowerCase().contains(q) ||
          (style?.name.toLowerCase().contains(q) ?? false);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Aucun résultat'));
    }
    return ListView(
      children: results.map((b) => BeerTile(beer: b)).toList(),
    );
  }
}
