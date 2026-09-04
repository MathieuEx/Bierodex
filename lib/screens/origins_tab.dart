import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../screens/origin_detail_screen.dart';

class OriginsTab extends StatelessWidget {
  const OriginsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final countries = allCountries;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        final count = beersForCountry(country).length;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.public)),
          title: Text(country),
          trailing: Chip(
            label: Text('$count'),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OriginDetailScreen(country: country),
              ),
            );
          },
        );
      },
    );
  }
}
