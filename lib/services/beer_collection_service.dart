import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/beer_user_status.dart';
import 'auth_service.dart';

/// Suivi personnel des bières (essayées / à goûter / notées / commentées).
/// Toujours persisté localement sur l'appareil ; synchronisé en plus avec
/// Supabase quand l'utilisateur est connecté (voir [AuthService]).
class BeerCollectionService extends ChangeNotifier {
  BeerCollectionService._() {
    AuthService.instance.addListener(_onAuthChanged);
  }

  static final BeerCollectionService instance = BeerCollectionService._();

  static const _prefsKey = 'bierodex.collection.v1';
  static const _table = 'beer_status';

  final Map<String, BeerUserStatus> _statuses = {};
  bool _loaded = false;
  bool _wasSignedIn = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _statuses[entry.key] =
            BeerUserStatus.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    _loaded = true;
    _wasSignedIn = AuthService.instance.isSignedIn;
    notifyListeners();
    if (_wasSignedIn) {
      await syncWithRemote();
    }
  }

  void _onAuthChanged() {
    final signedIn = AuthService.instance.isSignedIn;
    if (signedIn && !_wasSignedIn) {
      syncWithRemote();
    }
    _wasSignedIn = signedIn;
  }

  BeerUserStatus statusFor(String beerId) =>
      _statuses[beerId] ?? const BeerUserStatus();

  bool isTried(String beerId) => statusFor(beerId).tried;

  bool isWishlist(String beerId) => statusFor(beerId).wishlist;

  int? ratingFor(String beerId) => statusFor(beerId).rating;

  DateTime? triedAtFor(String beerId) => statusFor(beerId).triedAt;

  String? noteFor(String beerId) => statusFor(beerId).note;

  /// Marque [beerId] comme bue ou non. La marquer comme bue l'enlève de la
  /// liste "à goûter" et horodate la dégustation (sauf si une date était
  /// déjà connue) ; revenir en arrière efface la date et la note.
  Future<void> setTried(String beerId, bool tried) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(
      tried: tried,
      wishlist: tried ? false : current.wishlist,
      rating: tried ? current.rating : null,
      triedAt: tried ? (current.triedAt ?? DateTime.now()) : null,
      note: tried ? current.note : null,
    );
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  /// Ajoute ou retire [beerId] de la liste "à goûter". L'y ajouter la
  /// retire du statut "bue" (note, date et statut effacés) : les deux
  /// statuts sont mutuellement exclusifs, comme [setTried].
  Future<void> setWishlist(String beerId, bool wishlist) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(
      tried: wishlist ? false : current.tried,
      wishlist: wishlist,
      rating: wishlist ? null : current.rating,
      triedAt: wishlist ? null : current.triedAt,
      note: wishlist ? null : current.note,
    );
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  Future<void> setRating(String beerId, int? rating) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(
      tried: current.tried,
      wishlist: current.wishlist,
      rating: rating,
      triedAt: current.triedAt,
      note: current.note,
    );
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  /// Corrige manuellement la date de dégustation d'une bière déjà marquée
  /// comme bue.
  Future<void> setTriedAt(String beerId, DateTime date) async {
    final current = statusFor(beerId);
    if (!current.tried) return;
    _statuses[beerId] = BeerUserStatus(
      tried: current.tried,
      wishlist: current.wishlist,
      rating: current.rating,
      triedAt: date,
      note: current.note,
    );
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  Future<void> setNote(String beerId, String? note) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(
      tried: current.tried,
      wishlist: current.wishlist,
      rating: current.rating,
      triedAt: current.triedAt,
      note: (note == null || note.trim().isEmpty) ? null : note,
    );
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  List<String> get triedBeerIds => _statuses.entries
      .where((e) => e.value.tried)
      .map((e) => e.key)
      .toList();

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
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  /// Envoie une entrée vers Supabase si l'utilisateur est connecté.
  Future<void> _pushRemote(String beerId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final status = _statuses[beerId];
    if (status == null) return;
    await Supabase.instance.client.from(_table).upsert({
      'user_id': user.id,
      'beer_id': beerId,
      'tried': status.tried,
      'wishlist': status.wishlist,
      'rating': status.rating,
      'tried_at': status.triedAt?.toIso8601String(),
      'note': status.note,
    });
  }

  /// Récupère les données de l'utilisateur connecté depuis Supabase (le
  /// serveur fait foi pour les bières qu'il connaît déjà) et pousse les
  /// entrées locales que le serveur n'a pas encore (ex. ajoutées hors-ligne
  /// ou avant la première connexion).
  Future<void> syncWithRemote() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final rows = await Supabase.instance.client.from(_table).select();
    final remoteIds = <String>{};
    for (final row in rows) {
      final beerId = row['beer_id'] as String;
      remoteIds.add(beerId);
      final triedAtRaw = row['tried_at'] as String?;
      _statuses[beerId] = BeerUserStatus(
        tried: row['tried'] as bool? ?? false,
        wishlist: row['wishlist'] as bool? ?? false,
        rating: row['rating'] as int?,
        triedAt: triedAtRaw != null ? DateTime.tryParse(triedAtRaw) : null,
        note: row['note'] as String?,
      );
    }

    final toPush =
        _statuses.entries.where((e) => !remoteIds.contains(e.key)).toList();
    if (toPush.isNotEmpty) {
      await Supabase.instance.client.from(_table).upsert([
        for (final entry in toPush)
          {
            'user_id': user.id,
            'beer_id': entry.key,
            'tried': entry.value.tried,
            'wishlist': entry.value.wishlist,
            'rating': entry.value.rating,
            'tried_at': entry.value.triedAt?.toIso8601String(),
            'note': entry.value.note,
          },
      ]);
    }

    await _persist();
    notifyListeners();
  }
}
