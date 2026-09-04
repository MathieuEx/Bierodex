import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beer_user_status.dart';

/// Suivi personnel des bières (essayées / notées), persisté localement sur
/// l'appareil (pas de compte, pas de synchronisation).
class BeerCollectionService extends ChangeNotifier {
  BeerCollectionService._();

  static final BeerCollectionService instance = BeerCollectionService._();

  static const _prefsKey = 'bierodex.collection.v1';

  final Map<String, BeerUserStatus> _statuses = {};
  bool _loaded = false;

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
    notifyListeners();
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
  }

  Future<void> setRating(String beerId, int? rating) async {
    final current = statusFor(beerId);
    _statuses[beerId] = BeerUserStatus(tried: current.tried, rating: rating);
    notifyListeners();
    await _persist();
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
}
