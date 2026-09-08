import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Affiche une note sur 5 étoiles. Si [onChanged] est fourni, les étoiles
/// deviennent interactives (tap pour noter).
class StarRating extends StatelessWidget {
  final int? rating;
  final double size;
  final ValueChanged<int>? onChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = rating ?? 0;
    const color = AppColors.gold;
    final emptyColor = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < value;
        final icon = Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: filled ? color : emptyColor,
        );
        if (onChanged == null) return icon;
        return InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onChanged!(index + 1),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: icon,
          ),
        );
      }),
    );
  }
}
