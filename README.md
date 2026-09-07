# Bierodex

Application mobile Flutter qui classifie les grands styles de bières,
un peu comme un "Pokédex" des bières — avec un globe 3D pour repérer
les brasseries à leur adresse réelle.

## Fonctionnement de la classification

La classification se fait sur deux niveaux :

1. **Famille de fermentation** : fermentation haute (Ale), basse (Lager),
   spontanée ou mixte.
2. **Style** à l'intérieur de chaque famille (Pilsner, IPA, Stout,
   Tripel, Lambic, ...), avec pour chaque style son origine géographique,
   sa plage d'ABV typique et une description.

Chaque style est illustré par des exemples réels de bières (brasserie,
pays, ABV). Chaque brasserie est en plus géolocalisée à son adresse
réelle (données OpenStreetMap/Nominatim) et affichée comme repère sur
le globe 3D de l'écran d'accueil : toucher un repère ouvre la liste
des bières de cette brasserie.

Ce n'est pas une base exhaustive de "toutes les bières qui existent"
(il en existe des centaines de milliers) : c'est une taxonomie des
grands styles reconnus, avec des exemples représentatifs par style. Le
jeu de données (`lib/data/`) est fait pour être complété facilement.

## Compte et synchronisation

La collection personnelle (bières bues / notées) est toujours
disponible hors connexion (stockage local). En se connectant (code
reçu par e-mail, via Supabase Auth), elle se synchronise en plus entre
appareils.

## Structure du code

```
lib/
  models/        # Beer, BeerStyle, BeerFamily, BreweryLocation
  data/          # Taxonomie des styles, bières, localisation des brasseries
  screens/       # Globe 3D, styles, collection, compte, recherche, détails
  services/      # Auth (Supabase) et suivi de collection (local + sync)
  widgets/       # Composants réutilisables (tuiles de liste, étoiles...)
```

## Configuration

Le projet a besoin d'un projet Supabase (gratuit) pour la connexion et
la synchronisation de la collection. Les identifiants ne sont **pas**
commités (le repo est public) : ils sont fournis au build via
`--dart-define-from-file`.

1. Copie `env.example.json` vers `env.json`.
2. Renseigne `SUPABASE_URL` et `SUPABASE_ANON_KEY` (Project Settings →
   API Keys sur le dashboard Supabase — la clé "anon public", jamais la
   "service_role").

`env.json` est ignoré par git.

## Lancer le projet

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

Pour le web, un build WASM est nécessaire (rendu par shaders du globe
3D) :

```bash
flutter build web --wasm --dart-define-from-file=env.json
```
