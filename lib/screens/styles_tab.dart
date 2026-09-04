import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../models/beer_style.dart';
import '../widgets/style_tile.dart';

class StylesTab extends StatelessWidget {
  const StylesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final family in BeerFamily.values) ...[
          Container(
            width: double.infinity,
            color: family.color.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              family.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: family.color,
              ),
            ),
          ),
          for (final style in stylesForFamily(family)) StyleTile(style: style),
        ],
      ],
    );
  }
}
