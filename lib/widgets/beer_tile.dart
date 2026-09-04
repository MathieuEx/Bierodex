import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../models/beer.dart';
import '../screens/beer_detail_screen.dart';

class BeerTile extends StatelessWidget {
  final Beer beer;

  const BeerTile({super.key, required this.beer});

  @override
  Widget build(BuildContext context) {
    final style = findStyleById(beer.styleId);
    final familyColor = style?.family.color ?? Colors.brown;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: familyColor.withValues(alpha: 0.15),
        foregroundColor: familyColor,
        child: const Icon(Icons.sports_bar_outlined),
      ),
      title: Text(beer.name),
      subtitle: Text('${beer.brewery} · ${beer.country}'),
      trailing: Text(
        '${beer.abv.toStringAsFixed(1)}%',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BeerDetailScreen(beerId: beer.id),
          ),
        );
      },
    );
  }
}
