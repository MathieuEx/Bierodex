import 'beer.dart';
import 'beer_user_status.dart';
import '../l10n/l10n.dart';

/// Qui peut voir la collection d'un profil (colonne `profiles.visibility`).
enum ProfileVisibility {
  private('private'),
  friends('friends'),
  public('public');

  final String value;

  const ProfileVisibility(this.value);

  String get label => switch (this) {
    private => L10n.current.visibilityPrivate,
    friends => L10n.current.visibilityFriends,
    public => L10n.current.visibilityPublic,
  };

  String get description => switch (this) {
    private => L10n.current.visibilityPrivateDescription,
    friends => L10n.current.visibilityFriendsDescription,
    public => L10n.current.visibilityPublicDescription,
  };

  static ProfileVisibility fromValue(String? value) => values.firstWhere(
    (v) => v.value == value,
    orElse: () => ProfileVisibility.private,
  );
}

/// Le profil de l'utilisateur connecté (sa propre ligne de `profiles`).
class UserProfile {
  final String username;
  final String? displayName;
  final ProfileVisibility visibility;

  const UserProfile({
    required this.username,
    this.displayName,
    this.visibility = ProfileVisibility.private,
  });

  factory UserProfile.fromRow(Map<String, dynamic> row) => UserProfile(
    username: row['username'] as String,
    displayName: row['display_name'] as String?,
    visibility: ProfileVisibility.fromValue(row['visibility'] as String?),
  );
}

/// Relation entre l'utilisateur connecté et un autre profil, telle que
/// renvoyée par `find_profile`.
enum ProfileRelation { self, friend, pendingSent, pendingReceived, none }

ProfileRelation _relationFrom(String? value) => switch (value) {
  'self' => ProfileRelation.self,
  'friend' => ProfileRelation.friend,
  'pending_sent' => ProfileRelation.pendingSent,
  'pending_received' => ProfileRelation.pendingReceived,
  _ => ProfileRelation.none,
};

class FoundProfile {
  final String username;
  final String? displayName;
  final ProfileRelation relation;

  const FoundProfile({
    required this.username,
    this.displayName,
    required this.relation,
  });

  factory FoundProfile.fromRow(Map<String, dynamic> row) => FoundProfile(
    username: row['username'] as String,
    displayName: row['display_name'] as String?,
    relation: _relationFrom(row['relation'] as String?),
  );
}

/// Un ami, ou une demande d'ami reçue / envoyée (`list_friendships`).
class Friendship {
  final String id;
  final String username;
  final String? displayName;
  final bool accepted;

  /// `true` si c'est l'utilisateur connecté qui a envoyé la demande.
  final bool sentByMe;

  const Friendship({
    required this.id,
    required this.username,
    this.displayName,
    required this.accepted,
    required this.sentByMe,
  });

  String get label => displayName ?? '@$username';

  factory Friendship.fromRow(Map<String, dynamic> row) => Friendship(
    id: row['id'] as String,
    username: row['username'] as String,
    displayName: row['display_name'] as String?,
    accepted: row['status'] == 'accepted',
    sentByMe: row['direction'] == 'sent',
  );
}

/// Collection d'un autre profil, en lecture seule, telle que la renvoie
/// `get_shared_profile` : uniquement statut, note sur 5 et date. Les notes
/// libres, fiches de dégustation et photos ne quittent jamais le compte.
class SharedProfile {
  final String username;
  final String? displayName;
  final ProfileVisibility visibility;
  final bool isSelf;
  final Map<String, BeerUserStatus> statuses;

  /// Bières ajoutées à la main par ce profil (absentes du catalogue).
  final Map<String, Beer> customBeers;

  const SharedProfile({
    required this.username,
    this.displayName,
    required this.visibility,
    required this.isSelf,
    required this.statuses,
    required this.customBeers,
  });

  String get label => displayName ?? '@$username';

  factory SharedProfile.fromJson(Map<String, dynamic> json) {
    final statuses = <String, BeerUserStatus>{};
    for (final raw in (json['entries'] as List? ?? const [])) {
      final row = raw as Map<String, dynamic>;
      statuses[row['beer_id'] as String] = BeerUserStatus.fromRow(row);
    }
    return SharedProfile(
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      visibility: ProfileVisibility.fromValue(json['visibility'] as String?),
      isSelf: json['is_self'] as bool? ?? false,
      statuses: statuses,
      customBeers: {
        for (final raw in (json['custom_beers'] as List? ?? const []))
          (raw as Map<String, dynamic>)['id'] as String: Beer.fromJson(
            raw,
            isCustom: true,
          ),
      },
    );
  }
}

enum SubmissionStatus { pending, approved, rejected }

/// Bière du carnet personnel proposée au catalogue commun
/// (table `beer_submissions`).
class BeerSubmission {
  final String id;
  final String userBeerId;
  final String name;
  final String brewery;
  final String country;
  final String styleId;
  final double abv;
  final String description;
  final String? barcode;
  final String? imageUrl;
  final SubmissionStatus status;
  final String? reviewNote;
  final String? catalogBeerId;
  final DateTime createdAt;

  const BeerSubmission({
    required this.id,
    required this.userBeerId,
    required this.name,
    required this.brewery,
    required this.country,
    required this.styleId,
    required this.abv,
    required this.description,
    this.barcode,
    this.imageUrl,
    required this.status,
    this.reviewNote,
    this.catalogBeerId,
    required this.createdAt,
  });

  factory BeerSubmission.fromRow(Map<String, dynamic> row) => BeerSubmission(
    id: row['id'] as String,
    userBeerId: row['user_beer_id'] as String,
    name: row['name'] as String,
    brewery: row['brewery'] as String,
    country: row['country'] as String,
    styleId: row['style_id'] as String,
    abv: (row['abv'] as num).toDouble(),
    description: row['description'] as String? ?? '',
    barcode: row['barcode'] as String?,
    imageUrl: row['image_url'] as String?,
    status: SubmissionStatus.values.firstWhere(
      (s) => s.name == row['status'],
      orElse: () => SubmissionStatus.pending,
    ),
    reviewNote: row['review_note'] as String?,
    catalogBeerId: row['catalog_beer_id'] as String?,
    createdAt:
        DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
  );
}
