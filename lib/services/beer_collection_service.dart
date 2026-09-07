import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/beer_user_status.dart';
import 'auth_service.dart';

/// Suivi personnel des bières (essayées / notées). Toujours persisté
/// localement sur l'appareil ; synchronisé en plus avec Supabase quand
/// l'utilisateur est connecté (voir [AuthService]).
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

  int? ratingFor(String beerId) => statusFor(beerId).rating;

  Future<void> setTried(String beerId, bool tried) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(tried: tried, rating: current.rating);
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  Future<void> setRating(String beerId, int? rating) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(tried: current.tried, rating: rating);
    notifyListeners();
    await _persist();
    await _pushRemote(beerId);
  }

  List<String> get triedBeerIds => _statuses.entries
      .where((e) => e.value.tried)
      .map((e) => e.key)
      .toList();

  int get triedCount => triedBeerIds.length;

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
      'rating': status.rating,
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
      _statuses[beerId] = BeerUserStatus(
        tried: row['tried'] as bool? ?? false,
        rating: row['rating'] as int?,
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
            'rating': entry.value.rating,
          },
      ]);
    }

    await _persist();
    notifyListeners();
  }
}
