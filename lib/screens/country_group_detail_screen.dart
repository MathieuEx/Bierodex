import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../widgets/beer_tile.dart';

/// Liste des bières pour un ou plusieurs pays partageant le même contour
/// sur la carte (ex. Royaume-Uni et Écosse), ouvert depuis l'onglet Carte.
class CountryGroupDetailScreen extends StatelessWidget {
  final String title;
  final List<String> countries;

  const CountryGroupDetailScreen({
    super.key,
    required this.title,
    required this.countries,
  });

  @override
  Widget build(BuildContext context) {
    final matchingBeers = beersForCountries(countries);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${matchingBeers.length} bière(s) référencée(s)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...matchingBeers.map((b) => BeerTile(beer: b)),
        ],
      ),
    );
  }
}
