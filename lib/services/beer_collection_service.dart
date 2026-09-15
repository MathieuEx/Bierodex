import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/beer_user_status.dart';
import 'auth_service.dart';
import 'sync_queue.dart';
import 'tasting_photo_service.dart';

/// Suivi personnel des bières (essayées / à goûter / notées / commentées).
/// Toujours persisté localement sur l'appareil ; synchronisé en plus avec
/// Supabase quand l'utilisateur est connecté (voir [AuthService]).
///
/// Chaque modification est d'abord enregistrée sur l'appareil puis mise en
/// file d'attente ([syncQueue]) : sans réseau, elle part dès que la
/// connexion revient (voir `OfflineSyncService`), même après un redémarrage
/// de l'app.
class BeerCollectionService extends ChangeNotifier {
  BeerCollectionService._() {
    AuthService.instance.addListener(_onAuthChanged);
  }

  static final BeerCollectionService instance = BeerCollectionService._();

  static const _prefsKey = 'bierodex.collection.v1';
  static const _table = 'beer_status';

  final Map<String, BeerUserStatus> _statuses = {};

  /// Bières dont la dernière version locale n'a pas encore été confirmée
  /// par Supabase.
  final SyncQueue syncQueue = SyncQueue(_table);
  bool _loaded = false;

  /// Compte dont [_statuses] contient les données (`null` : personne).
  String? _userId;

  bool get isLoaded => _loaded;

  /// Chaque compte a son propre cache local : sans cela, se déconnecter
  /// puis se connecter avec un autre compte sur le même appareil enverrait
  /// la collection du premier sur le compte du second.
  static String _keyFor(String? userId) =>
      userId == null ? _prefsKey : '$_prefsKey.$userId';

