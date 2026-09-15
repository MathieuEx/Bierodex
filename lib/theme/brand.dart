import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Lettrage « BIERODEX » à la manière du logo : remplissage or → orange,
/// contour bleu nuit, puis liseré bleu ciel.
class BrandWordmark extends StatelessWidget {
  final double size;
  final String text;

  const BrandWordmark({super.key, this.size = 40, this.text = 'BIERODEX'});

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.display(
      size,
      FontWeight.w900,
      Colors.white,
      height: 1,
      letterSpacing: size * 0.02,
    );
    Text layer(TextStyle style) =>
        Text(text, style: style, maxLines: 1, softWrap: false);

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          layer(
            base.copyWith(
              color: null,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = size * 0.16
                ..strokeJoin = StrokeJoin.round
                ..color = AppColors.sky,
            ),
          ),
          layer(
            base.copyWith(
              color: null,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = size * 0.09
                ..strokeJoin = StrokeJoin.round
                ..color = AppColors.night,
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: AppGradients.amber.createShader,
            child: layer(base),
          ),
        ],
      ),
    );
  }
}

/// Texte rempli du dégradé or → orange (chiffres clés, compteurs).
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppGradients.amber,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: gradient.createShader,
      child: Text(text, style: style),
    );
  }
}

/// Carte encadrée comme l'icône du logo : bordure en dégradé or → orange
/// autour d'un fond bleu nuit légèrement éclairé.
class BrandFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double borderWidth;

  const BrandFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppTheme.radiusCard,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.frame,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: dark ? 0.18 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          gradient: dark ? AppGradients.cardDark : null,
          color: dark ? null : AppColors.cardLight,
          borderRadius: BorderRadius.circular(radius - borderWidth),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Barre de progression en dégradé or → orange sur une piste discrète.
class GradientProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.outlineVariant;
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  gradient: color == null
                      ? const LinearGradient(
                          colors: [AppColors.gold, AppColors.amber],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fond « ciel de nuit » des écrans d'entrée.
class NightBackground extends StatelessWidget {
  final Widget child;

  const NightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.nightGlow),
      child: child,
    );
  }
}

/// Fond commun des tuiles de liste (bières, styles) : carte bleu nuit
/// éclairée en diagonale, liseré bleu ciel discret.
class BrandTileSurface extends StatelessWidget {
  final Widget child;

  const BrandTileSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppTheme.radiusCard - 2);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark ? AppGradients.cardDark : null,
        color: dark ? null : scheme.surface,
        borderRadius: radius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// Vignette carrée arrondie, cadrée d'un dégradé de la couleur de famille,
/// à la manière de l'icône du logo.
class FamilyThumbnail extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String? imageUrl;
  final double size;

  const FamilyThumbnail({
    super.key,
    required this.color,
    required this.icon,
    this.imageUrl,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final inner = BorderRadius.circular(12);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, 0.35)!, color],
        ),
      ),
      child: ClipRRect(
        borderRadius: inner,
        child: ColoredBox(
          color: Color.lerp(AppColors.cardDarkHigh, color, 0.1)!,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(icon, color: color),
                )
              : Icon(icon, color: Color.lerp(color, Colors.white, 0.25)),
        ),
      ),
    );
  }
}

/// Petite pastille de valeur (degré, compteur) teintée de [color].
class ValuePill extends StatelessWidget {
  final String label;
  final Color color;

  const ValuePill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: AppTheme.display(
          13,
          FontWeight.w800,
          Color.lerp(color, Colors.white, 0.2)!,
          height: 1,
        ),
      ),
    );
  }
}
