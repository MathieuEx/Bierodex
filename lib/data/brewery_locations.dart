import '../models/brewery_location.dart';

/// Localisation de chaque brasserie référencée dans `beers.dart`, chargée
/// depuis Supabase au démarrage par [CatalogService] (voir
/// `lib/services/catalog_service.dart`). Vide tant que le catalogue n'a
/// pas fini de charger. Données géographiques : OpenStreetMap / Nominatim
/// (ODbL, https://www.openstreetmap.org/copyright).
Map<String, BreweryLocation> breweryLocations = {};