  /// Efface le cache local d'un compte supprimé (voir
  /// `AuthService.deleteAccount`) : rien ne doit survivre sur l'appareil.
  static Future<void> forgetUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(userId));
    await SyncQueue.forgetUser(_table, userId);
  }

  Future<void> load() async {
    if (_loaded) return;
    await _loadFor(AuthService.instance.currentUser?.id);
    _loaded = true;
    notifyListeners();
    // La copie locale suffit pour démarrer : la synchronisation se fait en
    // arrière-plan et ne bloque pas l'app sur un réseau lent.
    if (_userId != null) unawaited(syncWithRemote());
  }

  Future<void> _loadFor(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    _userId = userId;
    _statuses.clear();
    await syncQueue.load(userId);
    var raw = prefs.getString(_keyFor(userId));
    // Avant la connexion obligatoire, la collection était rangée sans
    // compte associé : elle revient une seule fois au premier compte qui
    // se connecte sur cet appareil.
    if (raw == null && userId != null) {
      raw = prefs.getString(_prefsKey);
      await prefs.remove(_prefsKey);
    }
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _statuses[entry.key] = BeerUserStatus.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
      if (userId != null) await _persist();
    }
  }

  Future<void> _onAuthChanged() async {
    final userId = AuthService.instance.currentUser?.id;
    if (!_loaded || userId == _userId) return;
    await _loadFor(userId);
    notifyListeners();
    if (userId != null) await syncWithRemote();
  }

  BeerUserStatus statusFor(String beerId) =>
      _statuses[beerId] ?? const BeerUserStatus();

  /// Tous les statuts connus, en lecture seule (statistiques, badges,
  /// recommandations).
  Map<String, BeerUserStatus> get statuses => Map.unmodifiable(_statuses);

  bool isTried(String beerId) => statusFor(beerId).tried;

  bool isWishlist(String beerId) => statusFor(beerId).wishlist;

  int? ratingFor(String beerId) => statusFor(beerId).rating;

  DateTime? triedAtFor(String beerId) => statusFor(beerId).triedAt;

  String? noteFor(String beerId) => statusFor(beerId).note;

  Future<void> _update(
    String beerId,
    BeerUserStatus Function(BeerUserStatus current) change,
  ) async {
    _statuses[beerId] = change(statusFor(beerId));
    notifyListeners();
    await _persist();
    await _enqueue([beerId]);
  }

  /// Marque [beerId] comme bue ou non. La marquer comme bue l'enlève de la
  /// liste "à goûter" et horodate la dégustation (sauf si une date était
  /// déjà connue) ; revenir en arrière efface toute la dégustation (date,
  /// note, fiche détaillée et photo).
  Future<void> setTried(String beerId, bool tried) async {
    final photoPath = statusFor(beerId).photoPath;
    await _update(
      beerId,
      (current) => tried
          ? current.copyWith(
              tried: true,
              wishlist: false,
              triedAt: current.triedAt ?? DateTime.now(),
            )
          : current.withoutTasting(),
    );
    if (!tried && photoPath != null) {
      await TastingPhotoService.instance.delete(photoPath);
    }
  }

  /// Ajoute ou retire [beerId] de la liste "à goûter". L'y ajouter efface
  /// la dégustation (voir [setTried]) : les deux statuts sont mutuellement
  /// exclusifs.
  Future<void> setWishlist(String beerId, bool wishlist) async {
    final photoPath = statusFor(beerId).photoPath;
    await _update(
      beerId,
      (current) => wishlist
          ? current.withoutTasting().copyWith(wishlist: true)
          : current.copyWith(wishlist: false),
    );
    if (wishlist && photoPath != null) {
      await TastingPhotoService.instance.delete(photoPath);
    }
  }

  Future<void> setRating(String beerId, int? rating) =>
      _update(beerId, (current) => current.copyWith(rating: rating));

  /// Corrige manuellement la date de dégustation d'une bière déjà marquée
  /// comme bue.
  Future<void> setTriedAt(String beerId, DateTime date) async {
    if (!isTried(beerId)) return;
    await _update(beerId, (current) => current.copyWith(triedAt: date));
  }

  Future<void> setNote(String beerId, String? note) => _update(
    beerId,
    (current) => current.copyWith(
      note: (note == null || note.trim().isEmpty) ? null : note,
    ),
  );

  /// Met à jour la fiche de dégustation détaillée (critères de 1 à 5 et
  /// arômes), uniquement pour une bière marquée comme bue.
  Future<void> setTastingProfile(
    String beerId, {
    required int? color,
    required int? bitterness,
    required int? sweetness,
    required int? body,
    required List<String> aromas,
  }) async {
    if (!isTried(beerId)) return;
    await _update(
      beerId,
      (current) => current.copyWith(
        color: color,
        bitterness: bitterness,
        sweetness: sweetness,
        body: body,
        aromas: List.unmodifiable(aromas),
      ),
    );
  }

  /// Remplace (ou retire, avec `null`) la photo de dégustation. L'ancienne
  /// photo est supprimée du stockage une fois la collection à jour.
  Future<void> setPhotoPath(String beerId, String? photoPath) async {
    final previous = statusFor(beerId).photoPath;
    if (photoPath != null && !isTried(beerId)) return;
    await _update(beerId, (current) => current.copyWith(photoPath: photoPath));
    if (previous != null && previous != photoPath) {
      await TastingPhotoService.instance.delete(previous);
    }
  }

  /// Rattache le suivi de [from] à la bière [to] (bière personnelle
  /// acceptée au catalogue commun, voir `SubmissionService`). Si [to] a
  /// déjà un suivi, il est conservé tel quel. La photo suit la ligne : son
  /// chemin reste dans le dossier du même compte.
  Future<void> moveStatus({required String from, required String to}) async {
    final moved = _statuses.remove(from);
    if (moved == null) return;
    final adopted = !_statuses.containsKey(to);
    if (adopted) {
      _statuses[to] = moved;
    } else if (moved.photoPath != null &&
        moved.photoPath != _statuses[to]!.photoPath) {
      await TastingPhotoService.instance.delete(moved.photoPath!);
    }
    notifyListeners();
    await _persist();
    // L'ancienne ligne n'existe plus localement : son envoi la supprime.
    await _enqueue([if (adopted) to, from]);
  }

  List<String> get triedBeerIds =>
      _statuses.entries.where((e) => e.value.tried).map((e) => e.key).toList();

  List<String> get wishlistBeerIds => _statuses.entries
      .where((e) => e.value.wishlist)
      .map((e) => e.key)
      .toList();

  int get triedCount => triedBeerIds.length;

  /// L'identifiant de la bière la plus récemment dégustée (selon
  /// [triedAtFor]), ou `null` si aucune date n'est connue.
  String? get mostRecentTriedId {
    String? best;
    DateTime? bestDate;
    for (final entry in _statuses.entries) {
      final date = entry.value.triedAt;
      if (!entry.value.tried || date == null) continue;
      if (bestDate == null || date.isAfter(bestDate)) {
        bestDate = date;
        best = entry.key;
      }
    }
    return best;
  }

  double? get averageRating {
    final ratings = _statuses.values.map((s) => s.rating).whereType<int>();
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      for (final entry in _statuses.entries) entry.key: entry.value.toJson(),
    };
    await prefs.setString(_keyFor(_userId), jsonEncode(map));
  }

  bool get _canSync {
    final user = AuthService.instance.currentUser;
    return user != null && user.id == _userId;
  }

  Future<void> _enqueue(List<String> beerIds) async {
    if (_userId == null) return;
    for (final beerId in beerIds) {
      await syncQueue.mark(beerId);
    }
    // L'app n'attend pas le réseau : l'enregistrement local suffit.
    unawaited(flushPending());
  }

  Future<bool>? _flushing;

  /// Envoie les modifications en attente (voir [syncQueue]). Sans réseau,
  /// elles restent en file ; ne lève jamais d'exception. Renvoie `true` si
  /// tout est parti.
  Future<bool> flushPending() {
    if (!_canSync) return Future.value(syncQueue.pending.isEmpty);
    // Un seul envoi à la fois : un appel pendant l'envoi relance une
    // tournée juste après, pour prendre les dernières modifications.
    final running = _flushing;
    final next = (running ?? Future.value(true))
        .then((_) => syncQueue.flush(_send))
        .catchError((Object _) => false);
    _flushing = next;
    next.whenComplete(() {
      if (identical(_flushing, next)) _flushing = null;
    });
    return next;
  }

  /// Envoie la version locale de [beerId], ou supprime la ligne distante
  /// si elle n'existe plus localement.
  Future<void> _send(String beerId) async {
    final userId = _userId;
    if (!_canSync || userId == null) {
      throw StateError('Compte changé pendant la synchronisation');
    }
    final status = _statuses[beerId];
    final table = Supabase.instance.client.from(_table);
    if (status == null) {
      await table.delete().eq('user_id', userId).eq('beer_id', beerId);
    } else {
      await table.upsert(status.toRow(userId: userId, beerId: beerId));
    }
  }

  /// Envoie d'abord les modifications en attente, puis récupère les données
  /// de l'utilisateur connecté depuis Supabase (le serveur fait foi pour les
  /// bières qu'il connaît déjà, sauf celles encore en attente d'envoi) et
  /// pousse les entrées locales que le serveur n'a pas encore (ex. ajoutées
  /// avant la première connexion). Sans réseau, ne fait rien et ne lève pas
  /// d'exception : la copie locale reste utilisable.
  Future<void> syncWithRemote() async {
    final user = AuthService.instance.currentUser;
    if (user == null || user.id != _userId) return;

    await flushPending();
    final List<Map<String, dynamic>> rows;
    try {
      // Le filtre double la policy RLS : même mal configurée côté serveur,
      // l'app n'importera jamais les données d'un autre compte.
      rows = await Supabase.instance.client
          .from(_table)
          .select()
          .eq('user_id', user.id);
    } catch (error) {
      debugPrint('Synchronisation de la collection reportée : $error');
      return;
    }
    if (user.id != _userId) return;

    final remoteIds = <String>{};
    for (final row in rows) {
      final beerId = row['beer_id'] as String;
      remoteIds.add(beerId);
      if (syncQueue.isPending(beerId)) continue;
      _statuses[beerId] = BeerUserStatus.fromRow(row);
    }

    await _persist();
    notifyListeners();
    await _enqueue([
      for (final beerId in _statuses.keys)
        if (!remoteIds.contains(beerId)) beerId,
    ]);
  }
}
