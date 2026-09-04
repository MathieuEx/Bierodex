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
    id: 'bitburger',
    name: 'Bitburger',
    brewery: 'Bitburger',
    country: 'Allemagne',
    styleId: 'pilsner',
    abv: 4.8,
    description: 'Pilsner allemande sèche, référence de l\'Eifel.',
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
  Beer(
    id: 'estrella-damm',
    name: 'Estrella Damm',
    brewery: 'Damm',
    country: 'Espagne',
    styleId: 'euroPaleLager',
    abv: 4.6,
    description: 'Lager barcelonaise brassée depuis 1876.',
  ),
  Beer(
    id: 'peroni-nastro-azzurro',
    name: 'Peroni Nastro Azzurro',
    brewery: 'Peroni',
    country: 'Italie',
    styleId: 'euroPaleLager',
    abv: 5.1,
    description: 'Lager italienne premium, symbole du style milanais.',
  ),
  Beer(
    id: 'carlsberg',
    name: 'Carlsberg',
    brewery: 'Carlsberg',
    country: 'Danemark',
    styleId: 'euroPaleLager',
    abv: 5.0,
    description: 'Lager danoise brassée à Copenhague depuis 1847.',
  ),
  Beer(
    id: 'la-cagole-blonde',
    name: 'La Cagole Blonde',
    brewery: 'Brasserie La Phocéenne',
    country: 'France',
    styleId: 'euroPaleLager',
    abv: 5.5,
    description: 'Lager blonde marseillaise devenue une figure locale.',
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
  Beer(
    id: 'weihenstephaner-original-helles',
    name: 'Weihenstephaner Original Helles',
    brewery: 'Weihenstephaner',
    country: 'Allemagne',
    styleId: 'helles',
    abv: 5.1,
    description: 'Brassée par la plus ancienne brasserie du monde.',
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
  Beer(
    id: 'hofbrau-dunkel',
    name: 'Hofbräu Dunkel',
    brewery: 'Hofbräu München',
    country: 'Allemagne',
    styleId: 'dunkel',
    abv: 5.5,
    description: 'Dunkel munichoise ronde, notes de pain et de caramel.',
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
  Beer(
    id: 'moenchshof-schwarzbier',
    name: 'Mönchshof Schwarzbier',
    brewery: 'Kulmbacher',
    country: 'Allemagne',
    styleId: 'schwarzbier',
    abv: 4.9,
    description: 'Schwarzbier de Kulmbach, douce et légèrement torréfiée.',
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
  Beer(
    id: 'hacker-pschorr-oktoberfest',
    name: 'Hacker-Pschorr Oktoberfest Märzen',
    brewery: 'Hacker-Pschorr',
    country: 'Allemagne',
    styleId: 'marzen',
    abv: 5.8,
    description: 'Märzen munichoise, l\'une des six bières officielles de la fête.',
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
  Beer(
    id: 'negra-modelo',
    name: 'Negra Modelo',
    brewery: 'Grupo Modelo',
    country: 'Mexique',
    styleId: 'vienna',
    abv: 5.4,
    description: 'Lager ambrée mexicaine héritée des brasseurs viennois.',
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
  Beer(
    id: 'einbecker-ur-bock',
    name: 'Einbecker Ur-Bock',
    brewery: 'Einbecker',
    country: 'Allemagne',
    styleId: 'bock',
    abv: 6.5,
    description: 'Le Bock originel, brassé à Einbeck depuis le Moyen Âge.',
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
  Beer(
    id: 'asahi-super-dry',
    name: 'Asahi Super Dry',
    brewery: 'Asahi',
    country: 'Japon',
    styleId: 'americanLager',
    abv: 5.0,
    description: 'Lager japonaise très sèche, la référence du pays.',
  ),
  Beer(
    id: 'tsingtao',
    name: 'Tsingtao',
    brewery: 'Tsingtao Brewery',
    country: 'Chine',
    styleId: 'americanLager',
    abv: 4.7,
    description: 'Lager chinoise brassée depuis 1903 à Qingdao.',
  ),
  Beer(
    id: 'brahma-chopp',
    name: 'Brahma Chopp',
    brewery: 'Ambev',
    country: 'Brésil',
    styleId: 'americanLager',
    abv: 4.8,
    description: 'L\'une des lagers les plus vendues du Brésil.',
  ),
  Beer(
    id: 'victoria-bitter',
    name: 'Victoria Bitter',
    brewery: 'Carlton United Breweries',
    country: 'Australie',
    styleId: 'americanLager',
    abv: 4.9,
    description: 'Lager australienne emblématique, malgré son nom.',
  ),
  Beer(
    id: 'castle-lager',
    name: 'Castle Lager',
    brewery: 'South African Breweries',
    country: 'Afrique du Sud',
    styleId: 'americanLager',
    abv: 5.0,
    description: 'Lager sud-africaine brassée depuis 1895.',
  ),

  // Kellerbier / Zwickelbier
  Beer(
    id: 'rothaus-kellerbier',
    name: 'Rothaus Kellerbier',
    brewery: 'Rothaus',
    country: 'Allemagne',
    styleId: 'kellerbier',
    abv: 5.1,
    description: 'Lager non filtrée de la Forêt-Noire, trouble et vive.',
  ),
  Beer(
    id: 'mahrs-ungespundet',
    name: "Mahr's Bräu Ungespundet",
    brewery: "Mahr's Bräu",
    country: 'Allemagne',
    styleId: 'kellerbier',
    abv: 5.2,
    description: 'Kellerbier culte de Bamberg, houblonnée et non filtrée.',
  ),

  // Rauchbier
  Beer(
    id: 'schlenkerla-rauchbier',
    name: 'Schlenkerla Aecht Schlenkerla Rauchbier Märzen',
    brewery: 'Schlenkerla',
    country: 'Allemagne',
    styleId: 'rauchbierLager',
    abv: 5.1,
    description: 'Le Rauchbier de référence, brassé à Bamberg depuis 1405.',
  ),
  Beer(
    id: 'spezial-rauchbier',
    name: 'Spezial Rauchbier Lager',
    brewery: 'Brauerei Spezial',
    country: 'Allemagne',
    styleId: 'rauchbierLager',
    abv: 5.1,
    description: 'L\'autre grand Rauchbier de Bamberg, plus doux et rond.',
  ),

  // Baltic Porter
  Beer(
    id: 'sinebrychoff-porter',
    name: 'Sinebrychoff Porter',
    brewery: 'Sinebrychoff',
    country: 'Finlande',
    styleId: 'balticPorter',
    abv: 7.2,
    description: 'Baltic Porter finlandais brassé depuis 1957.',
  ),
  Beer(
    id: 'okocim-porter',
    name: 'Okocim Porter',
    brewery: 'Okocim',
    country: 'Pologne',
    styleId: 'balticPorter',
    abv: 8.1,
    description: 'Baltic Porter polonais dense, notes de fruits noirs.',
  ),

  // India Pale Lager
  Beer(
    id: 'jacks-abby-hoponius-union',
    name: "Jack's Abby Hoponius Union",
    brewery: "Jack's Abby Craft Lagers",
    country: 'États-Unis',
    styleId: 'indiaPaleLager',
    abv: 6.7,
    description: 'L\'une des India Pale Lager pionnières aux États-Unis.',
  ),
  Beer(
    id: 'ballast-point-fathom',
    name: 'Ballast Point Fathom India Pale Lager',
    brewery: 'Ballast Point',
    country: 'États-Unis',
    styleId: 'indiaPaleLager',
    abv: 5.9,
    description: 'IPL californienne, croustillante et houblonnée.',
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
  Beer(
    id: 'la-debauche-california-ipa',
    name: 'La Débauche California IPA',
    brewery: 'La Débauche',
    country: 'France',
    styleId: 'ipa',
    abv: 6.5,
    description: 'IPA nantaise parmi les figures du craft français.',
  ),
  Beer(
    id: 'lagunitas-ipa',
    name: 'Lagunitas IPA',
    brewery: 'Lagunitas Brewing',
    country: 'États-Unis',
    styleId: 'ipa',
    abv: 6.2,
    description: 'IPA californienne résineuse, l\'une des plus vendues des États-Unis.',
  ),

  // Kölsch
  Beer(
    id: 'fruh-koelsch',
    name: 'Früh Kölsch',
    brewery: 'Früh',
    country: 'Allemagne',
    styleId: 'kolsch',
    abv: 4.8,
    description: 'Kölsch brassée à Cologne, servie en petits verres cylindriques.',
  ),
  Beer(
    id: 'reissdorf-koelsch',
    name: 'Reissdorf Kölsch',
    brewery: 'Reissdorf',
    country: 'Allemagne',
    styleId: 'kolsch',
    abv: 4.8,
    description: 'Autre grande Kölsch traditionnelle de Cologne.',
  ),

  // Altbier
  Beer(
    id: 'uerige-alt',
    name: 'Uerige Alt',
    brewery: 'Zum Uerige',
    country: 'Allemagne',
    styleId: 'altbier',
    abv: 4.7,
    description: 'Altbier de brasserie-brasserie (brewpub) de Düsseldorf.',
  ),
  Beer(
    id: 'diebels-alt',
    name: 'Diebels Alt',
    brewery: 'Diebels',
    country: 'Allemagne',
    styleId: 'altbier',
    abv: 4.9,
    description: 'Altbier produite à plus grande échelle, cuivrée et sèche.',
  ),

  // Cream Ale
  Beer(
    id: 'genesee-cream-ale',
    name: 'Genesee Cream Ale',
    brewery: 'Genesee Brewing',
    country: 'États-Unis',
    styleId: 'creamAle',
    abv: 5.1,
    description: 'Cream Ale américaine légère et désaltérante.',
  ),
  Beer(
    id: 'little-kings-cream-ale',
    name: 'Little Kings Cream Ale',
    brewery: 'Hudepohl',
    country: 'États-Unis',
    styleId: 'creamAle',
    abv: 5.5,
    description: 'Cream Ale de Cincinnati vendue en petites bouteilles culte.',
  ),

  // New England IPA
  Beer(
    id: 'tree-house-julius',
    name: 'Tree House Julius',
    brewery: 'Tree House Brewing',
    country: 'États-Unis',
    styleId: 'neipa',
    abv: 6.8,
    description: 'NEIPA culte, trouble et gorgée de fruits tropicaux.',
  ),
  Beer(
    id: 'heady-topper',
    name: 'The Alchemist Heady Topper',
    brewery: 'The Alchemist',
    country: 'États-Unis',
    styleId: 'neipa',
    abv: 8.0,
    description: 'L\'une des IPA fondatrices du style trouble du Vermont.',
  ),

  // Double / Imperial IPA
  Beer(
    id: 'pliny-the-elder',
    name: 'Pliny the Elder',
    brewery: 'Russian River Brewing',
    country: 'États-Unis',
    styleId: 'doubleIpa',
    abv: 8.0,
    description: 'L\'une des Double IPA les plus réputées au monde.',
  ),
  Beer(
    id: 'dogfish-head-90-minute',
    name: 'Dogfish Head 90 Minute IPA',
    brewery: 'Dogfish Head',
    country: 'États-Unis',
    styleId: 'doubleIpa',
    abv: 9.0,
    description: 'Imperial IPA houblonnée en continu pendant 90 minutes.',
  ),

  // Black IPA
  Beer(
    id: 'stone-sublimely-self-righteous',
    name: 'Stone Sublimely Self-Righteous Black IPA',
    brewery: 'Stone Brewing',
    country: 'États-Unis',
    styleId: 'blackIpa',
    abv: 8.7,
    description: 'Black IPA californienne, torréfaction et houblon intense.',
  ),
  Beer(
    id: 'deschutes-hop-in-the-dark',
    name: 'Deschutes Hop in the Dark',
    brewery: 'Deschutes Brewery',
    country: 'États-Unis',
    styleId: 'blackIpa',
    abv: 6.5,
    description: 'Black IPA de l\'Oregon, équilibre entre torréfaction et houblon.',
  ),

  // Session IPA
  Beer(
    id: 'founders-all-day-ipa',
    name: 'Founders All Day IPA',
    brewery: 'Founders Brewing',
    country: 'États-Unis',
    styleId: 'sessionIpa',
    abv: 4.7,
    description: 'Session IPA parmi les plus populaires des États-Unis.',
  ),
  Beer(
    id: 'lagunitas-daytime',
    name: 'Lagunitas DayTime IPA',
    brewery: 'Lagunitas Brewing',
    country: 'États-Unis',
    styleId: 'sessionIpa',
    abv: 4.0,
    description: 'Session IPA légère mais pleinement aromatique.',
  ),

  // American Amber Ale
  Beer(
    id: 'fat-tire-amber-ale',
    name: 'Fat Tire Amber Ale',
    brewery: 'New Belgium Brewing',
    country: 'États-Unis',
    styleId: 'americanAmberAle',
    abv: 5.2,
    description: 'Amber Ale américaine ronde, malt caramel bien présent.',
  ),
  Beer(
    id: 'alaskan-amber',
    name: 'Alaskan Amber',
    brewery: 'Alaskan Brewing',
    country: 'États-Unis',
    styleId: 'americanAmberAle',
    abv: 5.3,
    description: 'Amber Ale d\'Alaska inspirée d\'une recette de l\'époque de la ruée vers l\'or.',
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
  Beer(
    id: 'timothy-taylor-landlord',
    name: 'Timothy Taylor Landlord',
    brewery: 'Timothy Taylor',
    country: 'Royaume-Uni',
    styleId: 'bitter',
    abv: 4.3,
    description: 'Bitter du Yorkshire réputée pour son équilibre fruité.',
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
  Beer(
    id: 'samuel-smiths-nut-brown-ale',
    name: "Samuel Smith's Nut Brown Ale",
    brewery: 'Samuel Smith',
    country: 'Royaume-Uni',
    styleId: 'brownAle',
    abv: 5.0,
    description: 'Brown Ale du Yorkshire, notes de noisette grillée.',
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
  Beer(
    id: 'anchor-porter',
    name: 'Anchor Porter',
    brewery: 'Anchor Brewing',
    country: 'États-Unis',
    styleId: 'porter',
    abv: 5.6,
    description: 'Porter californien dense, l\'un des piliers du craft américain.',
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
  Beer(
    id: 'murphys-irish-stout',
    name: "Murphy's Irish Stout",
    brewery: "Murphy's",
    country: 'Irlande',
    styleId: 'stout',
    abv: 4.0,
    description: 'Dry Stout de Cork, plus doux que Guinness.',
  ),

  // Milk Stout / Sweet Stout
  Beer(
    id: 'mackeson-xxx-stout',
    name: 'Mackeson XXX Stout',
    brewery: 'Mackeson',
    country: 'Royaume-Uni',
    styleId: 'milkStout',
    abv: 2.8,
    description: 'Le Milk Stout historique, adouci au lactose depuis 1907.',
  ),
  Beer(
    id: 'left-hand-milk-stout',
    name: 'Left Hand Milk Stout',
    brewery: 'Left Hand Brewing',
    country: 'États-Unis',
    styleId: 'milkStout',
    abv: 6.0,
    description: 'Milk Stout américain qui a relancé le style dans le craft.',
  ),

  // Oatmeal Stout
  Beer(
    id: 'samuel-smiths-oatmeal-stout',
    name: "Samuel Smith's Oatmeal Stout",
    brewery: 'Samuel Smith',
    country: 'Royaume-Uni',
    styleId: 'oatmealStout',
    abv: 5.0,
    description: 'Oatmeal Stout du Yorkshire, texture veloutée.',
  ),
  Beer(
    id: 'anderson-valley-barney-flats',
    name: 'Anderson Valley Barney Flats Oatmeal Stout',
    brewery: 'Anderson Valley Brewing',
    country: 'États-Unis',
    styleId: 'oatmealStout',
    abv: 5.2,
    description: 'Oatmeal Stout californien, rond et peu amer.',
  ),

  // Imperial Stout
  Beer(
    id: 'old-rasputin',
    name: 'North Coast Old Rasputin',
    brewery: 'North Coast Brewing',
    country: 'États-Unis',
    styleId: 'imperialStout',
    abv: 9.0,
    description: 'Russian Imperial Stout californien, dense et torréfié.',
  ),
  Beer(
    id: 'founders-breakfast-stout',
    name: 'Founders Breakfast Stout',
    brewery: 'Founders Brewing',
    country: 'États-Unis',
    styleId: 'imperialStout',
    abv: 8.3,
    description: 'Imperial Stout au café et à l\'avoine, culte aux États-Unis.',
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
  Beer(
    id: 'sierra-nevada-bigfoot',
    name: 'Sierra Nevada Bigfoot Barleywine',
    brewery: 'Sierra Nevada',
    country: 'États-Unis',
    styleId: 'barleywine',
    abv: 9.6,
    description: 'Barleywine américain puissant, très houblonné.',
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
  Beer(
    id: 'belhaven-wee-heavy',
    name: 'Belhaven Wee Heavy',
    brewery: 'Belhaven',
    country: 'Écosse',
    styleId: 'scotchAle',
    abv: 6.5,
    description: 'Wee Heavy écossaise, malt riche et pointe de fumé.',
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
  Beer(
    id: 'affligem-blonde',
    name: 'Affligem Blonde',
    brewery: 'Affligem',
    country: 'Belgique',
    styleId: 'belgianBlonde',
    abv: 6.8,
    description: 'Blonde d\'abbaye héritée d\'une tradition monastique de 1074.',
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
  Beer(
    id: 'chimay-rouge',
    name: 'Chimay Rouge (Première)',
    brewery: 'Abbaye de Scourmont',
    country: 'Belgique',
    styleId: 'belgianDubbel',
    abv: 7.0,
    description: 'Dubbel trappiste de Chimay, fruitée et épicée.',
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
  Beer(
    id: 'chimay-blanche',
    name: 'Chimay Blanche (Cinq Cents)',
    brewery: 'Abbaye de Scourmont',
    country: 'Belgique',
    styleId: 'belgianTripel',
    abv: 8.0,
    description: 'Tripel trappiste de Chimay, sèche et houblonnée.',
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
  Beer(
    id: 'delirium-tremens',
    name: 'Delirium Tremens',
    brewery: 'Huyghe',
    country: 'Belgique',
    styleId: 'belgianStrongGolden',
    abv: 8.5,
    description: 'Strong Golden Ale belge reconnaissable à sa bouteille tachetée.',
  ),

  // Quadrupel / Belgian Dark Strong Ale
  Beer(
    id: 'rochefort-10',
    name: 'Rochefort 10',
    brewery: 'Abbaye Notre-Dame de Saint-Rémy',
    country: 'Belgique',
    styleId: 'quadrupel',
    abv: 11.3,
    description: 'La Quadrupel trappiste la plus forte de Rochefort.',
  ),
  Beer(
    id: 'st-bernardus-abt-12',
    name: 'St. Bernardus Abt 12',
    brewery: 'St. Bernardus',
    country: 'Belgique',
    styleId: 'quadrupel',
    abv: 10.0,
    description: 'Quadrupel réputée, proche historiquement de Westvleteren 12.',
  ),

  // Patersbier / Abbey Single
  Beer(
    id: 'westvleteren-blonde',
    name: 'Westvleteren Blonde (Patersbier)',
    brewery: 'Abbaye Saint-Sixte de Westvleteren',
    country: 'Belgique',
    styleId: 'patersbier',
    abv: 5.8,
    description: 'La bière du quotidien des moines de Westvleteren.',
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
  Beer(
    id: 'fantome-saison',
    name: 'Fantôme Saison',
    brewery: 'Fantôme',
    country: 'Belgique',
    styleId: 'saison',
    abv: 8.0,
    description: 'Saison fermière atypique, souvent épicée ou fruitée.',
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
  Beer(
    id: 'blue-moon-belgian-white',
    name: 'Blue Moon Belgian White',
    brewery: 'Blue Moon Brewing',
    country: 'États-Unis',
    styleId: 'witbier',
    abv: 5.4,
    description: 'Witbier américaine à l\'écorce d\'orange, très populaire.',
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
  Beer(
    id: 'erdinger-weissbier',
    name: 'Erdinger Weissbier',
    brewery: 'Erdinger',
    country: 'Allemagne',
    styleId: 'weissbier',
    abv: 5.3,
    description: 'La plus grande brasserie de bière de blé au monde.',
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
  Beer(
    id: 'drie-fonteinen-oude-lambiek',
    name: 'Drie Fonteinen Oude Lambiek',
    brewery: 'Drie Fonteinen',
    country: 'Belgique',
    styleId: 'lambic',
    abv: 6.0,
    description: 'Lambic pur de Beersel, sec et complexe.',
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
  Beer(
    id: 'boon-oude-geuze',
    name: 'Boon Oude Geuze',
    brewery: 'Brouwerij Boon',
    country: 'Belgique',
    styleId: 'gueuze',
    abv: 7.0,
    description: 'Gueuze de Lembeek, acidulée et vive.',
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
  Beer(
    id: 'cantillon-rose-de-gambrinus',
    name: 'Cantillon Rosé de Gambrinus',
    brewery: 'Cantillon',
    country: 'Belgique',
    styleId: 'fruitLambic',
    abv: 5.0,
    description: 'Lambic macéré à la framboise, acidulé et peu sucré.',
  ),

  // Faro
  Beer(
    id: 'lindemans-faro',
    name: 'Lindemans Faro',
    brewery: 'Lindemans',
    country: 'Belgique',
    styleId: 'faro',
    abv: 4.2,
    description: 'Lambic adouci au sucre candi, doux et facile à boire.',
  ),
  Beer(
    id: 'boon-faro',
    name: 'Boon Faro',
    brewery: 'Brouwerij Boon',
    country: 'Belgique',
    styleId: 'faro',
    abv: 4.0,
    description: 'Faro de Lembeek, léger et rafraîchissant.',
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
  Beer(
    id: 'duchesse-de-bourgogne',
    name: 'Duchesse de Bourgogne',
    brewery: 'Verhaeghe',
    country: 'Belgique',
    styleId: 'flandersRed',
    abv: 6.2,
    description: 'Flanders Red très acidulée, notes de cerise et de vinaigre balsamique.',
  ),

  // Gose
  Beer(
    id: 'original-leipziger-gose',
    name: 'Original Leipziger Gose',
    brewery: 'Bayerischer Bahnhof',
    country: 'Allemagne',
    styleId: 'gose',
    abv: 4.6,
    description: 'Gose brassée à Leipzig, salée et acidulée, notes de coriandre.',
  ),
  Beer(
    id: 'westbrook-gose',
    name: 'Westbrook Gose',
    brewery: 'Westbrook Brewing',
    country: 'États-Unis',
    styleId: 'gose',
    abv: 4.0,
    description: 'Gose américaine qui a relancé le style dans le craft.',
  ),

  // Berliner Weisse
  Beer(
    id: 'berliner-kindl-weisse',
    name: 'Berliner Kindl Weisse',
    brewery: 'Berliner Kindl',
    country: 'Allemagne',
    styleId: 'berlinerWeisse',
    abv: 3.0,
    description: 'Berliner Weisse historique, très légère et acidulée.',
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
