# Bierodex

Application mobile Flutter qui classifie les grands styles de bières,
un peu comme un "Pokédex" des bières.

## Fonctionnement de la classification

La classification se fait sur deux niveaux :

1. **Famille de fermentation** : fermentation haute (Ale), basse (Lager),
   spontanée ou mixte.
2. **Style** à l'intérieur de chaque famille (Pilsner, IPA, Stout,
   Tripel, Lambic, ...), avec pour chaque style son origine géographique,
   sa plage d'ABV typique et une description.

Chaque style est illustré par des exemples réels de bières (brasserie,
pays, ABV), consultables aussi par pays d'origine.

Ce n'est pas une base exhaustive de "toutes les bières qui existent"
(il en existe des centaines de milliers) : c'est une taxonomie des
grands styles reconnus, avec des exemples représentatifs par style. Le
jeu de données (`lib/data/`) est fait pour être complété facilement.

## Structure du code

```
lib/
  models/        # Beer, BeerStyle, BeerFamily
  data/          # Taxonomie des styles + exemples de bières
  screens/       # Écrans (onglets Styles/Origines, détails, recherche)
  widgets/       # Composants réutilisables (tuiles de liste)
```

## Lancer le projet

```bash
flutter pub get
flutter run
```
