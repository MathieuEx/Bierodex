import '../models/beer_style.dart';

/// Taxonomie des grands styles de bières, regroupés par famille de
/// fermentation. Ce n'est pas exhaustif (il existe des centaines de
/// variantes régionales), mais ça couvre les familles reconnues par le
/// BJCP et les principales traditions brassicoles.
const List<BeerStyle> beerStyles = [
  // --- Fermentation basse (Lager) ---
  BeerStyle(
    id: 'pilsner',
    name: 'Pilsner',
    family: BeerFamily.lagerBasse,
    origin: 'République tchèque',
    abvRange: '4,2 – 5,4 %',
    description:
        'Lager blonde et sèche, houblonnée noblement, née à Plzeň en 1842. '
        'La référence des lagers claires modernes.',
  ),
  BeerStyle(
    id: 'euroPaleLager',
    name: 'Pale Lager européenne',
    family: BeerFamily.lagerBasse,
    origin: 'Europe',
    abvRange: '4,5 – 5,8 %',
    description:
        'Lager blonde légère et facile à boire, produite à grande échelle '
        'partout en Europe, dérivée du style Pilsner mais plus neutre.',
  ),
  BeerStyle(
    id: 'helles',
    name: 'Munich Helles',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne (Bavière)',
    abvRange: '4,7 – 5,4 %',
    description:
        'Lager blonde maltée et ronde de Munich, moins amère que la '
        'Pilsner, pensée pour être bue en grande quantité.',
  ),
  BeerStyle(
    id: 'dunkel',
    name: 'Munich Dunkel',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne (Bavière)',
    abvRange: '4,5 – 6 %',
    description:
        'Lager brune maltée, notes de pain grillé et de caramel léger, '
        'sans amertume marquée.',
  ),
  BeerStyle(
    id: 'schwarzbier',
    name: 'Schwarzbier',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne',
    abvRange: '3,8 – 5 %',
    description:
        'Lager noire douce, torréfiée mais sans l\'amertume d\'un stout, '
        'légère en bouche malgré sa couleur.',
  ),
  BeerStyle(
    id: 'marzen',
    name: 'Märzen / Oktoberfest',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne (Bavière)',
    abvRange: '5,6 – 6 %',
    description:
        'Lager ambrée, maltée et ronde, brassée traditionnellement en '
        'mars et servie à l\'Oktoberfest de Munich.',
  ),
  BeerStyle(
    id: 'vienna',
    name: 'Vienna Lager',
    family: BeerFamily.lagerBasse,
    origin: 'Autriche',
    abvRange: '4,5 – 5,5 %',
    description:
        'Lager ambrée élégante, malt légèrement toasté, amertume modérée. '
        'Ancêtre indirect de nombreuses lagers mexicaines.',
  ),
  BeerStyle(
    id: 'bock',
    name: 'Bock / Doppelbock',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne',
    abvRange: '6,3 – 12 %',
    description:
        'Lager forte et maltée, du Bock classique au Doppelbock plus '
        'corsé encore, brassée historiquement par des moines bavarois.',
  ),
  BeerStyle(
    id: 'americanLager',
    name: 'American / Adjunct Lager',
    family: BeerFamily.lagerBasse,
    origin: 'États-Unis',
    abvRange: '4,2 – 5 %',
    description:
        'Lager très légère utilisant du maïs ou du riz en complément du '
        'malt d\'orge, peu amère, très rafraîchissante.',
  ),

  // --- Fermentation haute (Ale) ---
  BeerStyle(
    id: 'paleAle',
    name: 'Pale Ale',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '4,5 – 6,2 %',
    description:
        'Ale ambrée équilibrée entre malt et houblon, plus douce que son '
        'dérivé l\'IPA.',
  ),
  BeerStyle(
    id: 'ipa',
    name: 'India Pale Ale (IPA)',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni / États-Unis',
    abvRange: '5,5 – 7,5 %',
    description:
        'Ale très houblonnée, à l\'origine surhoublonnée pour survivre au '
        'transport vers l\'Inde coloniale, aujourd\'hui déclinée à l\'infini '
        '(NEIPA, Double IPA, Session IPA...).',
  ),
  BeerStyle(
    id: 'bitter',
    name: 'Bitter / ESB',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '3,8 – 5,8 %',
    description:
        'Ale anglaise traditionnelle de pub, équilibrée, faiblement '
        'carbonatée, souvent servie en fût à température de cave.',
  ),
  BeerStyle(
    id: 'brownAle',
    name: 'Brown Ale',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '4 – 6 %',
    description:
        'Ale brune aux notes de noisette et de caramel, peu amère, '
        'facile à boire.',
  ),
  BeerStyle(
    id: 'porter',
    name: 'Porter',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '4 – 6,5 %',
    description:
        'Ale sombre torréfiée née à Londres au XVIIIe siècle, ancêtre du '
        'Stout, notes de chocolat et de café.',
  ),
  BeerStyle(
    id: 'stout',
    name: 'Stout',
    family: BeerFamily.aleHaute,
    origin: 'Irlande',
    abvRange: '4 – 8 %',
    description:
        'Ale noire brassée avec de l\'orge torréfiée, texture crémeuse, '
        'amertume de café et de chocolat noir.',
  ),
  BeerStyle(
    id: 'barleywine',
    name: 'Barleywine',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '8 – 12 %',
    description:
        'Ale très forte et très maltée, à garder en cave, aussi complexe '
        'qu\'un vin.',
  ),
  BeerStyle(
    id: 'scotchAle',
    name: 'Scotch Ale / Wee Heavy',
    family: BeerFamily.aleHaute,
    origin: 'Écosse',
    abvRange: '6,5 – 10 %',
    description:
        'Ale écossaise forte, très maltée, peu houblonnée, souvent avec '
        'une pointe de fumé.',
  ),
  BeerStyle(
    id: 'belgianBlonde',
    name: 'Blonde belge',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '6 – 7,5 %',
    description:
        'Ale blonde belge ronde et épicée par la levure, sucrosité '
        'maîtrisée par une finale sèche.',
  ),
  BeerStyle(
    id: 'belgianDubbel',
    name: 'Dubbel',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '6 – 7,6 %',
    description:
        'Ale brune belge d\'abbaye, notes de fruits secs, de caramel et '
        'd\'épices, héritée des brasseries trappistes.',
  ),
  BeerStyle(
    id: 'belgianTripel',
    name: 'Tripel',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '7,5 – 9,5 %',
    description:
        'Ale blonde belge forte, sèche et épicée, trompeusement facile à '
        'boire vu son degré d\'alcool.',
  ),
  BeerStyle(
    id: 'belgianStrongGolden',
    name: 'Strong Golden Ale',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '7,5 – 10,5 %',
    description:
        'Ale belge forte, blonde et pétillante, très sèche en finale '
        'malgré un fort degré d\'alcool.',
  ),
  BeerStyle(
    id: 'saison',
    name: 'Saison',
    family: BeerFamily.aleHaute,
    origin: 'Belgique (Wallonie)',
    abvRange: '5 – 8,5 %',
    description:
        'Ale fermière belge, sèche, épicée et rafraîchissante, brassée à '
        'l\'origine pour désaltérer les saisonniers agricoles.',
  ),
  BeerStyle(
    id: 'witbier',
    name: 'Witbier / Blanche',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '4,5 – 5,5 %',
    description:
        'Ale de blé non filtrée, épicée à la coriandre et à l\'écorce '
        'd\'orange amère, trouble et désaltérante.',
  ),
  BeerStyle(
    id: 'weissbier',
    name: 'Weissbier / Hefeweizen',
    family: BeerFamily.aleHaute,
    origin: 'Allemagne (Bavière)',
    abvRange: '4,9 – 5,6 %',
    description:
        'Ale de blé bavaroise, levure caractéristique aux notes de banane '
        'et de clou de girofle.',
  ),

  // --- Fermentation spontanée ---
  BeerStyle(
    id: 'lambic',
    name: 'Lambic',
    family: BeerFamily.spontanee,
    origin: 'Belgique (Pajottenland)',
    abvRange: '5 – 6,5 %',
    description:
        'Bière fermentée spontanément par les levures et bactéries '
        'sauvages de la vallée de la Senne, acidulée et complexe.',
  ),
  BeerStyle(
    id: 'gueuze',
    name: 'Gueuze',
    family: BeerFamily.spontanee,
    origin: 'Belgique',
    abvRange: '5 – 8 %',
    description:
        'Assemblage de lambics jeunes et vieux, refermentés en '
        'bouteille, effervescent et très acidulé.',
  ),
  BeerStyle(
    id: 'fruitLambic',
    name: 'Lambic fruité (Kriek, Framboise...)',
    family: BeerFamily.spontanee,
    origin: 'Belgique',
    abvRange: '3,5 – 7 %',
    description:
        'Lambic mis à macérer sur fruits (cerise, framboise...), acidulé '
        'et fruité.',
  ),

  // --- Fermentation mixte ---
  BeerStyle(
    id: 'flandersRed',
    name: 'Flanders Red / Oud Bruin',
    family: BeerFamily.mixte,
    origin: 'Belgique (Flandre)',
    abvRange: '4,6 – 6,5 %',
    description:
        'Ale rouge-brune vieillie en fût de bois, fermentation mixte '
        '(levure + bactéries), acidité vineuse et notes de fruits rouges.',
  ),
];

BeerStyle? findStyleById(String id) {
  for (final style in beerStyles) {
    if (style.id == id) return style;
  }
  return null;
}

List<BeerStyle> stylesForFamily(BeerFamily family) =>
    beerStyles.where((s) => s.family == family).toList();
