import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/beers.dart' as beers_data;
import '../models/beer.dart';
import 'auth_service.dart';
import 'sync_queue.dart';

/// Bières ajoutées à la main par l'utilisateur, typiquement après un scan
/// de code-barres sans correspondance dans le catalogue partagé (voir
/// `lib/screens/add_beer_screen.dart`). Contrairement au catalogue chargé
/// par [CatalogService], ce sont des données privées : toujours persistées
/// localement, synchronisées avec Supabase (table `user_beers`, RLS
/// restreinte au propriétaire) quand l'utilisateur est connecté.
///
/// Après chargement, chaque bière personnelle est fusionnée dans
/// [beers_data.beers] (avec [Beer.isCustom] à `true`) : le reste de l'app
/// (recherche, fiche détail, collection...) n'a donc rien de spécial à
/// faire pour les afficher.
///
/// Comme pour `BeerCollectionService`, les ajouts et suppressions faits
/// hors-ligne sont mis en file d'attente ([syncQueue]) et envoyés au retour
/// du réseau.
class UserBeerService extends ChangeNotifier {
  UserBeerService._() {
    AuthService.instance.addListener(_onAuthChanged);
  }

  static final UserBeerService instance = UserBeerService._();

  static const _prefsKey = 'bierodex.userBeers.v1';
  static const _table = 'user_beers';
  static const _uuid = Uuid();

  final Map<String, Beer> _beers = {};

  /// Bières ajoutées ou supprimées localement, pas encore confirmées par
  /// Supabase.
  final SyncQueue syncQueue = SyncQueue(_table);
  bool _loaded = false;

  /// Compte dont [_beers] contient les ajouts (`null` : personne).
  String? _userId;

  bool get isLoaded => _loaded;

  /// Un cache local par compte, pour la même raison que
  /// `BeerCollectionService` : ne jamais mélanger les données de deux
  /// comptes qui se succèdent sur le même appareil.
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
    if (_loaded) {
      _mergeIntoCatalog();
      return;
    }
    await _loadFor(AuthService.instance.currentUser?.id);
    _loaded = true;
    _mergeIntoCatalog();
    notifyListeners();
    // La copie locale suffit pour démarrer : la synchronisation se fait en
    // arrière-plan et ne bloque pas l'app sur un réseau lent.
    if (_userId != null) unawaited(syncWithRemote());
  }

  Future<void> _loadFor(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    _userId = userId;
    _beers.clear();
    await syncQueue.load(userId);
    var raw = prefs.getString(_keyFor(userId));
    // Ajouts faits avant la connexion obligatoire : rattachés une seule
    // fois au premier compte qui se connecte sur cet appareil.
    if (raw == null && userId != null) {
      raw = prefs.getString(_prefsKey);
      await prefs.remove(_prefsKey);
    }
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final row in decoded) {
        final beer = Beer.fromJson(row as Map<String, dynamic>, isCustom: true);
        _beers[beer.id] = beer;
      }
      if (userId != null) await _persist();
    }
  }

  Future<void> _onAuthChanged() async {
    final userId = AuthService.instance.currentUser?.id;
    if (!_loaded || userId == _userId) return;
    await _loadFor(userId);
    _mergeIntoCatalog();
    notifyListeners();
    if (userId != null) await syncWithRemote();
  }

  /// Ajoute une bière au carnet personnel de l'utilisateur et la fusionne
  /// immédiatement dans le catalogue affiché par l'app.
  Future<Beer> addBeer({
    required String name,
    required String brewery,
    required String country,
    required String styleId,
    required double abv,
    required String description,
    String? barcode,
    String? imageUrl,
    String? imageCredit,
  }) async {
    final beer = Beer(
      id: 'custom-${_uuid.v4()}',
      name: name,
      brewery: brewery,
      country: country,
      styleId: styleId,
      abv: abv,
      description: description,
      imageUrl: imageUrl,
      imageCredit: imageCredit,
      barcode: barcode,
      isCustom: true,
    );
    _beers[beer.id] = beer;
    _mergeIntoCatalog();
    notifyListeners();
    await _persist();
    await _enqueue([beer.id]);
    return beer;
  }

  Future<void> removeBeer(String id) async {
    if (_beers.remove(id) == null) return;
    _mergeIntoCatalog();
    notifyListeners();
    await _persist();
    await _enqueue([id]);
  }

  /// Remplace les bières personnelles de [beers_data.beers] par la
  /// dernière version connue (le catalogue partagé n'est pas touché).
  void _mergeIntoCatalog() {
    beers_data.beers = [
      for (final beer in beers_data.beers)
        if (!beer.isCustom) beer,
      ..._beers.values,
    ];
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(_userId),
      jsonEncode([for (final beer in _beers.values) beer.toJson()]),
    );
  }

  bool get _canSync {
    final user = AuthService.instance.currentUser;
    return user != null && user.id == _userId;
  }

  Future<void> _enqueue(List<String> ids) async {
    if (_userId == null) return;
    for (final id in ids) {
      await syncQueue.mark(id);
    }
    unawaited(flushPending());
  }

  Future<bool>? _flushing;

  /// Envoie les ajouts et suppressions en attente (voir [syncQueue]). Ne
  /// lève jamais d'exception ; renvoie `true` si tout est parti.
  Future<bool> flushPending() {
    if (!_canSync) return Future.value(syncQueue.pending.isEmpty);
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

  Future<void> _send(String id) async {
    final userId = _userId;
    if (!_canSync || userId == null) {
      throw StateError('Compte changé pendant la synchronisation');
    }
    final table = Supabase.instance.client.from(_table);
    final beer = _beers[id];
    if (beer == null) {
      await table.delete().eq('id', id).eq('user_id', userId);
      return;
    }
    await table.upsert({
      'id': beer.id,
      'user_id': userId,
      'name': beer.name,
      'brewery': beer.brewery,
      'country': beer.country,
      'style_id': beer.styleId,
      'abv': beer.abv,
      'description': beer.description,
      'barcode': beer.barcode,
      'image_url': beer.imageUrl,
      'image_credit': beer.imageCredit,
    });
  }

  /// Envoie d'abord les modifications en attente, puis récupère les bières
  /// personnelles de l'utilisateur connecté depuis Supabase (le serveur fait
  /// foi) et pousse celles qu'il ne connaît pas encore (ajoutées avant la
  /// première connexion). Sans réseau, ne fait rien et ne lève pas
  /// d'exception.
  Future<void> syncWithRemote() async {
    final user = AuthService.instance.currentUser;
    if (user == null || user.id != _userId) return;

    await flushPending();
    final List<Map<String, dynamic>> rows;
    try {
      rows = await Supabase.instance.client
          .from(_table)
          .select()
          .eq('user_id', user.id);
    } catch (error) {
      debugPrint('Synchronisation des bières personnelles reportée : $error');
      return;
    }
    if (user.id != _userId) return;

    final remoteIds = <String>{};
    for (final row in rows) {
      final beer = Beer.fromJson(row, isCustom: true);
      remoteIds.add(beer.id);
      // Supprimée hors-ligne, pas encore confirmée : ne pas la ressusciter.
      if (syncQueue.isPending(beer.id)) continue;
      _beers[beer.id] = beer;
    }

    _mergeIntoCatalog();
    await _persist();
    notifyListeners();
    await _enqueue([
      for (final id in _beers.keys)
        if (!remoteIds.contains(id)) id,
    ]);
  }
}
