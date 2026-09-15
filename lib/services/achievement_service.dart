import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import 'auth_service.dart';
import 'beer_collection_service.dart';
import 'collection_insights.dart';

/// Détecte les badges qui viennent d'être débloqués, pour que l'app joue
/// une animation (voir `showAchievementUnlocked`). Les badges déjà vus sont
/// mémorisés par compte : un badge n'est célébré qu'une seule fois.
///
/// À démarrer seulement une fois le catalogue chargé : calculés sur un
/// catalogue vide, aucun badge ne serait débloqué, et tous sembleraient
/// « nouveaux » à l'arrivée du catalogue.
class AchievementService {
  AchievementService._();

  static final AchievementService instance = AchievementService._();

  static const _prefsKey = 'bierodex.achievementsSeen.v1';

  final _unlocked = StreamController<Achievement>.broadcast();

  /// Chaque badge débloqué depuis le dernier passage, un événement par badge.
  Stream<Achievement> get unlocked => _unlocked.stream;

  bool _started = false;
  String? _userId;
  Set<String>? _seen;

  static String _keyFor(String userId) => '$_prefsKey.$userId';

  static Future<void> forgetUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(userId));
  }

  void start() {
    if (_started) return;
    _started = true;
    BeerCollectionService.instance.addListener(check);
    AuthService.instance.addListener(check);
    check();
  }

  Future<void> check() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) {
      _userId = null;
      _seen = null;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = {
      for (final achievement in _currentAchievements())
        if (achievement.unlocked) achievement.id,
    };

    if (_userId != userId || _seen == null) {
      _userId = userId;
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null) {
        // Premier passage sur cet appareil pour ce compte : les badges déjà
        // acquis sont enregistrés sans fête, sinon un utilisateur existant
        // verrait défiler toutes ses animations d'un coup.
        _seen = unlockedIds;
        await prefs.setString(_keyFor(userId), jsonEncode(_seen!.toList()));
        return;
      }
      _seen = {for (final id in jsonDecode(raw) as List<dynamic>) id as String};
    }

    final fresh = unlockedIds.difference(_seen!);
    if (fresh.isEmpty) return;
    _seen!.addAll(fresh);
    await prefs.setString(_keyFor(userId), jsonEncode(_seen!.toList()));
    for (final achievement in _currentAchievements()) {
      if (fresh.contains(achievement.id)) _unlocked.add(achievement);
    }
  }

  List<Achievement> _currentAchievements() => CollectionInsights(
        catalog: beers,
        statuses: BeerCollectionService.instance.statuses,
        styleOf: findStyleById,
      ).achievements;
}
