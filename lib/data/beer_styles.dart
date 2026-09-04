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
  BeerStyle(
    id: 'kellerbier',
    name: 'Kellerbier / Zwickelbier',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne (Franconie)',
    abvRange: '4,5 – 5,5 %',
    description:
        'Lager non filtrée servie directement depuis la cave de garde, '
        'trouble, aux notes de levure et de houblon frais.',
  ),
  BeerStyle(
    id: 'rauchbierLager',
    name: 'Rauchbier',
    family: BeerFamily.lagerBasse,
    origin: 'Allemagne (Bamberg)',
    abvRange: '4,8 – 5,4 %',
    description:
        'Lager ambrée brassée avec du malt fumé au bois de hêtre, '
        'signature de la ville de Bamberg.',
  ),
  BeerStyle(
    id: 'balticPorter',
    name: 'Baltic Porter',
    family: BeerFamily.lagerBasse,
    origin: 'Europe de la Baltique',
    abvRange: '6,5 – 9,5 %',
    description:
        'Porter fort brassé en fermentation basse, hérité des échanges '
        'commerciaux entre l\'Angleterre et la mer Baltique, notes de '
        'fruits secs et de réglisse.',
  ),
  BeerStyle(
    id: 'indiaPaleLager',
    name: 'India Pale Lager (IPL)',
    family: BeerFamily.lagerBasse,
    origin: 'États-Unis',
    abvRange: '5,5 – 6,5 %',
    description:
        'Lager très houblonnée, hybride moderne entre la fraîcheur d\'une '
        'lager et l\'intensité aromatique d\'une IPA.',
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
    id: 'neipa',
    name: 'New England IPA (Hazy IPA)',
    family: BeerFamily.aleHaute,
    origin: 'États-Unis',
    abvRange: '6 – 9 %',
    description:
        'IPA trouble et juteuse, texture soyeuse, houblonnage massif à '
        'cru pour des arômes de fruits tropicaux sans amertume agressive.',
  ),
  BeerStyle(
    id: 'doubleIpa',
    name: 'Double / Imperial IPA',
    family: BeerFamily.aleHaute,
    origin: 'États-Unis',
    abvRange: '7,5 – 10,5 %',
    description:
        'Version renforcée de l\'IPA, plus maltée, plus alcoolisée et '
        'encore plus houblonnée.',
  ),
  BeerStyle(
    id: 'blackIpa',
    name: 'Black IPA / Cascadian Dark Ale',
    family: BeerFamily.aleHaute,
    origin: 'États-Unis',
    abvRange: '6,5 – 9 %',
    description:
        'IPA noire, torréfaction discrète pour ne pas masquer le '
        'houblonnage caractéristique de l\'IPA.',
  ),
  BeerStyle(
    id: 'sessionIpa',
    name: 'Session IPA',
    family: BeerFamily.aleHaute,
    origin: 'États-Unis',
    abvRange: '3,5 – 5 %',
    description:
        'Toute l\'aromatique houblonnée d\'une IPA, dans un degré '
        'd\'alcool réduit pour une bière plus "session".',
  ),
  BeerStyle(
    id: 'americanAmberAle',
    name: 'American Amber Ale',
    family: BeerFamily.aleHaute,
    origin: 'États-Unis',
    abvRange: '4,5 – 6,2 %',
    description:
        'Ale ambrée américaine, équilibre entre malt caramel et '
        'houblonnage franc, plus ronde qu\'une Pale Ale.',
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
    id: 'kolsch',
    name: 'Kölsch',
    family: BeerFamily.aleHaute,
    origin: 'Allemagne (Cologne)',
    abvRange: '4,4 – 5,2 %',
    description:
        'Ale fermentée à froid puis garde à la manière d\'une lager, '
        'blonde, légère et délicate, protégée par une appellation limitée '
        'à Cologne.',
  ),
  BeerStyle(
    id: 'altbier',
    name: 'Altbier',
    family: BeerFamily.aleHaute,
    origin: 'Allemagne (Düsseldorf)',
    abvRange: '4,5 – 5,2 %',
    description:
        'Ale cuivrée de Düsseldorf, fermentée haute puis gardée au froid, '
        'équilibrée entre malt toasté et houblon.',
  ),
  BeerStyle(
    id: 'creamAle',
    name: 'Cream Ale',
    family: BeerFamily.aleHaute,
    origin: 'États-Unis',
    abvRange: '4,2 – 5,6 %',
    description:
        'Ale américaine légère et douce, pensée pour ressembler à une '
        'lager facile à boire.',
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
    id: 'milkStout',
    name: 'Milk Stout / Sweet Stout',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '4 – 6 %',
    description:
        'Stout adouci par l\'ajout de lactose (sucre du lait, non '
        'fermentescible), rond et légèrement sucré.',
  ),
  BeerStyle(
    id: 'oatmealStout',
    name: 'Oatmeal Stout',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '4,2 – 5,9 %',
    description:
        'Stout brassé avec une part d\'avoine, texture soyeuse et '
        'onctueuse.',
  ),
  BeerStyle(
    id: 'imperialStout',
    name: 'Imperial Stout / Russian Imperial Stout',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni / Russie',
    abvRange: '8 – 12 %',
    description:
        'Stout très fort brassé à l\'origine pour supporter le voyage '
        'jusqu\'à la cour impériale russe, dense et complexe.',
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
    id: 'quadrupel',
    name: 'Quadrupel / Belgian Dark Strong Ale',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '9 – 14 %',
    description:
        'Ale belge sombre et très forte, notes de fruits confits, de '
        'caramel brûlé et d\'alcool bien intégré.',
  ),
  BeerStyle(
    id: 'patersbier',
    name: 'Patersbier / Abbey Single',
    family: BeerFamily.aleHaute,
    origin: 'Belgique',
    abvRange: '4,5 – 6 %',
    description:
        'La bière légère et peu alcoolisée que les moines trappistes se '
        'réservent au quotidien, rarement commercialisée.',
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
  BeerStyle(
    id: 'faro',
    name: 'Faro',
    family: BeerFamily.spontanee,
    origin: 'Belgique',
    abvRange: '4 – 6 %',
    description:
        'Lambic jeune adouci avec du sucre candi, doux et acidulé, '
        'historiquement la bière la plus populaire de Bruxelles.',
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
  BeerStyle(
    id: 'gose',
    name: 'Gose',
    family: BeerFamily.mixte,
    origin: 'Allemagne (Leipzig)',
    abvRange: '4,2 – 4,8 %',
    description:
        'Ale de blé acidulée par des bactéries lactiques, salée et '
        'relevée de coriandre, originaire de Leipzig.',
  ),
  BeerStyle(
    id: 'berlinerWeisse',
    name: 'Berliner Weisse',
    family: BeerFamily.mixte,
    origin: 'Allemagne (Berlin)',
    abvRange: '2,8 – 3,8 %',
    description:
        'Ale de blé très légère et acidulée par fermentation mixte, '
        'traditionnellement servie avec un sirop pour adoucir l\'acidité.',
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
