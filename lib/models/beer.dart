/// Une bière concrète, rattachée à un [BeerStyle] via [styleId].
class Beer {
  final String id;
  final String name;
  final String brewery;
  final String country;
  final String styleId;
  final double abv;
  final String description;

  /// Photo du produit (Open Food Facts ou Wikimedia Commons, licences
  /// libres), ou `null` si aucune correspondance fiable n'a été trouvée
  /// pour cette bière.
  final String? imageUrl;

  /// Crédit à afficher sous la photo (auteur + licence), requis dès que
  /// [imageUrl] est non nul.
  final String? imageCredit;

  const Beer({
    required this.id,
    required this.name,
    required this.brewery,
    required this.country,
    required this.styleId,
    required this.abv,
    required this.description,
    this.imageUrl,
    this.imageCredit,
  });

  factory Beer.fromJson(Map<String, dynamic> row) => Beer(
        id: row['id'] as String,
        name: row['name'] as String,
        brewery: row['brewery'] as String,
        country: row['country'] as String,
        styleId: row['style_id'] as String,
        abv: (row['abv'] as num).toDouble(),
        description: row['description'] as String,
        imageUrl: row['image_url'] as String?,
        imageCredit: row['image_credit'] as String?,
      );
}
