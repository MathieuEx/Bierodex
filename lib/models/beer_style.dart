import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

/// Grande famille de fermentation, le premier niveau de classification.
enum BeerFamily {
  aleHaute,
  lagerBasse,
  spontanee,
  mixte;

  String get label {
    final l10n = L10n.current;
    switch (this) {
      case BeerFamily.aleHaute:
        return l10n.familyAle;
      case BeerFamily.lagerBasse:
        return l10n.familyLager;
      case BeerFamily.spontanee:
        return l10n.familySpontaneous;
      case BeerFamily.mixte:
        return l10n.familyMixed;
    }
  }

  String get shortLabel {
    final l10n = L10n.current;
    switch (this) {
      case BeerFamily.aleHaute:
        return 'Ale';
      case BeerFamily.lagerBasse:
        return 'Lager';
      case BeerFamily.spontanee:
        return l10n.familySpontaneousShort;
      case BeerFamily.mixte:
        return l10n.familyMixedShort;
    }
  }

  Color get color {
    switch (this) {
      case BeerFamily.aleHaute:
        return const Color(0xFFF28A17);
      case BeerFamily.lagerBasse:
        return const Color(0xFFFDB602);
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

  factory BeerStyle.fromJson(Map<String, dynamic> row) => BeerStyle(
    id: row['id'] as String,
    name: row['name'] as String,
    family: BeerFamily.values.byName(row['family'] as String),
    origin: row['origin'] as String,
    abvRange: row['abv_range'] as String,
    description: row['description'] as String,
  );
}
