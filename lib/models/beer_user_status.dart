/// Statut personnel d'un utilisateur vis-à-vis d'une bière : l'a-t-il
/// bue, et quelle note lui a-t-il donnée (1 à 5, ou pas de note).
class BeerUserStatus {
  final bool tried;
  final int? rating;

  const BeerUserStatus({this.tried = false, this.rating});

  Map<String, dynamic> toJson() => {
        'tried': tried,
        if (rating != null) 'rating': rating,
      };

  factory BeerUserStatus.fromJson(Map<String, dynamic> json) {
    return BeerUserStatus(
      tried: json['tried'] as bool? ?? false,
      rating: json['rating'] as int?,
    );
  }
}
