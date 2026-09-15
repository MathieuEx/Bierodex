import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/widgets.dart';

/// Fournisseur des tuiles de fond de carte, réglé comme les autres via
/// `--dart-define-from-file=env.json` :
/// - `MAP_TILE_URL` : modèle d'URL avec `{z}`, `{x}`, `{y}` (et la clé
///   d'API du fournisseur si besoin), par ex.
///   `https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=XXXX` ;
/// - `MAP_ATTRIBUTION` : mention exigée par ce fournisseur.
///
/// Laissés vides, on retombe sur les serveurs publics d'OpenStreetMap :
/// pratique en développement, mais leur politique d'usage
/// (https://operations.osmfoundation.org/policies/tiles) ne couvre pas une
/// app publiée à grande échelle.
class MapConfig {
  static const String _osmUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: _osmUrl,
  );

  static const String attribution = String.fromEnvironment(
    'MAP_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  /// Identifiant envoyé dans le User-Agent, exigé par OSM : doit
  /// correspondre au vrai identifiant de l'app (Android/iOS).
  static const String userAgentPackageName = 'com.bierodex.bierodex';

  /// Sur écran haute densité, le mode rétina charge les tuiles du niveau de
  /// zoom supérieur : sans lui, la carte du monde (zoom ~2) paraît floue et
  /// sans frontières ni noms.
  static TileLayer tileLayer(BuildContext context) => TileLayer(
    urlTemplate: tileUrl,
    userAgentPackageName: userAgentPackageName,
    retinaMode: RetinaMode.isHighDensity(context),
  );
}
