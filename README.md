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
reçu par e-mail, ou compte Google, via Supabase Auth), elle se
synchronise en plus entre appareils.

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

### Activer la connexion Google

Le code est déjà en place (`AuthService.signInWithGoogle`), mais Google
OAuth demande une config côté Google Cloud et côté dashboard Supabase
qui ne peut pas être commise dans le repo :

1. **Google Cloud Console** → APIs & Services → Credentials → *Create
   credentials* → *OAuth client ID*.
   - Un client **Web application** est nécessaire dans tous les cas
     (Supabase gère le flux OAuth côté serveur) : renseigner comme
     "Authorized redirect URI" `https://<project-ref>.supabase.co/auth/v1/callback`.
   - Pour l'app mobile/desktop, ajoute aussi un client **Android**
     (avec le SHA-1 de signature) et/ou **iOS** si tu publies sur ces
     stores — sinon le client Web seul suffit pour tester.
2. **Dashboard Supabase** → Authentication → Providers → *Google* :
   active-le et colle le **Client ID** et **Client Secret** du client
   Web créé ci-dessus.
3. **Dashboard Supabase** → Authentication → URL Configuration → dans
   *Redirect URLs*, ajoute `io.supabase.bierodex://login-callback/`
   (retour mobile — voir `AuthService.oauthRedirectUrl`) ainsi que
   l'URL du site web déployé (le retour web utilise l'URL courante).

Sans cette configuration, le bouton "Continuer avec Google" affichera
une erreur de connexion (le provider n'est pas activé côté Supabase).

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
