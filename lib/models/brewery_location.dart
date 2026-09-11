/// Localisation d'une brasserie référencée dans [lib/data/beers.dart],
/// obtenue via OpenStreetMap/Nominatim (données ODbL,
/// https://www.openstreetmap.org/copyright).
class BreweryLocation {
  final double lat;
  final double lng;
  final String city;

  /// Adresse complète telle que retournée par Nominatim (rue, ville, pays
  /// quand disponibles ; à défaut, la zone la plus précise trouvée).
  final String address;

  /// Logo de la brasserie (Wikimedia Commons, licence libre), ou `null` si
  /// aucune correspondance fiable n'a été trouvée.
  final String? logoUrl;

  /// Crédit à afficher pour [logoUrl] (auteur + licence).
  final String? logoCredit;

  const BreweryLocation({
    required this.lat,
    required this.lng,
    required this.city,
    required this.address,
    this.logoUrl,
    this.logoCredit,
  });

  factory BreweryLocation.fromJson(Map<String, dynamic> row) => BreweryLocation(
        lat: (row['lat'] as num).toDouble(),
        lng: (row['lng'] as num).toDouble(),
        city: row['city'] as String? ?? '',
        address: row['address'] as String? ?? '',
        logoUrl: row['logo_url'] as String?,
        logoCredit: row['logo_credit'] as String?,
      );
}
