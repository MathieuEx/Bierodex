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
class CatalogService {
  CatalogService._();

  static final CatalogService instance = CatalogService._();

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final client = Supabase.instance.client;

    final styleRows = await client.from('beer_styles').select();
    final styles = [
      for (final row in styleRows) BeerStyle.fromJson(row),
    ];

    final beerRows = await client.from('beers').select();
    final beerList = [
      for (final row in beerRows) Beer.fromJson(row),
    ];

    final breweryRows = await client.from('brewery_locations').select();
    final locations = {
      for (final row in breweryRows)
        row['brewery'] as String: BreweryLocation.fromJson(row),
    };

    beer_styles_data.beerStyles = styles;
    beers_data.beers = beerList;
    brewery_locations_data.breweryLocations = locations;

    _loaded = true;
  }
}
