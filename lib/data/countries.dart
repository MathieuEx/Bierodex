import '../l10n/l10n.dart';

/// Continent de chaque pays du catalogue (noms en français, tels que
/// stockés dans `beers.country`). Sert aux badges « Tour d'Europe » et
/// « Tour du monde » : un pays absent de cette table n'est simplement
/// compté dans aucun continent.
const countryContinents = <String, String>{
  // Europe
  'Allemagne': 'Europe',
  'Autriche': 'Europe',
  'Belgique': 'Europe',
  'Croatie': 'Europe',
  'Danemark': 'Europe',
  'Écosse': 'Europe',
  'Espagne': 'Europe',
  'Estonie': 'Europe',
  'Finlande': 'Europe',
  'France': 'Europe',
  'Grèce': 'Europe',
  'Hongrie': 'Europe',
  'Irlande': 'Europe',
  'Islande': 'Europe',
  'Italie': 'Europe',
  'Lettonie': 'Europe',
  'Lituanie': 'Europe',
  'Luxembourg': 'Europe',
  'Norvège': 'Europe',
  'Pays de Galles': 'Europe',
  'Pays-Bas': 'Europe',
  'Pologne': 'Europe',
  'Portugal': 'Europe',
  'République tchèque': 'Europe',
  'Roumanie': 'Europe',
  'Royaume-Uni': 'Europe',
  'Russie': 'Europe',
  'Slovaquie': 'Europe',
  'Slovénie': 'Europe',
  'Suède': 'Europe',
  'Suisse': 'Europe',
  'Ukraine': 'Europe',
  // Amériques
  'Argentine': 'Amériques',
  'Aruba': 'Amériques',
  'Brésil': 'Amériques',
  'Canada': 'Amériques',
  'Chili': 'Amériques',
  'Colombie': 'Amériques',
  'Costa Rica': 'Amériques',
  'Cuba': 'Amériques',
  'États-Unis': 'Amériques',
  'Jamaïque': 'Amériques',
  'Mexique': 'Amériques',
  'Pérou': 'Amériques',
  'République dominicaine': 'Amériques',
  // Asie
  'Chine': 'Asie',
  'Corée du Sud': 'Asie',
  'Inde': 'Asie',
  'Indonésie': 'Asie',
  'Japon': 'Asie',
  'Laos': 'Asie',
  'Liban': 'Asie',
  'Philippines': 'Asie',
  'Singapour': 'Asie',
  'Sri Lanka': 'Asie',
  'Thaïlande': 'Asie',
  'Turquie': 'Asie',
  'Vietnam': 'Asie',
  // Afrique
  'Afrique du Sud': 'Afrique',
  'Éthiopie': 'Afrique',
  'Kenya': 'Afrique',
  'Maroc': 'Afrique',
  'Namibie': 'Afrique',
  'Nigeria': 'Afrique',
  'Rwanda': 'Afrique',
  // Océanie
  'Australie': 'Océanie',
  'Nouvelle-Zélande': 'Océanie',
};

/// Nom anglais des pays du catalogue. Le nom français reste la clé stockée
/// (`beers.country`) : seul l'affichage est traduit.
const _countryNamesEn = <String, String>{
  'Allemagne': 'Germany',
  'Autriche': 'Austria',
  'Belgique': 'Belgium',
  'Croatie': 'Croatia',
  'Danemark': 'Denmark',
  'Écosse': 'Scotland',
  'Espagne': 'Spain',
  'Estonie': 'Estonia',
  'Finlande': 'Finland',
  'France': 'France',
  'Grèce': 'Greece',
  'Hongrie': 'Hungary',
  'Irlande': 'Ireland',
  'Islande': 'Iceland',
  'Italie': 'Italy',
  'Lettonie': 'Latvia',
  'Lituanie': 'Lithuania',
  'Luxembourg': 'Luxembourg',
  'Norvège': 'Norway',
  'Pays de Galles': 'Wales',
  'Pays-Bas': 'Netherlands',
  'Pologne': 'Poland',
  'Portugal': 'Portugal',
  'République tchèque': 'Czech Republic',
  'Roumanie': 'Romania',
  'Royaume-Uni': 'United Kingdom',
  'Russie': 'Russia',
  'Slovaquie': 'Slovakia',
  'Slovénie': 'Slovenia',
  'Suède': 'Sweden',
  'Suisse': 'Switzerland',
  'Ukraine': 'Ukraine',
  'Argentine': 'Argentina',
  'Aruba': 'Aruba',
  'Brésil': 'Brazil',
  'Canada': 'Canada',
  'Chili': 'Chile',
  'Colombie': 'Colombia',
  'Costa Rica': 'Costa Rica',
  'Cuba': 'Cuba',
  'États-Unis': 'United States',
  'Jamaïque': 'Jamaica',
  'Mexique': 'Mexico',
  'Pérou': 'Peru',
  'République dominicaine': 'Dominican Republic',
  'Chine': 'China',
  'Corée du Sud': 'South Korea',
  'Inde': 'India',
  'Indonésie': 'Indonesia',
  'Japon': 'Japan',
  'Laos': 'Laos',
  'Liban': 'Lebanon',
  'Philippines': 'Philippines',
  'Singapour': 'Singapore',
  'Sri Lanka': 'Sri Lanka',
  'Thaïlande': 'Thailand',
  'Turquie': 'Turkey',
  'Vietnam': 'Vietnam',
  'Afrique du Sud': 'South Africa',
  'Éthiopie': 'Ethiopia',
  'Kenya': 'Kenya',
  'Maroc': 'Morocco',
  'Namibie': 'Namibia',
  'Nigeria': 'Nigeria',
  'Rwanda': 'Rwanda',
  'Australie': 'Australia',
  'Nouvelle-Zélande': 'New Zealand',
  // Bière ajoutée à la main sans pays.
  'Inconnu': 'Unknown',
};

const _continentNamesEn = <String, String>{
  'Europe': 'Europe',
  'Amériques': 'Americas',
  'Asie': 'Asia',
  'Afrique': 'Africa',
  'Océanie': 'Oceania',
};

/// Nom d'un pays (clé française du catalogue) dans la langue de l'app. Un
/// pays inconnu de la table (bière ajoutée à la main) s'affiche tel quel.
String countryName(String country) => L10n.locale.languageCode == 'fr'
    ? country
    : _countryNamesEn[country] ?? country;

/// Nom d'un continent (valeur de [countryContinents]) dans la langue de
/// l'app.
String continentName(String continent) => L10n.locale.languageCode == 'fr'
    ? continent
    : _continentNamesEn[continent] ?? continent;
