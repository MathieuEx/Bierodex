import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Message sanitaire lié à la présentation de boissons alcoolisées (loi
/// Évin). Affiché à l'entrée de l'app et sur l'écran du compte.
class HealthNotice extends StatelessWidget {
  /// Couleur adaptée aux écrans sombres (entrée de l'app) ; sinon, celle du
  /// thème courant.
  final bool onDark;

  const HealthNotice({super.key, this.onDark = false});

  static const text =
      'L\'abus d\'alcool est dangereux pour la santé. '
      'À consommer avec modération.';

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: onDark ? AppColors.foamSoft : null,
      ),
    );
  }
}
