import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/share_config.dart';
import '../models/social.dart';
import 'auth_service.dart';
import '../l10n/l10n.dart';

/// Erreur affichable telle quelle à l'utilisateur.
class SocialFailure implements Exception {
  final String message;
  const SocialFailure(this.message);

  @override
  String toString() => message;
}

/// Profil public optionnel et amis (voir `supabase/add_social.sql`).
///
/// Ce service ne lit jamais directement les tables des autres comptes :
/// tout passe par des fonctions SQL qui vérifient la visibilité du profil
/// côté serveur. L'app ne fait qu'afficher ce que le serveur accepte de
/// renvoyer.
class SocialService extends ChangeNotifier {
  SocialService._() {
    AuthService.instance.addListener(_onAuthChanged);
  }

  static final SocialService instance = SocialService._();

  static const minUsernameLength = 3;
  static const maxUsernameLength = 20;
  static const maxDisplayNameLength = 40;
  static final _usernamePattern = RegExp(r'^[a-z0-9_]+$');

  SupabaseClient get _client => Supabase.instance.client;

  UserProfile? _profile;
  bool _profileLoaded = false;
  String? _userId;
  List<Friendship> _friendships = const [];

  /// `null` tant que l'utilisateur n'a pas choisi de pseudo.
  UserProfile? get profile => _profile;
  bool get isProfileLoaded => _profileLoaded;
  List<Friendship> get friendships => _friendships;
  List<Friendship> get friends =>
      _friendships.where((f) => f.accepted).toList();
  List<Friendship> get receivedRequests =>
      _friendships.where((f) => !f.accepted && !f.sentByMe).toList();
  List<Friendship> get sentRequests =>
      _friendships.where((f) => !f.accepted && f.sentByMe).toList();

  void _onAuthChanged() {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == _userId) return;
    _userId = userId;
    _profile = null;
    _profileLoaded = false;
    _friendships = const [];
    notifyListeners();
  }

  /// Normalise un pseudo saisi (espaces, `@` initial, majuscules).
  static String normalizeUsername(String input) {
    var value = input.trim().toLowerCase();
    if (value.startsWith('@')) value = value.substring(1);
    return value;
  }

  /// Mêmes règles que la contrainte `profiles_bounds` côté serveur.
  static String? usernameProblem(String username) {
    if (username.length < minUsernameLength ||
        username.length > maxUsernameLength) {
      return L10n.current.usernameLength(minUsernameLength, maxUsernameLength);
    }
    if (!_usernamePattern.hasMatch(username)) {
      return L10n.current.usernameCharacters;
    }
    return null;
  }

  /// Lien à partager pour un profil. `null` si l'URL du site web n'est pas
  /// configurée (voir [ShareConfig]).
  static Uri? profileLink(String username) {
    if (ShareConfig.webBaseUrl.isEmpty) return null;
    final base = Uri.parse(ShareConfig.webBaseUrl);
    return base.replace(
      queryParameters: {...base.queryParameters, 'profil': username},
    );
  }

  Future<UserProfile?> loadProfile() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return null;
    _userId = user.id;
    final row = await _guard(
      () => _client
          .from('profiles')
          .select('username, display_name, visibility')
          .eq('user_id', user.id)
          .maybeSingle(),
    );
    _profile = row == null ? null : UserProfile.fromRow(row);
    _profileLoaded = true;
    notifyListeners();
    return _profile;
  }

  Future<void> saveProfile({
    required String username,
    required String? displayName,
    required ProfileVisibility visibility,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw SocialFailure(L10n.current.errorSignInRequired);
    final normalized = normalizeUsername(username);
    final problem = usernameProblem(normalized);
    if (problem != null) throw SocialFailure(problem);
    final name = displayName?.trim();
    if (name != null && name.length > maxDisplayNameLength) {
      throw SocialFailure(L10n.current.displayNameTooLong);
    }

    final row = await _guard(
      () => _client
          .from('profiles')
          .upsert({
            'user_id': user.id,
            'username': normalized,
            'display_name': (name == null || name.isEmpty) ? null : name,
            'visibility': visibility.value,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select('username, display_name, visibility')
          .single(),
    );
    _profile = UserProfile.fromRow(row);
    _profileLoaded = true;
    notifyListeners();
  }

  Future<List<Friendship>> loadFriendships() async {
    if (AuthService.instance.currentUser == null) return const [];
    final rows = await _guard(() => _client.rpc('list_friendships'));
    _friendships = [
      for (final row in rows as List)
        Friendship.fromRow(row as Map<String, dynamic>),
    ];
    notifyListeners();
    return _friendships;
  }

  Future<FoundProfile?> findProfile(String username) async {
    final normalized = normalizeUsername(username);
    if (usernameProblem(normalized) != null) return null;
    final rows = await _guard(
      () => _client.rpc('find_profile', params: {'p_username': normalized}),
    );
    final list = rows as List;
    return list.isEmpty
        ? null
        : FoundProfile.fromRow(list.first as Map<String, dynamic>);
  }

  /// Envoie une demande d'ami. Retourne `true` si l'amitié est directement
  /// acceptée (l'autre personne avait déjà envoyé une demande).
  Future<bool> sendFriendRequest(String username) async {
    final result = await _guard(
      () => _client.rpc(
        'send_friend_request',
        params: {'p_username': normalizeUsername(username)},
      ),
    );
    await loadFriendships();
    return result == 'accepted';
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _guard(
      () => _client.rpc(
        'accept_friend_request',
        params: {'p_request_id': requestId},
      ),
    );
    await loadFriendships();
  }

  /// Refuse une demande reçue, annule une demande envoyée ou retire un ami.
  Future<void> removeFriendship(String friendshipId) async {
    await _guard(
      () => _client.from('friendships').delete().eq('id', friendshipId),
    );
    await loadFriendships();
  }

  /// Collection d'un profil, ou `null` s'il n'existe pas ou n'est pas
  /// visible (le serveur ne distingue volontairement pas les deux cas).
  /// Fonctionne aussi sans compte, pour un profil public.
  Future<SharedProfile?> fetchSharedProfile(String username) async {
    final result = await _guard(
      () => _client.rpc(
        'get_shared_profile',
        params: {'p_username': normalizeUsername(username)},
      ),
    );
    return result is Map<String, dynamic>
        ? SharedProfile.fromJson(result)
        : null;
  }

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      throw SocialFailure(messageFor(e.code, e.message));
    } on SocialFailure {
      rethrow;
    } catch (_) {
      throw SocialFailure(L10n.current.errorServerUnreachable);
    }
  }

  /// Traduit les erreurs levées par `supabase/add_social.sql`.
  @visibleForTesting
  static String messageFor(String? code, String message) {
    final l10n = L10n.current;
    if (code == '23505') return l10n.socialUsernameTaken;
    if (code == '23514') return l10n.socialInvalidProfile;
    if (message.contains('profile_required')) {
      return l10n.socialProfileRequired;
    }
    if (message.contains('profile_not_found')) {
      return l10n.socialProfileNotFound;
    }
    if (message.contains('cannot_add_self')) {
      return l10n.socialCannotAddSelf;
    }
    if (message.contains('too_many_requests')) {
      return l10n.socialTooManyRequests;
    }
    if (message.contains('request_not_found')) {
      return l10n.socialRequestNotFound;
    }
    return l10n.errorGeneric;
  }
}
