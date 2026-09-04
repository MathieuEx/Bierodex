import 'package:flutter/material.dart';

/// Grande famille de fermentation, le premier niveau de classification.
enum BeerFamily {
  aleHaute,
  lagerBasse,
  spontanee,
  mixte;

  String get label {
    switch (this) {
      case BeerFamily.aleHaute:
        return 'Fermentation haute (Ale)';
      case BeerFamily.lagerBasse:
        return 'Fermentation basse (Lager)';
      case BeerFamily.spontanee:
        return 'Fermentation spontanée';
      case BeerFamily.mixte:
        return 'Fermentation mixte';
    }
  }

  String get shortLabel {
    switch (this) {
      case BeerFamily.aleHaute:
        return 'Ale';
      case BeerFamily.lagerBasse:
        return 'Lager';
      case BeerFamily.spontanee:
        return 'Spontanée';
      case BeerFamily.mixte:
        return 'Mixte';
    }
  }

  Color get color {
    switch (this) {
      case BeerFamily.aleHaute:
        return const Color(0xFFC9752B);
      case BeerFamily.lagerBasse:
        return const Color(0xFFD9A62E);
      case BeerFamily.spontanee:
        return const Color(0xFF8B3A3A);
      case BeerFamily.mixte:
        return const Color(0xFF6B4226);
    }
  }
}

/// Un style de bière (Pilsner, IPA, Stout, ...), deuxième niveau de
/// classification à l'intérieur d'une [BeerFamily].
class BeerStyle {
  final String id;
  final String name;
  final BeerFamily family;
  final String origin;
  final String abvRange;
  final String description;

  const BeerStyle({
    required this.id,
    required this.name,
    required this.family,
    required this.origin,
    required this.abvRange,
    required this.description,
  });
}
