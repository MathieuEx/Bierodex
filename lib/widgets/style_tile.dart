import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer_style.dart';
import '../screens/style_detail_screen.dart';
import '../theme/brand.dart';

/// Un style de bière, présenté comme une carte du Bierodex, cohérente avec
/// [BeerTile].
class StyleTile extends StatelessWidget {
  final BeerStyle style;

  const StyleTile({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final count = beersForStyle(style.id).length;
    final color = style.family.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: BrandTileSurface(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StyleDetailScreen(styleId: style.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
            child: Row(
              children: [
                FamilyThumbnail(color: color, icon: Icons.local_drink_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${style.origin} · ${style.abvRange}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  ValuePill(label: '$count', color: color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
