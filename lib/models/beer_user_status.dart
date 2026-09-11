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

  const BeerUserStatus({
    this.tried = false,
    this.wishlist = false,
    this.rating,
    this.triedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'tried': tried,
        if (wishlist) 'wishlist': wishlist,
        if (rating != null) 'rating': rating,
        if (triedAt != null) 'triedAt': triedAt!.toIso8601String(),
        if (note != null) 'note': note,
      };

  factory BeerUserStatus.fromJson(Map<String, dynamic> json) {
    final triedAtRaw = json['triedAt'] as String?;
    return BeerUserStatus(
      tried: json['tried'] as bool? ?? false,
      wishlist: json['wishlist'] as bool? ?? false,
      rating: json['rating'] as int?,
      triedAt: triedAtRaw != null ? DateTime.tryParse(triedAtRaw) : null,
      note: json['note'] as String?,
    );
  }
}
