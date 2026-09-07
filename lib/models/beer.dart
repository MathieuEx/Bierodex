/// Une bière concrète, rattachée à un [BeerStyle] via [styleId].
class Beer {
  final String id;
  final String name;
  final String brewery;
  final String country;
  final String styleId;
  final double abv;
  final String description;

  const Beer({
    required this.id,
    required this.name,
    required this.brewery,
    required this.country,
    required this.styleId,
    required this.abv,
    required this.description,
  });

  factory Beer.fromJson(Map<String, dynamic> row) => Beer(
        id: row['id'] as String,
        name: row['name'] as String,
        brewery: row['brewery'] as String,
        country: row['country'] as String,
        styleId: row['style_id'] as String,
        abv: (row['abv'] as num).toDouble(),
        description: row['description'] as String,
      );
}
