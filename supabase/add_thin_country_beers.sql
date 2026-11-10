-- Deuxième bière pour des pays qui n'en avaient qu'une seule (juste assez
-- pour exister sur la carte du monde). Toutes les nouvelles entrées
-- viennent d'une brasserie déjà référencée dans `brewery_locations` :
-- aucune géolocalisation à ajouter.
--
-- ABV arrondis aux valeurs couramment citées pour ces marques
-- grand public ; elles varient légèrement selon le marché/millésime,
-- comme pour le reste du catalogue.

insert into beers (id, name, brewery, country, style_id, abv, description) values ('skol-brasil', 'Skol', 'Ambev', 'Brésil', 'americanLager', 4.7, 'Lager brésilienne très légère, l''une des marques de bière les plus vendues au monde.');
insert into beers (id, name, brewery, country, style_id, abv, description) values ('antarctica', 'Antarctica', 'Ambev', 'Brésil', 'americanLager', 4.7, 'Lager brésilienne historique (brassée depuis 1885), très associée au Carnaval et au football.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('castle-milk-stout', 'Castle Milk Stout', 'South African Breweries', 'Afrique du Sud', 'milkStout', 6.0, 'Stout doux et crémeux, l''un des milk stouts les plus vendus au monde, originaire d''Afrique du Sud.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('kingfisher-strong', 'Kingfisher Strong', 'United Breweries', 'Inde', 'bock', 8.0, 'Version forte de la Kingfisher, la lager la plus vendue d''Inde.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('tomislav', 'Tomislav', 'Zagrebačka pivovara', 'Croatie', 'bock', 7.3, 'Lager forte croate, plus maltée et alcoolisée que l''Ožujsko de la même brasserie.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('baltika-3', 'Baltika 3 Classic', 'Baltika', 'Russie', 'euroPaleLager', 4.8, 'La plus consommée des lagers numérotées Baltika, référence du marché russe.');
insert into beers (id, name, brewery, country, style_id, abv, description) values ('baltika-9', 'Baltika 9 Extra', 'Baltika', 'Russie', 'bock', 8.0, 'La plus forte des lagers numérotées Baltika, surnommée familièrement « le marteau ».');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('gulder', 'Gulder', 'Nigerian Breweries', 'Nigeria', 'euroPaleLager', 5.2, 'Lager premium nigériane, l''une des marques historiques de Nigerian Breweries.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('tusker-malt-lager', 'Tusker Malt Lager', 'East African Breweries', 'Kenya', 'euroPaleLager', 4.5, 'Variante premium et plus maltée de la Tusker, de la même brasserie kényane.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('pilsen-costa-rica', 'Pilsen', 'Florida Ice & Farm', 'Costa Rica', 'americanLager', 4.6, 'Lager costaricaine historique, aussi emblématique que l''Imperial dans le pays.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('quilmes-bock', 'Quilmes Bock', 'Quilmes', 'Argentine', 'bock', 5.8, 'Lager brune et maltée, déclinaison plus corsée de la Quilmes classique.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('aguila', 'Águila', 'Bavaria S.A.', 'Colombie', 'americanLager', 4.0, 'La lager la plus populaire de Colombie, légère et très rafraîchissante.');
insert into beers (id, name, brewery, country, style_id, abv, description) values ('poker', 'Poker', 'Bavaria S.A.', 'Colombie', 'americanLager', 4.0, 'Lager colombienne historique, rivale traditionnelle de l''Águila.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('saigon-export', 'Saigon Export', 'Sabeco', 'Vietnam', 'americanLager', 4.3, 'Lager vietnamienne historique de Sabeco, aux côtés de la 333 Export.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('beerlao-dark', 'Beerlao Dark', 'Lao Brewery', 'Laos', 'dunkel', 6.5, 'Version brune et plus corsée de la Beerlao, aux malts torréfiés.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('steinlager-pure', 'Steinlager Pure', 'Lion', 'Nouvelle-Zélande', 'americanLager', 4.0, 'Version épurée (sans additifs) de la Steinlager, lager emblématique néo-zélandaise.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('lion-lager-sri-lanka', 'Lion Lager', 'Ceylon Brewery', 'Sri Lanka', 'euroPaleLager', 4.8, 'Lager classique de la même brasserie que la Lion Stout, bien plus légère.');

insert into beers (id, name, brewery, country, style_id, abv, description) values ('escudo', 'Escudo', 'CCU', 'Chili', 'euroPaleLager', 4.6, 'Lager chilienne historique, aux côtés de la Cristal dans le portefeuille de CCU.');
