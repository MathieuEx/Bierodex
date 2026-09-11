import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/beers.dart' as beers_data;
import '../models/beer.dart';
import 'auth_service.dart';

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
class UserBeerService extends ChangeNotifier {
  UserBeerService._() {
    AuthService.instance.addListener(_onAuthChanged);
  }

  static final UserBeerService instance = UserBeerService._();

  static const _prefsKey = 'bierodex.userBeers.v1';
  static const _table = 'user_beers';
  static const _uuid = Uuid();

  final Map<String, Beer> _beers = {};
  bool _loaded = false;
  bool _wasSignedIn = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      _mergeIntoCatalog();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final row in decoded) {
        final beer = Beer.fromJson(row as Map<String, dynamic>, isCustom: true);
        _beers[beer.id] = beer;
      }
    }
    _loaded = true;
    _wasSignedIn = AuthService.instance.isSignedIn;
    _mergeIntoCatalog();
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
    await _pushRemote(beer);
    return beer;
  }

  Future<void> removeBeer(String id) async {
    if (_beers.remove(id) == null) return;
    _mergeIntoCatalog();
    notifyListeners();
    await _persist();
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await Supabase.instance.client
        .from(_table)
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
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
      _prefsKey,
      jsonEncode([for (final beer in _beers.values) beer.toJson()]),
    );
  }

  Future<void> _pushRemote(Beer beer) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from(_table).upsert({
      'id': beer.id,
      'user_id': user.id,
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

  /// Récupère les bières personnelles de l'utilisateur connecté depuis
  /// Supabase (le serveur fait foi) et pousse celles qu'il ne connaît pas
  /// encore (ajoutées hors-ligne ou avant la première connexion).
  Future<void> syncWithRemote() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final rows = await Supabase.instance.client
        .from(_table)
        .select()
        .eq('user_id', user.id);
    final remoteIds = <String>{};
    for (final row in rows) {
      final beer = Beer.fromJson(row, isCustom: true);
      remoteIds.add(beer.id);
      _beers[beer.id] = beer;
    }

    final toPush =
        _beers.values.where((beer) => !remoteIds.contains(beer.id)).toList();
    for (final beer in toPush) {
      await _pushRemote(beer);
    }

    _mergeIntoCatalog();
    await _persist();
    notifyListeners();
  }
}
