import '../models/beer.dart';

/// Un échantillon représentatif de bières connues pour chaque style. Il ne
/// s'agit pas d'une liste exhaustive de "toutes les bières" (il en existe
/// des centaines de milliers) mais d'exemples réels illustrant chaque
/// case de la classification.
const List<Beer> beers = [
  // Pilsner
  Beer(
    id: 'pilsner-urquell',
    name: 'Pilsner Urquell',
    brewery: 'Plzeňský Prazdroj',
    country: 'République tchèque',
    styleId: 'pilsner',
    abv: 4.4,
    description: 'La première Pilsner au monde, brassée depuis 1842.',
  ),
  Beer(
    id: 'jupiler',
    name: 'Jupiler',
    brewery: 'AB InBev',
    country: 'Belgique',
    styleId: 'pilsner',
    abv: 5.2,
    description: 'La pils la plus populaire de Belgique.',
  ),

  // Pale Lager européenne
  Beer(
    id: '1664',
    name: '1664',
    brewery: 'Kronenbourg',
    country: 'France',
    styleId: 'euroPaleLager',
    abv: 5.5,
    description: 'Lager blonde emblématique de la brasserie alsacienne.',
  ),
  Beer(
    id: 'heineken',
    name: 'Heineken',
    brewery: 'Heineken',
    country: 'Pays-Bas',
    styleId: 'euroPaleLager',
    abv: 5.0,
    description: 'Lager néerlandaise distribuée dans plus de 190 pays.',
  ),

  // Helles
  Beer(
    id: 'augustiner-hell',
    name: 'Augustiner Lagerbier Hell',
    brewery: 'Augustiner-Bräu',
    country: 'Allemagne',
    styleId: 'helles',
    abv: 5.2,
    description: 'Un classique munichois servi dans les biergartens.',
  ),

  // Dunkel
  Beer(
    id: 'ayinger-dunkel',
    name: 'Ayinger Altbairisch Dunkel',
    brewery: 'Ayinger',
    country: 'Allemagne',
    styleId: 'dunkel',
    abv: 5.0,
    description: 'Lager brune maltée, notes de pain grillé.',
  ),

  // Schwarzbier
  Beer(
    id: 'koestritzer',
    name: 'Köstritzer Schwarzbier',
    brewery: 'Köstritzer',
    country: 'Allemagne',
    styleId: 'schwarzbier',
    abv: 4.8,
    description: 'Lager noire légère brassée depuis 1543.',
  ),

  // Märzen / Oktoberfest
  Beer(
    id: 'paulaner-oktoberfest',
    name: 'Paulaner Oktoberfest Wiesn',
    brewery: 'Paulaner',
    country: 'Allemagne',
    styleId: 'marzen',
    abv: 6.0,
    description: 'La bière officielle de l\'Oktoberfest de Munich.',
  ),

  // Vienna Lager
  Beer(
    id: 'sam-adams-boston-lager',
    name: 'Samuel Adams Boston Lager',
    brewery: 'Boston Beer Company',
    country: 'États-Unis',
    styleId: 'vienna',
    abv: 4.9,
    description: 'Lager ambrée qui a relancé le craft beer américain.',
  ),

  // Bock
  Beer(
    id: 'ayinger-celebrator',
    name: 'Ayinger Celebrator',
    brewery: 'Ayinger',
    country: 'Allemagne',
    styleId: 'bock',
    abv: 6.7,
    description: 'Doppelbock riche et maltée, notes de fruits secs.',
  ),

  // American / Adjunct Lager
  Beer(
    id: 'budweiser',
    name: 'Budweiser',
    brewery: 'Anheuser-Busch',
    country: 'États-Unis',
    styleId: 'americanLager',
    abv: 5.0,
    description: 'La lager américaine la plus vendue au monde.',
  ),
  Beer(
    id: 'corona',
    name: 'Corona Extra',
    brewery: 'Grupo Modelo',
    country: 'Mexique',
    styleId: 'americanLager',
    abv: 4.5,
    description: 'Lager mexicaine légère, souvent servie avec du citron.',
  ),

  // Pale Ale
  Beer(
    id: 'sierra-nevada-pale-ale',
    name: 'Sierra Nevada Pale Ale',
    brewery: 'Sierra Nevada',
    country: 'États-Unis',
    styleId: 'paleAle',
    abv: 5.6,
    description: 'La Pale Ale américaine fondatrice du mouvement craft.',
  ),
  Beer(
    id: 'fullers-london-pride',
    name: "Fuller's London Pride",
    brewery: "Fuller's",
    country: 'Royaume-Uni',
    styleId: 'paleAle',
    abv: 4.7,
    description: 'Pale Ale londonienne équilibrée et maltée.',
  ),

  // IPA
  Beer(
    id: 'brewdog-punk-ipa',
    name: 'BrewDog Punk IPA',
    brewery: 'BrewDog',
    country: 'Écosse',
    styleId: 'ipa',
    abv: 5.4,
    description: 'IPA écossaise qui a popularisé le style en Europe.',
  ),
  Beer(
    id: 'sierra-nevada-torpedo',
    name: 'Sierra Nevada Torpedo Extra IPA',
    brewery: 'Sierra Nevada',
    country: 'États-Unis',
    styleId: 'ipa',
    abv: 7.2,
    description: 'IPA américaine intensément houblonnée.',
  ),

  // Bitter / ESB
  Beer(
    id: 'fullers-esb',
    name: "Fuller's ESB",
    brewery: "Fuller's",
    country: 'Royaume-Uni',
    styleId: 'bitter',
    abv: 5.9,
    description: 'L\'Extra Special Bitter de référence.',
  ),

  // Brown Ale
  Beer(
    id: 'newcastle-brown-ale',
    name: 'Newcastle Brown Ale',
    brewery: 'Newcastle',
    country: 'Royaume-Uni',
    styleId: 'brownAle',
    abv: 4.7,
    description: 'Brown Ale anglaise douce et sans amertume marquée.',
  ),

  // Porter
  Beer(
    id: 'fullers-london-porter',
    name: "Fuller's London Porter",
    brewery: "Fuller's",
    country: 'Royaume-Uni',
    styleId: 'porter',
    abv: 5.4,
    description: 'Porter londonien torréfié, notes de chocolat noir.',
  ),

  // Stout
  Beer(
    id: 'guinness-draught',
    name: 'Guinness Draught',
    brewery: 'Guinness',
    country: 'Irlande',
    styleId: 'stout',
    abv: 4.2,
    description: 'Le Dry Stout irlandais le plus célèbre au monde.',
  ),
  Beer(
    id: 'guinness-foreign-extra',
    name: 'Guinness Foreign Extra Stout',
    brewery: 'Guinness',
    country: 'Irlande',
    styleId: 'stout',
    abv: 7.5,
    description: 'Version plus forte et plus amère, exportée dès 1801.',
  ),

  // Barleywine
  Beer(
    id: 'fullers-golden-pride',
    name: "Fuller's Golden Pride",
    brewery: "Fuller's",
    country: 'Royaume-Uni',
    styleId: 'barleywine',
    abv: 8.5,
    description: 'Barleywine anglais riche à garder en cave.',
  ),

  // Scotch Ale
  Beer(
    id: 'traquair-house-ale',
    name: 'Traquair House Ale',
    brewery: 'Traquair House',
    country: 'Écosse',
    styleId: 'scotchAle',
    abv: 7.2,
    description: 'Brassée dans le plus vieux château habité d\'Écosse.',
  ),

  // Blonde belge
  Beer(
    id: 'leffe-blonde',
    name: 'Leffe Blonde',
    brewery: 'Leffe',
    country: 'Belgique',
    styleId: 'belgianBlonde',
    abv: 6.6,
    description: 'Blonde belge d\'abbaye ronde et épicée.',
  ),

  // Dubbel
  Beer(
    id: 'westmalle-dubbel',
    name: 'Westmalle Dubbel',
    brewery: 'Abbaye de Westmalle',
    country: 'Belgique',
    styleId: 'belgianDubbel',
    abv: 7.0,
    description: 'La Dubbel trappiste originelle, brassée depuis 1856.',
  ),

  // Tripel
  Beer(
    id: 'westmalle-tripel',
    name: 'Westmalle Tripel',
    brewery: 'Abbaye de Westmalle',
    country: 'Belgique',
    styleId: 'belgianTripel',
    abv: 9.5,
    description: 'La Tripel trappiste de référence depuis 1934.',
  ),

  // Strong Golden Ale
  Beer(
    id: 'duvel',
    name: 'Duvel',
    brewery: 'Duvel Moortgat',
    country: 'Belgique',
    styleId: 'belgianStrongGolden',
    abv: 8.5,
    description: 'Strong Golden Ale belge trompeusement facile à boire.',
  ),

  // Saison
  Beer(
    id: 'saison-dupont',
    name: 'Saison Dupont',
    brewery: 'Brasserie Dupont',
    country: 'Belgique',
    styleId: 'saison',
    abv: 6.5,
    description: 'La Saison de référence, sèche et poivrée.',
  ),

  // Witbier
  Beer(
    id: 'hoegaarden',
    name: 'Hoegaarden',
    brewery: 'Hoegaarden',
    country: 'Belgique',
    styleId: 'witbier',
    abv: 4.9,
    description: 'La blanche belge qui a relancé le style en 1966.',
  ),

  // Weissbier
  Beer(
    id: 'paulaner-hefe-weissbier',
    name: 'Paulaner Hefe-Weissbier',
    brewery: 'Paulaner',
    country: 'Allemagne',
    styleId: 'weissbier',
    abv: 5.5,
    description: 'Weissbier bavaroise aux notes de banane et de girofle.',
  ),

  // Lambic
  Beer(
    id: 'cantillon-grand-cru',
    name: 'Cantillon Grand Cru Bruocsella',
    brewery: 'Cantillon',
    country: 'Belgique',
    styleId: 'lambic',
    abv: 5.0,
    description: 'Lambic pur, sec et acidulé, sans sucre ajouté.',
  ),

  // Gueuze
  Beer(
    id: 'cantillon-gueuze',
    name: 'Cantillon Gueuze',
    brewery: 'Cantillon',
    country: 'Belgique',
    styleId: 'gueuze',
    abv: 5.0,
    description: 'Assemblage de lambics de 1, 2 et 3 ans.',
  ),

  // Fruit lambic
  Beer(
    id: 'lindemans-kriek',
    name: 'Lindemans Kriek',
    brewery: 'Lindemans',
    country: 'Belgique',
    styleId: 'fruitLambic',
    abv: 3.5,
    description: 'Lambic macéré à la cerise, fruité et acidulé.',
  ),

  // Flanders Red
  Beer(
    id: 'rodenbach-grand-cru',
    name: 'Rodenbach Grand Cru',
    brewery: 'Rodenbach',
    country: 'Belgique',
    styleId: 'flandersRed',
    abv: 6.0,
    description: 'Vieillie en foudres de chêne, acidité vineuse.',
  ),
];

Beer? findBeerById(String id) {
  for (final beer in beers) {
    if (beer.id == id) return beer;
  }
  return null;
}

List<Beer> beersForStyle(String styleId) =>
    beers.where((b) => b.styleId == styleId).toList();

List<Beer> beersForCountry(String country) =>
    beers.where((b) => b.country == country).toList();

List<String> get allCountries {
  final set = <String>{for (final b in beers) b.country};
  final list = set.toList()..sort();
  return list;
}
