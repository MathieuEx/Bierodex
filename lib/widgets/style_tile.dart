import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer_style.dart';
import '../screens/style_detail_screen.dart';

class StyleTile extends StatelessWidget {
  final BeerStyle style;

  const StyleTile({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final count = beersForStyle(style.id).length;
    final color = style.family.color;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        child: const Icon(Icons.local_drink_outlined),
      ),
      title: Text(style.name),
      subtitle: Text('${style.origin} · ${style.abvRange}'),
      trailing: count > 0
          ? Chip(
              label: Text('$count'),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StyleDetailScreen(styleId: style.id),
          ),
        );
      },
    );
  }
}
