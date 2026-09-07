import '../models/beer.dart';

/// Catalogue des bières, chargé depuis Supabase au démarrage par
/// [CatalogService] (voir `lib/services/catalog_service.dart`). Vide tant
/// que le catalogue n'a pas fini de charger.
List<Beer> beers = [];

Beer? findBeerById(String id) {
  for (final beer in beers) {
    if (beer.id == id) return beer;
  }
  return null;
}

List<Beer> beersForStyle(String styleId) =>
    beers.where((b) => b.styleId == styleId).toList();

List<Beer> beersForCountry(String country) =>
    beers.where((b) => b.country == country).toList();

List<Beer> beersForCountries(List<String> countries) =>
    beers.where((b) => countries.contains(b.country)).toList();

List<String> get allCountries {
  final set = <String>{for (final b in beers) b.country};
  final list = set.toList()..sort();
  return list;
}

List<Beer> beersForBrewery(String brewery) =>
    beers.where((b) => b.brewery == brewery).toList();

/// Les brasseries ayant au moins une bière référencée dans [country].
List<String> breweriesForCountry(String country) {
  final set = <String>{
    for (final b in beers)
      if (b.country == country) b.brewery,
  };
  final list = set.toList()..sort();
  return list;
}
