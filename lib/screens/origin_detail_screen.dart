import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../widgets/beer_tile.dart';

class OriginDetailScreen extends StatelessWidget {
  final String country;

  const OriginDetailScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final beersOfCountry = beersForCountry(country);

    return Scaffold(
      appBar: AppBar(title: Text(country)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${beersOfCountry.length} bière(s) référencée(s)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...beersOfCountry.map((b) => BeerTile(beer: b)),
        ],
      ),
    );
  }
}
