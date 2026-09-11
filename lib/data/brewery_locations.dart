import '../models/brewery_location.dart';
import 'beers.dart';

/// Localisation de chaque brasserie référencée dans `beers.dart`, chargée
/// depuis Supabase au démarrage par [CatalogService] (voir
/// `lib/services/catalog_service.dart`). Vide tant que le catalogue n'a
/// pas fini de charger. Données géographiques : OpenStreetMap / Nominatim
/// (ODbL, https://www.openstreetmap.org/copyright).
Map<String, BreweryLocation> breweryLocations = {};

/// Position moyenne (centroïde) des brasseries connues d'un pays, utilisée
/// comme point d'ancrage du marqueur pays sur le globe. `null` si aucune
/// brasserie localisée n'est connue pour ce pays.
({double lat, double lng})? countryCentroid(String country) {
  final points = [
    for (final brewery in breweriesForCountry(country))
      if (breweryLocations[brewery] != null) breweryLocations[brewery]!,
  ];
  if (points.isEmpty) return null;
  final lat = points.map((p) => p.lat).reduce((a, b) => a + b) / points.length;
  final lng = points.map((p) => p.lng).reduce((a, b) => a + b) / points.length;
  return (lat: lat, lng: lng);
}

/// Un marqueur par pays : nom du pays + sa position centroïde, uniquement
/// pour les pays ayant au moins une brasserie localisée.
Map<String, ({double lat, double lng})> get countryMarkers {
  final result = <String, ({double lat, double lng})>{};
  for (final country in allCountries) {
    final centroid = countryCentroid(country);
    if (centroid != null) result[country] = centroid;
  }
  return result;
}
