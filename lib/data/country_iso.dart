import 'package:interactive_world_map/interactive_world_map.dart';

/// Correspondance entre les noms de pays utilisés dans nos données
/// (lib/data/beers.dart) et les codes ISO alpha-2 utilisés par la carte
/// interactive. L'Écosse n'ayant pas de code ISO propre, elle est
/// rattachée au Royaume-Uni sur la carte.
const Map<String, CountryCode> countryNameToIso = {
  'Afrique du Sud': CountryCode.ZA,
  'Allemagne': CountryCode.DE,
  'Argentine': CountryCode.AR,
  'Aruba': CountryCode.AW,
  'Australie': CountryCode.AU,
  'Belgique': CountryCode.BE,
  'Brésil': CountryCode.BR,
  'Canada': CountryCode.CA,
  'Chili': CountryCode.CL,
  'Chine': CountryCode.CN,
  'Colombie': CountryCode.CO,
  'Corée du Sud': CountryCode.KR,
  'Costa Rica': CountryCode.CR,
  'Croatie': CountryCode.HR,
  'Cuba': CountryCode.CU,
  'Danemark': CountryCode.DK,
  'Espagne': CountryCode.ES,
  'Finlande': CountryCode.FI,
  'France': CountryCode.FR,
  'Grèce': CountryCode.GR,
  'Inde': CountryCode.IN,
  'Indonésie': CountryCode.ID,
  'Irlande': CountryCode.IE,
  'Italie': CountryCode.IT,
  'Jamaïque': CountryCode.JM,
  'Japon': CountryCode.JP,
  'Kenya': CountryCode.KE,
  'Laos': CountryCode.LA,
  'Liban': CountryCode.LB,
  'Lituanie': CountryCode.LT,
  'Mexique': CountryCode.MX,
  'Namibie': CountryCode.NA,
  'Nigeria': CountryCode.NG,
  'Nouvelle-Zélande': CountryCode.NZ,
  'Pays-Bas': CountryCode.NL,
  'Pologne': CountryCode.PL,
  'Royaume-Uni': CountryCode.GB,
  'Russie': CountryCode.RU,
  'Rwanda': CountryCode.RW,
  'République dominicaine': CountryCode.DO,
  'République tchèque': CountryCode.CZ,
  'Singapour': CountryCode.SG,
  'Sri Lanka': CountryCode.LK,
  'Thaïlande': CountryCode.TH,
  'Turquie': CountryCode.TR,
  'Vietnam': CountryCode.VN,
  'Écosse': CountryCode.GB,
  'États-Unis': CountryCode.US,
};

/// Réciproque : pour un id de carte donné (résultat de [defaultMapIdResolver]
/// appliqué à un code ISO), la ou les entrées de [countryNameToIso] qui s'y
/// rattachent (plusieurs quand deux pays de nos données partagent le même
/// contour, comme Royaume-Uni/Écosse).
Map<String, List<String>> _buildMapIdToCountryNames() {
  final result = <String, List<String>>{};
  for (final entry in countryNameToIso.entries) {
    final mapId = defaultMapIdResolver(entry.value.name) ?? entry.value.name;
    result.putIfAbsent(mapId, () => []).add(entry.key);
  }
  return result;
}

final Map<String, List<String>> mapIdToCountryNames =
    _buildMapIdToCountryNames();

/// Les ids de carte (déjà résolus) de tous les pays présents dans nos
/// données, à passer directement à [WorldMapController.highlightedIds] ou
/// à `visibleCountryIds`.
final Set<String> allDataMapIds = countryNameToIso.values.toSet().toMapIds();
