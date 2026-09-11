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

  /// Code-barres EAN/UPC de la bouteille/canette, utilisé pour retrouver
  /// cette bière au scan (voir `lib/screens/barcode_scanner_screen.dart`).
  /// `null` pour la plupart des bières du catalogue partagé, non
  /// systématiquement renseigné.
  final String? barcode;

  /// `true` pour une bière ajoutée par l'utilisateur lui-même (voir
  /// [UserBeerService]), absente du catalogue partagé géré côté Supabase.
  final bool isCustom;

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
    this.barcode,
    this.isCustom = false,
  });

  factory Beer.fromJson(Map<String, dynamic> row, {bool isCustom = false}) =>
      Beer(
        id: row['id'] as String,
        name: row['name'] as String,
        brewery: row['brewery'] as String,
        country: row['country'] as String,
        styleId: row['style_id'] as String,
        abv: (row['abv'] as num).toDouble(),
        description: row['description'] as String,
        imageUrl: row['image_url'] as String?,
        imageCredit: row['image_credit'] as String?,
        barcode: row['barcode'] as String?,
        isCustom: isCustom,
      );

  /// Sérialisation utilisée pour le cache local et la synchronisation
  /// Supabase des bières ajoutées par l'utilisateur (voir
  /// [UserBeerService]) : [isCustom] n'en fait pas partie, c'est le
  /// contexte de chargement qui le détermine.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brewery': brewery,
        'country': country,
        'style_id': styleId,
        'abv': abv,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (imageCredit != null) 'image_credit': imageCredit,
        if (barcode != null) 'barcode': barcode,
      };
}
