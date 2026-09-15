import '../l10n/l10n.dart';

/// Identifiants des arômes proposés à cocher sur la fiche de dégustation.
/// C'est ce qui est stocké (localement et dans `beer_status.aromas`) : ne
/// jamais renommer un identifiant existant, seulement son libellé.
const tastingAromaIds = [
  'agrumes',
  'fruits_rouges',
  'fruits_exotiques',
  'floral',
  'herbace',
  'resineux',
  'epices',
  'banane_clou',
  'miel',
  'biscuit',
  'caramel',
  'torrefie',
  'chocolat',
  'cafe',
  'boise',
  'acidule',
  'funky',
];

/// Libellés des arômes dans la langue de l'app, dans l'ordre de
/// [tastingAromaIds].
Map<String, String> get tastingAromas {
  final l10n = L10n.current;
  return {
    'agrumes': l10n.aromaAgrumes,
    'fruits_rouges': l10n.aromaFruitsRouges,
    'fruits_exotiques': l10n.aromaFruitsExotiques,
    'floral': l10n.aromaFloral,
    'herbace': l10n.aromaHerbace,
    'resineux': l10n.aromaResineux,
    'epices': l10n.aromaEpices,
    'banane_clou': l10n.aromaBananeClou,
    'miel': l10n.aromaMiel,
    'biscuit': l10n.aromaBiscuit,
    'caramel': l10n.aromaCaramel,
    'torrefie': l10n.aromaTorrefie,
    'chocolat': l10n.aromaChocolat,
    'cafe': l10n.aromaCafe,
    'boise': l10n.aromaBoise,
    'acidule': l10n.aromaAcidule,
    'funky': l10n.aromaFunky,
  };
}

/// Sentinelle de [BeerUserStatus.copyWith] : distingue « ne pas toucher »
/// de « remettre à `null` ».
const _unset = Object();

/// Statut personnel d'un utilisateur vis-à-vis d'une bière : bue, à goûter,
/// ou ni l'une ni l'autre. [tried] et [wishlist] sont mutuellement
/// exclusifs (voir [BeerCollectionService]).
class BeerUserStatus {
  final bool tried;
  final bool wishlist;
  final int? rating;

  /// Date à laquelle la bière a été dégustée (renseignée automatiquement
  /// au moment où [tried] passe à `true`, modifiable ensuite à la main).
  final DateTime? triedAt;

  /// Note de dégustation libre (arômes, contexte, avec qui...).
  final String? note;

  /// Fiche de dégustation détaillée, chaque critère de 1 à 5 : couleur
  /// (1 = très pâle, 5 = noire), amertume, douceur et corps.
  final int? color;
  final int? bitterness;
  final int? sweetness;
  final int? body;

  /// Identifiants d'arômes cochés (clés de [tastingAromas]).
  final List<String> aromas;

  /// Chemin de la photo de dégustation dans le bucket privé Supabase
  /// Storage (voir `TastingPhotoService`), jamais une URL publique.
  final String? photoPath;

  const BeerUserStatus({
    this.tried = false,
    this.wishlist = false,
    this.rating,
    this.triedAt,
    this.note,
    this.color,
    this.bitterness,
    this.sweetness,
    this.body,
    this.aromas = const [],
    this.photoPath,
  });

  /// Au moins un critère de la fiche détaillée est renseigné.
  bool get hasTastingProfile =>
      color != null ||
      bitterness != null ||
      sweetness != null ||
      body != null ||
      aromas.isNotEmpty;

  BeerUserStatus copyWith({
    bool? tried,
    bool? wishlist,
    Object? rating = _unset,
    Object? triedAt = _unset,
    Object? note = _unset,
    Object? color = _unset,
    Object? bitterness = _unset,
    Object? sweetness = _unset,
    Object? body = _unset,
    List<String>? aromas,
    Object? photoPath = _unset,
  }) => BeerUserStatus(
    tried: tried ?? this.tried,
    wishlist: wishlist ?? this.wishlist,
    rating: rating == _unset ? this.rating : rating as int?,
    triedAt: triedAt == _unset ? this.triedAt : triedAt as DateTime?,
    note: note == _unset ? this.note : note as String?,
    color: color == _unset ? this.color : color as int?,
    bitterness: bitterness == _unset ? this.bitterness : bitterness as int?,
    sweetness: sweetness == _unset ? this.sweetness : sweetness as int?,
    body: body == _unset ? this.body : body as int?,
    aromas: aromas ?? this.aromas,
    photoPath: photoPath == _unset ? this.photoPath : photoPath as String?,
  );

  /// Tout ce qui décrit une dégustation, effacé quand la bière n'est plus
  /// marquée comme bue.
  BeerUserStatus withoutTasting() =>
      BeerUserStatus(tried: false, wishlist: wishlist);

  Map<String, dynamic> toJson() => {
    'tried': tried,
    if (wishlist) 'wishlist': wishlist,
    if (rating != null) 'rating': rating,
    if (triedAt != null) 'triedAt': triedAt!.toIso8601String(),
    if (note != null) 'note': note,
    if (color != null) 'color': color,
    if (bitterness != null) 'bitterness': bitterness,
    if (sweetness != null) 'sweetness': sweetness,
    if (body != null) 'body': body,
    if (aromas.isNotEmpty) 'aromas': aromas,
    if (photoPath != null) 'photoPath': photoPath,
  };

  factory BeerUserStatus.fromJson(Map<String, dynamic> json) {
    final triedAtRaw = json['triedAt'] as String?;
    return BeerUserStatus(
      tried: json['tried'] as bool? ?? false,
      wishlist: json['wishlist'] as bool? ?? false,
      rating: json['rating'] as int?,
      triedAt: triedAtRaw != null ? DateTime.tryParse(triedAtRaw) : null,
      note: json['note'] as String?,
      color: json['color'] as int?,
      bitterness: json['bitterness'] as int?,
      sweetness: json['sweetness'] as int?,
      body: json['body'] as int?,
      aromas: _aromasFrom(json['aromas']),
      photoPath: json['photoPath'] as String?,
    );
  }

  /// Ligne de la table Supabase `beer_status` (colonnes en snake_case).
  Map<String, dynamic> toRow({
    required String userId,
    required String beerId,
  }) => {
    'user_id': userId,
    'beer_id': beerId,
    'tried': tried,
    'wishlist': wishlist,
    'rating': rating,
    'tried_at': triedAt?.toIso8601String(),
    'note': note,
    'color': color,
    'bitterness': bitterness,
    'sweetness': sweetness,
    'body': body,
    'aromas': aromas,
    'photo_path': photoPath,
  };

  factory BeerUserStatus.fromRow(Map<String, dynamic> row) {
    final triedAtRaw = row['tried_at'] as String?;
    return BeerUserStatus(
      tried: row['tried'] as bool? ?? false,
      wishlist: row['wishlist'] as bool? ?? false,
      rating: row['rating'] as int?,
      triedAt: triedAtRaw != null ? DateTime.tryParse(triedAtRaw) : null,
      note: row['note'] as String?,
      color: row['color'] as int?,
      bitterness: row['bitterness'] as int?,
      sweetness: row['sweetness'] as int?,
      body: row['body'] as int?,
      aromas: _aromasFrom(row['aromas']),
      photoPath: row['photo_path'] as String?,
    );
  }

  /// Ignore les arômes inconnus (retirés d'une version ultérieure, ou
  /// injectés directement via l'API).
  static List<String> _aromasFrom(Object? raw) => raw is List
      ? [
          for (final item in raw)
            if (item is String && tastingAromaIds.contains(item)) item,
        ]
      : const [];
}
