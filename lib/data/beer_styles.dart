import '../models/beer_style.dart';

/// Taxonomie des grands styles de bières, chargée depuis Supabase au
/// démarrage par [CatalogService] (voir `lib/services/catalog_service.dart`).
/// Vide tant que le catalogue n'a pas fini de charger.
List<BeerStyle> beerStyles = [];

BeerStyle? findStyleById(String id) {
  for (final style in beerStyles) {
    if (style.id == id) return style;
  }
  return null;
}

List<BeerStyle> stylesForFamily(BeerFamily family) =>
    beerStyles.where((s) => s.family == family).toList();
