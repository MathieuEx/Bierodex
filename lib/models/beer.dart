/// Une bière concrète, rattachée à un [BeerStyle] via [styleId].
class Beer {
  final String id;
  final String name;
  final String brewery;
  final String country;
  final String styleId;
  final double abv;
  final String description;

  /// Photo du produit (Open Food Facts, licence CC BY-SA), ou `null` si
  /// aucune correspondance fiable n'a été trouvée pour cette bière.
  final String? imageUrl;

  const Beer({
    required this.id,
    required this.name,
    required this.brewery,
    required this.country,
    required this.styleId,
    required this.abv,
    required this.description,
    this.imageUrl,
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
      );
}
