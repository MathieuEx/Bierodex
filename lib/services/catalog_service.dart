import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/beer_styles.dart' as beer_styles_data;
import '../data/beers.dart' as beers_data;
import '../data/brewery_locations.dart' as brewery_locations_data;
import '../models/beer.dart';
import '../models/beer_style.dart';
import '../models/brewery_location.dart';

/// Charge le catalogue (styles, bières, localisation des brasseries) depuis
/// Supabase et le garde en mémoire pour le reste de la session. Ce sont des
/// données publiques en lecture seule (voir les policies RLS de
/// `supabase/seed.sql`) : aucun utilisateur connecté n'est requis.
///
/// Une copie est mise en cache localement après chaque chargement réussi :
/// si le réseau n'est pas disponible au démarrage suivant, on retombe sur
/// cette copie plutôt que d'afficher un écran d'erreur, quitte à afficher
/// des données un peu datées.
class CatalogService {
  CatalogService._();

  static final CatalogService instance = CatalogService._();

  static const _cacheKey = 'bierodex.catalog.cache.v1';

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final client = Supabase.instance.client;

    try {
      final styleRows = await client.from('beer_styles').select();
      final beerRows = await client.from('beers').select();
      final breweryRows = await client.from('brewery_locations').select();

      _apply(
        styleRows: styleRows,
        beerRows: beerRows,
        breweryRows: breweryRows,
      );
      _loaded = true;
      unawaited(_cache(
        styleRows: styleRows,
        beerRows: beerRows,
        breweryRows: breweryRows,
      ));
    } catch (error) {
      final loadedFromCache = await _loadFromCache();
      if (!loadedFromCache) rethrow;
      _loaded = true;
    }
  }

  void _apply({
    required List<Map<String, dynamic>> styleRows,
    required List<Map<String, dynamic>> beerRows,
    required List<Map<String, dynamic>> breweryRows,
  }) {
    beer_styles_data.beerStyles = [
      for (final row in styleRows) BeerStyle.fromJson(row),
    ];
    beers_data.beers = [
      for (final row in beerRows) Beer.fromJson(row),
    ];
    brewery_locations_data.breweryLocations = {
      for (final row in breweryRows)
        row['brewery'] as String: BreweryLocation.fromJson(row),
    };
  }

  Future<void> _cache({
    required List<Map<String, dynamic>> styleRows,
    required List<Map<String, dynamic>> beerRows,
    required List<Map<String, dynamic>> breweryRows,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode({
        'styles': styleRows,
        'beers': beerRows,
        'breweries': breweryRows,
      }),
    );
  }

  Future<bool> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return false;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _apply(
      styleRows: (decoded['styles'] as List).cast<Map<String, dynamic>>(),
      beerRows: (decoded['beers'] as List).cast<Map<String, dynamic>>(),
      breweryRows:
          (decoded['breweries'] as List).cast<Map<String, dynamic>>(),
    );
    return true;
  }
}
