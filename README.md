# Bierodex

Application mobile Flutter qui classifie les grands styles de bières,
un peu comme un "Pokédex" des bières — avec une carte du monde pour
repérer les brasseries à leur adresse réelle.

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
la carte du monde de l'écran d'accueil : toucher un repère ouvre la
liste des bières de cette brasserie.

Ce n'est pas une base exhaustive de "toutes les bières qui existent"
(il en existe des centaines de milliers) : c'est une taxonomie des
grands styles reconnus, avec des exemples représentatifs par style. Le
jeu de données (`lib/data/`) est fait pour être complété facilement.

## Compte et synchronisation

La collection personnelle (bières bues / notées) est toujours
disponible hors connexion (stockage local). En se connectant (e-mail
et mot de passe, ou compte Google, via Supabase Auth), elle se
synchronise en plus entre appareils.

Hors-ligne, chaque modification (dégustation, note, bière ajoutée ou
supprimée) est enregistrée sur l'appareil puis mise en file d'attente
(`lib/services/sync_queue.dart`). La file survit à un redémarrage et
part au retour du réseau, au retour au premier plan de l'app, ou toutes
les minutes tant qu'il reste des envois (`OfflineSyncService`). « Mon
compte » affiche le nombre de modifications en attente. Le catalogue est
lui aussi gardé en cache. Les fonctions sociales (amis, propositions,
modération) et l'envoi de photos restent en ligne uniquement.

## Rappels

Deux rappels locaux, programmés sur l'appareil sans serveur
(`NotificationService`, mobile uniquement) : « rien goûté depuis un
mois » (reporté à chaque nouvelle dégustation) et une bière de la
wishlist toutes les deux semaines. Désactivables dans « Mon compte ».

## Langues

L'interface est en français (langue de référence) et en anglais, via
les outils de traduction de Flutter (`flutter gen-l10n`, voir
`l10n.yaml`) : français sur un appareil réglé en français, anglais
ailleurs. Les textes sont dans `lib/l10n/app_fr.arb` et
`lib/l10n/app_en.arb` ; les fichiers `app_localizations*.dart` sont
générés (régénérés par `flutter pub get`) et commités. Dans un widget :
`context.l10n.maCle` ; ailleurs (services) : `L10n.current.maCle`.

Le contenu du catalogue (descriptions des styles et des bières) vient
de Supabase et reste en français ; seuls les noms de pays sont traduits
à l'affichage (`countryName` dans `lib/data/countries.dart`).

## Structure du code

```
lib/
  models/        # Beer, BeerStyle, BeerFamily, BreweryLocation
  data/          # Taxonomie des styles, bières, localisation des brasseries
  screens/       # Carte du monde, styles, collection, compte, recherche, détails
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

**Optionnel — sélecteur de compte natif sur iOS/Android** (sans passer par
le navigateur). Sinon, l'app garde le flux OAuth ci-dessus :

1. Google Cloud : créer aussi un client **iOS** (bundle
   `com.bierodex.bierodex`) et un client **Android** (package
   `com.bierodex.bierodex` + empreinte SHA-1, `./gradlew signingReport`).
2. Supabase → Providers → Google → *Client IDs* : les ID Web, iOS et
   Android séparés par des virgules.
3. `env.json` : `GOOGLE_WEB_CLIENT_ID` et `GOOGLE_IOS_CLIENT_ID` (voir
   `env.example.json`).
4. iOS : copier `ios/Flutter/GoogleSignIn.example.xcconfig` en
   `GoogleSignIn.xcconfig` (ignoré par git) avec l'ID client iOS inversé.

### Suppression de compte et mentions légales

- Déployer la fonction de suppression de compte :
  `supabase functions deploy delete-account`
  (code dans `supabase/functions/delete-account/`).
- Exécuter `supabase/secure_auth.sql` dans l'éditeur SQL.
- Compléter `lib/config/legal_config.dart` et `web/confidentialite.html`
  (éditeur, contact, région Supabase) avant toute publication.

## Intégration continue

`.github/workflows/ci.yml` lance, à chaque push sur `main` et sur chaque
pull request : vérification que les traductions générées sont à jour,
`flutter analyze`, `flutter test`, puis les builds web, Android (APK
debug) et iOS (sans signature). Aucun secret n'est nécessaire.

## Lancer le projet

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

Pour le web :

```bash
flutter build web --dart-define-from-file=env.json
```
